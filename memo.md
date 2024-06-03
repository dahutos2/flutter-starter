以下に、SageMakerを使用してDynamoDBから取得したデータをもとに、画像から大喜利の文字列を生成するモデルを作成する手順を詳細に説明します。

### 前提条件
- Lambda関数、DynamoDBテーブル、S3バケットはすでに作成済み。

### 手順

### 1. IAMポリシーの作成

#### ポリシー定義

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateTrainingJob",
                "sagemaker:DescribeTrainingJob",
                "sagemaker:CreateModel",
                "sagemaker:DescribeModel",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:DescribeEndpointConfig",
                "sagemaker:CreateEndpoint",
                "sagemaker:DescribeEndpoint"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

#### ポリシーの作成手順

1. AWSマネジメントコンソールにログインし、「IAM」サービスに移動します。
2. 左側のメニューから「ポリシー」を選択し、「ポリシーを作成」をクリックします。
3. 「JSON」タブを選択し、上記のポリシー定義をコピーして貼り付けます。
4. 「次のステップ: タグ」をクリックします（タグの設定は任意です）。
5. 「次のステップ: 確認」をクリックします。
6. ポリシーに名前を付けます（例: `SageMakerExecutionPolicy`）、説明を入力し、「ポリシーの作成」をクリックします。

### 2. IAMロールの作成とポリシーのアタッチ

1. IAMコンソールの左側メニューから「ロール」を選択し、「ロールを作成」をクリックします。
2. 「AWSサービス」を選択し、「SageMaker」を選択します。
3. 「次のステップ: アクセス許可」をクリックします。
4. 作成したポリシー（例: `SageMakerExecutionPolicy`）を検索して選択し、「次のステップ: タグ」をクリックします（タグの設定は任意です）。
5. 「次のステップ: 確認」をクリックします。
6. ロールに名前を付けます（例: `SageMakerExecutionRole`）、説明を入力し、「ロールの作成」をクリックします。
#### 1. SageMakerの設定

#### 1.1. トレーニングスクリプトの準備

トレーニングスクリプトを用意します。このスクリプトは、SageMakerで実行され、DynamoDBからデータを取得してモデルをトレーニングします。

以下は、トレーニングスクリプトの例です：

training_script.py

```python

import logging
import boto3
import json
import os
import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
from torch.utils.data import Dataset, DataLoader
from torch.nn.utils.rnn import pack_padded_sequence
from PIL import Image
from io import BytesIO
import requests

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 定数の定義
EMBEDDING_DIM = 256
HIDDEN_DIM = 512
VOCAB_SIZE = 5000  # 語彙サイズは必要に応じて調整
MAX_SEQ_LENGTH = 20

# 画像特徴抽出モデル（ResNet）
class EncoderCNN(nn.Module):
    def __init__(self, embed_size):
        super(EncoderCNN, self).__init__()
        resnet = models.resnet50(pretrained=True)
        modules = list(resnet.children())[:-1]  # 最後の全結合層を除く
        self.resnet = nn.Sequential(*modules)
        self.linear = nn.Linear(resnet.fc.in_features, embed_size)
        self.bn = nn.BatchNorm1d(embed_size, momentum=0.01)

    def forward(self, images):
        with torch.no_grad():
            features = self.resnet(images)
        features = features.reshape(features.size(0), -1)
        features = self.bn(self.linear(features))
        return features

# キャプション生成モデル（LSTM）
class DecoderRNN(nn.Module):
    def __init__(self, embed_size, hidden_size, vocab_size, num_layers=1):
        super(DecoderRNN, self).__init__()
        self.embed = nn.Embedding(vocab_size, embed_size)
        self.lstm = nn.LSTM(embed_size, hidden_size, num_layers, batch_first=True)
        self.linear = nn.Linear(hidden_size, vocab_size)
        self.max_seg_length = MAX_SEQ_LENGTH

    def forward(self, features, captions):
        embeddings = self.embed(captions)
        embeddings = torch.cat((features.unsqueeze(1), embeddings), 1)
        hiddens, _ = self.lstm(embeddings)
        outputs = self.linear(hiddens)
        return outputs

    def sample(self, features, states=None):
        sampled_ids = []
        inputs = features.unsqueeze(1)
        for i in range(self.max_seg_length):
            hiddens, states = self.lstm(inputs, states)  # (batch_size, 1, hidden_size)
            outputs = self.linear(hiddens.squeeze(1))  # (batch_size, vocab_size)
            _, predicted = outputs.max(1)  # (batch_size)
            sampled_ids.append(predicted)
            inputs = self.embed(predicted)  # (batch_size, embed_size)
            inputs = inputs.unsqueeze(1)  # (batch_size, 1, embed_size)
        sampled_ids = torch.stack(sampled_ids, 1)  # (batch_size, max_seq_length)
        return sampled_ids

# データセットクラスの定義
class OgiriDataset(Dataset):
    def __init__(self, dynamodb_table_name, s3_client, dynamodb_client):
        self.dynamodb_table_name = dynamodb_table_name
        self.s3_client = s3_client
        self.dynamodb_client = dynamodb_client
        self.data = self._load_data_from_dynamodb()
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225))
        ])
        logger.info(f"Loaded {len(self.data)} items from DynamoDB")

    def _load_data_from_dynamodb(self):
        paginator = self.dynamodb_client.get_paginator('scan')
        response_iterator = paginator.paginate(TableName=self.dynamodb_table_name)
        data = []
        for page in response_iterator:
            data.extend(page['Items'])
        return data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        item = self.data[idx]
        image_url = item['ImageUrl']['S']
        response = requests.get(image_url)
        image = Image.open(BytesIO(response.content)).convert('RGB')
        image = self.transform(image)
        expected_result = item['ExpectedResult']['S']
        labels = item['Labels']['SS']
        return image, expected_result, labels

# トレーニング関数
def train():
    dynamodb_table_name = os.environ['DYNAMODB_TABLE_NAME']
    s3_client = boto3.client('s3')
    dynamodb_client = boto3.client('dynamodb')

    dataset = OgiriDataset(dynamodb_table_name, s3_client, dynamodb_client)
    dataloader = DataLoader(dataset, batch_size=32, shuffle=True)

    # モデルの定義
    encoder = EncoderCNN(EMBEDDING_DIM)
    decoder = DecoderRNN(EMBEDDING_DIM, HIDDEN_DIM, VOCAB_SIZE)

    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    encoder.to(device)
    decoder.to(device)

    # 最適化関数と損失関数の定義
    criterion = nn.CrossEntropyLoss()
    params = list(decoder.parameters()) + list(encoder.linear.parameters()) + list(encoder.bn.parameters())
    optimizer = torch.optim.Adam(params, lr=0.001)

    # トレーニング開始
    logger.info("トレーニングを開始します")
    num_epochs = 10  # エポック数
    for epoch in range(num_epochs):
        logger.info(f"Epoch {epoch+1}/{num_epochs} started")
        for i, (images, captions, labels) in enumerate(dataloader):
            images = images.to(device)
            captions = captions.to(device)

            # 前方伝播
            features = encoder(images)
            outputs = decoder(features, captions)
            targets = pack_padded_sequence(captions, lengths=[len(caption) for caption in captions], batch_first=True)[0]
            loss = criterion(outputs.view(-1, outputs.size(2)), targets)

            # 逆伝播と最適化
            decoder.zero_grad()
            encoder.zero_grad()
            loss.backward()
            optimizer.step()

            if i % 100 == 0:
                logger.info(f"Epoch [{epoch+1}/{num_epochs}], Step [{i}/{len(dataloader)}], Loss: {loss.item():.4f}")

    # モデルの保存
    torch.save(encoder.state_dict(), '/opt/ml/model/encoder.ckpt')
    torch.save(decoder.state_dict(), '/opt/ml/model/decoder.ckpt')
    logger.info("トレーニングが完了し、モデルを保存しました")

if __name__ == '__main__':
    train()
```

#### 1.2. トレーニングスクリプトをS3にアップロード

1. AWSマネジメントコンソールで「S3」サービスに移動します。
2. アップロードしたいバケット（例: `bokete-training-data-bucket`）を選択します。
3. 「オブジェクトをアップロード」をクリックし、`training_script.py`をアップロードします。
### 2. SageMakerトレーニングジョブの設定

1. AWSマネジメントコンソールで「SageMaker」サービスに移動します。
2. 「トレーニングジョブ」を選択し、「トレーニングジョブの作成」をクリックします。
3. 以下の設定を行います：

#### トレーニングジョブ設定

- **トレーニングジョブ名**：`ogiri-training-job`
- **トレーニングイメージ**：組み込みのPyTorchイメージを選択します。
  - 例: `763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.6.0-cpu-py36-ubuntu16.04`

#### 入力データ設定

- **S3データソース**：
  - **チャンネル名**：`training`
  - **S3データの場所**：`s3://bokete-training-data-bucket/training_data.json`
  - **入力モード**：`File`

#### 出力データ設定

- **S3出力パス**：`s3://bokete-training-data-bucket/output/`

#### リソース設定

- **インスタンスタイプ**：`ml.m5.large`
- **インスタンス数**：`1`
- **ボリュームサイズ**：`50 GB`

#### その他の設定

- **ロールARN**：SageMakerにトレーニングジョブを実行する権限を持つIAMロールのARNを指定します。

SageMakerコンソールでCloudWatchログを有効にする
3. トレーニングジョブの設定画面で、「詳細設定」セクションに移動します。
4. 「ログオプション」で、「CloudWatch Logsにログを出力」を有効にします。

### 3. Lambda関数の設定

以下は、このLambda関数に必要なポリシーのJSONです。これには、S3、Rekognition、DynamoDB、およびSageMakerに対する必要な権限が含まれています。

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "rekognition:DetectLabels",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/OgiriTrainingDataTable"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateTrainingJob",
                "sagemaker:DescribeTrainingJob"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:123456789012:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/*"
            ]
        }
    ]
}
```

このポリシーJSONには、以下の権限が含まれています：

1. **S3権限**：
    - `s3:GetObject`、`s3:PutObject`、`s3:ListBucket`：Lambda関数がS3バケットからオブジェクトを取得し、オブジェクトをアップロードし、バケットの内容をリストできるようにします。

2. **Rekognition権限**：
    - `rekognition:DetectLabels`：Lambda関数がRekognitionを使用して画像のラベルを検出できるようにします。

3. **DynamoDB権限**：
    - `dynamodb:PutItem`、`dynamodb:GetItem`、`dynamodb:UpdateItem`：Lambda関数がDynamoDBテーブルに項目を追加、取得、更新できるようにします。

4. **SageMaker権限**：
    - `sagemaker:CreateTrainingJob`、`sagemaker:DescribeTrainingJob`：Lambda関数がSageMakerでトレーニングジョブを作成および説明できるようにします。

5. **CloudWatch Logs権限**：
    - `logs:CreateLogGroup`、`logs:CreateLogStream`、`logs:PutLogEvents`：Lambda関数がCloudWatch Logsにログを出力できるようにします。

これにより、Lambda関数が必要なリソースにアクセスし、適切にログを出力できるようになります。

Lambda関数を設定し、トレーニングジョブを実行します。

#### 3.1. Lambda関数の編集

Lambda関数にSageMakerトレーニングジョブを実行するコードを追加します。

1. **Lambda関数の編集**：
   - AWSマネジメントコンソールにログインし、「Lambda」サービスに移動します。
   - 作成済みのLambda関数（例: `ProcessCsvAndTrainModel`）を選択します。
   - 関数コードの編集画面に移動し、以下のコードを追加します。

```python
import json
import boto3
import csv
import requests
from botocore.exceptions import NoCredentialsError, ClientError
import logging

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')
sagemaker = boto3.client('sagemaker')

def lambda_handler(event, context):
    try:
        # イベントからバケット名とオブジェクトキーを取得
        bucket = event.get('bucket')
        key = event.get('key')
        
        if not bucket or not key:
            raise ValueError("bucket and key must be specified in the event")

        # S3からCSVファイルを取得
        csv_file = s3.get_object(Bucket=bucket, Key=key)
        csv_content = csv_file['Body'].read().decode('utf-8').splitlines()
        csv_reader = csv.reader(csv_content)

        for row in csv_reader:
            image_url, expected_result = row
            
            try:
                # グローバルなURLから画像をダウンロード
                image_data = requests.get(image_url).content
                image_key = image_url.split('/')[-1]
                
                # ダウンロードした画像をS3にアップロード
                s3.put_object(Bucket=bucket, Key=image_key, Body=image_data)
                
                # S3のURLを生成
                s3_url = f"https://{bucket}.s3.amazonaws.com/{image_key}"
                
                # Rekognitionを使用して画像を分析
                rekognition_response = rekognition.detect_labels(
                    Image={'S3Object': {'Bucket': bucket, 'Name': image_key}},
                    MaxLabels=10
                )
                labels = [label['Name'] for label in rekognition_response['Labels']]
                
                # DynamoDBに画像URLと期待結果を保存
                table = dynamodb.Table('OgiriTrainingDataTable')
                table.put_item(
                    Item={
                        'ImageKey': image_key,
                        'ImageUrl': s3_url,  # S3のURLを保存
                        'Labels': labels,
                        'ExpectedResult': expected_result
                    }
                )
                logger.info(f"Successfully processed {image_url}")

            except requests.exceptions.RequestException as e:
                logger.error(f"Failed to download image from {image_url}: {str(e)}")
            except ClientError as e:
                logger.error(f"Failed to process image {image_url}: {str(e)}")
        
        # SageMakerトレーニングジョブの作成
        response = sagemaker.create_training_job(
            TrainingJobName='ogiri-training-job',
            HyperParameters={
                'batch_size': '32',
                'epochs': '10'
            },
            AlgorithmSpecification={
                'TrainingImage': '763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.6.0-cpu-py36-ubuntu16.04',
                'TrainingInputMode': 'File'
            },
            RoleArn='arn:aws:iam::123456789012:role/SageMakerRole',
            InputDataConfig=[
                {
                    'ChannelName': 'training',
                    'DataSource': {
                        'S3DataSource': {
                            'S3DataType': 'S3Prefix',
                            'S3Uri': 's3://bokete-training-data-bucket/training_data.json',
                            'S3DataDistributionType': 'FullyReplicated'
                        }
                    },
                    'ContentType': 'application/json',
                    'InputMode': 'File'
                }
            ],
            OutputDataConfig={
                'S3OutputPath': 's3://bokete-training-data-bucket/output/'
            },
            ResourceConfig={
                'InstanceType': 'ml.m5.large',
                'InstanceCount': 1,
                'VolumeSizeInGB': 50
            },
            StoppingCondition={
                'MaxRuntimeInSeconds': 86400
            }
        )
        
        logger.info("Training job started successfully")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Training job started successfully')
        }
    except NoCredentialsError:
        logger.error("Credentials not available")
        return {
            'statusCode': 403,
            'body': 'Credentials not available'
        }
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
```

### Lambda関数の設定

#### CloudWatch Logsの確認

Lambda関数を実行すると、ログは自動的にCloudWatch Logsに送られます。AWSマネジメントコンソールで以下の手順でログを確認できます：

1. **AWSマネジメントコンソール**にログインします。
2. **CloudWatch**サービスに移動します。
3. 左側のメニューから「ロググループ」を選択します。
4. Lambda関数名に対応するロググループをクリックします（例：`/aws/lambda/YourLambdaFunctionName`）。
5. ログストリームを選択し、ログを確認します。

#### Lambda関数のテスト

Lambda関数をAWSコンソールで手動実行するには：

1. **Lambdaコンソール**に移動し、関数を選択します。
2. 「テスト」タブをクリックし、新しいテストイベントを作成します。
3. テストイベントに以下のようなJSONを設定します：
   ```json
   {
       "bucket": "your-bucket-name",
       "key": "path/to/your/csvfile.csv"
   }
   ```
4. 「テスト」ボタンをクリックして関数を実行します。
5. 実行結果とログを確認します。

### 4. モデルのデプロイと推論

トレーニングジョブが完了すると、モデルのアーティファクトが指定したS3バケットに保存されます。

学習をやり直すたびにモデルの再作成やエンドポイントの再デプロイを行う必要はありません。ただし、モデルが改善されたり新しいデータで再学習を行う場合には、エンドポイントを更新する必要があります。以下に、AWSコンソールを使用してこれらの操作を行う方法を説明します。

### 1. SageMakerトレーニングジョブの確認と実行

1. **AWS Management Console**にログインし、**SageMaker**に移動します。
2. 左側のメニューから「**トレーニングジョブ**」を選択します。
3. 「**トレーニングジョブの作成**」をクリックします。
4. トレーニングジョブの詳細を入力します。必要な情報は以下の通りです：
    - **トレーニングジョブ名**：任意の名前
    - **アルゴリズム**：ビルトインアルゴリズム、Amazonの提供するコンテナ、またはカスタムコンテナのいずれかを選択
    - **入力データ設定**：
        - **S3入力データ**：学習用データが保存されているS3バケットのパス
        - **チャンネル名**：`training`（例として）
    - **出力データ設定**：
        - **S3出力データパス**：学習結果を保存するS3バケットのパス
    - **リソース設定**：
        - **インスタンスタイプ**：学習に使用するインスタンスのタイプ
        - **インスタンス数**：1
        - **ボリュームサイズ**：50GB
    - **IAMロール**：SageMakerが使用するIAMロール

5. 「**トレーニングジョブの作成**」をクリックしてジョブを開始します。

### 2. モデルの作成

1. トレーニングジョブが完了した後、SageMakerコンソールの左側メニューから「**モデル**」を選択します。
2. 「**モデルの作成**」をクリックします。
3. モデルの詳細を入力します。必要な情報は以下の通りです：
    - **モデル名**：任意の名前
    - **コンテナ**：
        - **コンテナのイメージ**：推論に使用するコンテナのイメージ（例：`763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-inference:1.6.0-cpu-py36-ubuntu16.04`）
        - **モデルアーティファクトのS3場所**：トレーニングジョブの出力データが保存されているS3バケットのパス
    - **IAMロール**：SageMakerが使用するIAMロール

4. 「**モデルの作成**」をクリックします。

### 3. エンドポイント構成の作成

1. SageMakerコンソールの左側メニューから「**エンドポイント構成**」を選択します。
2. 「**エンドポイント構成の作成**」をクリックします。
3. エンドポイント構成の詳細を入力します。必要な情報は以下の通りです：
    - **エンドポイント構成名**：任意の名前
    - **プロダクションバリアント**：
        - **バリアント名**：任意の名前（例：`AllTraffic`）
        - **モデル名**：先ほど作成したモデル
        - **インスタンスタイプ**：推論に使用するインスタンスのタイプ（例：`ml.m5.large`）
        - **初期インスタンス数**：1

4. 「**エンドポイント構成の作成**」をクリックします。

### 4. エンドポイントの作成

1. SageMakerコンソールの左側メニューから「**エンドポイント**」を選択します。
2. 「**エンドポイントの作成**」をクリックします。
3. エンドポイントの詳細を入力します。必要な情報は以下の通りです：
    - **エンドポイント名**：任意の名前
    - **エンドポイント構成名**：先ほど作成したエンドポイント構成

4. 「**エンドポイントの作成**」をクリックします。

これにより、トレーニングジョブの実行、モデルの作成、エンドポイント構成の作成、およびエンドポイントのデプロイが完了します。学習をやり直すたびにこれらの操作を行う必要がありますが、特にモデルを更新する際に役立ちます。

### まとめ

1. **トレーニングスクリプトを準備し、S3にアップロード**。
2. **Lambda関数を修正して、トレーニングジョブを実行**。
3. **トレーニングジョブの結果を確認し、モデルをデプロイ**。
4. **エンドポイントを使用して推論を実行**。

この手順に従うことで、AWSマネジメントコンソールのUIを使用して、画像から大喜利の文字列を生成するモデルを作成およびデプロイできます。

Lambda関数を使用してSageMakerのトレーニングジョブを開始し、その後のモデル作成およびエンドポイントの作成も自動化することができます。以下は、その手順を説明します。

### 1. Lambda関数の設定と実行

Lambda関数内でSageMakerトレーニングジョブの開始、モデルの作成、エンドポイントの作成までを一貫して行うようにします。以下は、トレーニングジョブの開始からエンドポイントの作成までを含むLambda関数のコードです。

### 説明

1. **イベントからバケット名とオブジェクトキーの取得**：
   - 手動で実行するため、イベントから `bucket` と `key` を取得するように変更しました。

2. **CSVファイルの処理**：
   - CSVファイルから各行を読み込み、画像をダウンロードし、S3にアップロードしてURLを生成します。

3. **Rekognitionの使用**：
   - Rekognitionを使用して画像のラベルを取得し、DynamoDBに保存します。

4. **SageMakerトレーニングジョブの作成**：
   - トレーニングジョブを作成し、完了を待ちます。

5. **モデルの作成**：
   - トレーニングが完了したら、S3に保存されたモデルデータを使用してモデルを作成します。

6. **エンドポイント構成とエンドポイントの作成**：
   - モデルをデプロイするためのエンドポイント構成を作成し、エンドポイントを作成します。

### 注意点

- **ロールとポリシー**：このLambda関数がSageMakerのトレーニングジョブを開始し、モデルを作成し、エンドポイントを作成するために必要なIAMロールとポリシーを適切に設定してください。
- **エラーハンドリング**：エラーが発生した場合に適切にログを出力し、エラー内容を把握できるようにしています。

これにより、Lambda関数を実行するだけで、トレーニングジョブの開始からエンドポイントの作成までを自動化することができます。
