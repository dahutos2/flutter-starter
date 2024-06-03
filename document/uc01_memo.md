### 1. ローカルからCSVファイルをS3にアップロードするバッチスクリプト
### 2. IAMポリシーの作成
#### トレーニングジョブ開始するLambda用

<details><summary>詳細を開く</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::ogiri-training-data-bucket",
                "arn:aws:s3:::ogiri-training-data-bucket/*"
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

</details>

#### トレーニングジョブ終了後のLambda用

<details><summary>詳細を開く</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateModel",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:CreateEndpoint",
                "sagemaker:DescribeTrainingJob"
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

</details>

#### トレーニングジョブ開始するSageMaker用

<details><summary>詳細を開く</summary>

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
                "arn:aws:s3:::ogiri-training-data-bucket",
                "arn:aws:s3:::ogiri-training-data-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        }
    ]
}
```

</details>

#### トレーニングジョブ終了後のSageMaker

<details><summary>詳細を開く</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:DescribeTrainingJob",
                "sagemaker:CreateModel",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:CreateEndpoint"
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

</details>

#### IAMユーザー用

<details><summary>詳細を開く</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::ogiri-training-data-bucket",
                "arn:aws:s3:::ogiri-training-data-bucket/*"
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
                "dynamodb:UpdateItem",
                "dynamodb:Scan",
                "dynamodb:Query"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/OgiriTrainingDataTable"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateTrainingJob",
                "sagemaker:DescribeTrainingJob",
                "sagemaker:CreateModel",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:CreateEndpoint",
                "sagemaker:InvokeEndpoint"
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
            "Resource": "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ProcessTrainingData"
        }
    ]
}
```

</details>

### 3. IAMロールの作成
#### トレーニングジョブ開始するLambda用のロールとポリシー

##### ロール名：`LambdaStartOgiriTrainingJobRole`
##### ポリシー名：`LambdaStartOgiriTrainingJobPolicy`

#### トレーニングジョブ終了後のLambda用のロールとポリシー

##### ロール名：`LambdaEndOgiriTrainingJobRole`
##### ポリシー名：`LambdaEndOgiriTrainingJobPolicy`

#### トレーニングジョブ開始するSageMaker用のロールとポリシー

##### ロール名：`SageMakerStartOgiriTrainingJobRole`
##### ポリシー名：`SageMakerStartOgiriTrainingJobPolicy`

#### トレーニングジョブ終了後のSageMaker用のロールとポリシー

##### ロール名：`SageMakerEndOgiriTrainingJobRole`
##### ポリシー名：`SageMakerEndOgiriTrainingJobPolicy`

### 4. IAMユーザの作成

#### ポリシー名：`OgiriServiceUserPolicy`

### 5. S3バケットの設定
### 6. DynamoDBテーブルの作成
### 7. SageMakerの設定
#### 7.1. トレーニングスクリプトの準備
`training_script.py`を作成する

<details><summary>詳細をクリック</summary>

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

</details>

#### 7.2. トレーニングスクリプトをS3にアップロード

1. AWSマネジメントコンソールで「S3」サービスに移動します。
2. アップロードしたいバケット（例: `ogiri-training-data-bucket`）を選択します。
3. 「オブジェクトをアップロード」をクリックし、`training_script.py`をアップロードします。

### 8. トレーニングジョブ開始するLambda関数の作成

1. **Lambda関数の作成**：
    - Lambdaダッシュボードに移動し、「関数の作成」をクリックします。
    - 「一から作成」を選択し、関数名（例: `StartOgiriTrainingJob`）を入力し、ランタイムをPython 3.8に設定します。
    - 実行ロールには「既存のロールを使用する」を選択し、`LambdaStartOgiriTrainingRole`を選択します。
    - 「関数の作成」をクリックします。

2. **Lambda関数にコードを追加**：

<details><summary>詳細をクリック</summary>

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
                image_name = image_url.split('/')[-1]
                image_key = f"images/{image_name}"  # images ディレクトリに配置
                
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
                        'ImageUrl': s3_url,
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
        training_job_name = 'ogiri-training-job'
        response = sagemaker.create_training_job(
            TrainingJobName=training_job_name,
            HyperParameters={
                'batch_size': '32',
                'epochs': '10'
            },
            AlgorithmSpecification={
                'TrainingImage': '763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.6.0-cpu-py36-ubuntu16.04',
                'TrainingInputMode': 'File',
                'MetricDefinitions': [
                    {'Name': 'validation:error', 'Regex': 'validation:error=(.*)'}
                ],
                'TrainingInputMode': 'File',
                'EnableSageMakerMetricsTimeSeries': True,
                'ScriptMode': 'SageMaker',
                'TrainingScript': 's3://ogiri-training-data-bucket/training_script.py'
            },
            RoleArn='arn:aws:iam::123456789012:role/SageMakerStartOgiriTrainingJobRole',
            InputDataConfig=[
                {
                    'ChannelName': 'training',
                    'DataSource': {
                        'S3DataSource': {
                            'S3DataType': 'S3Prefix',
                            'S3Uri': 's3://ogiri-training-data-bucket/training_data.json',
                            'S3DataDistributionType': 'FullyReplicated'
                        }
                    },
                    'ContentType': 'application/json',
                    'InputMode': 'File'
                }
            ],
            OutputDataConfig={
                'S3OutputPath': 's3://ogiri-training-data-bucket/output/'
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

</details>

3. **テストイベントの設定**：
    - 「テスト」ボタンをクリックし、テストイベントを作成します。以下のようなJSONを使用します：
      - [トレーニングジョブ終了後のlambda関数の作成](#10-トレーニングジョブ終了後のlambda関数の作成)完了後にテストする

```json
{
  "bucket": "ogiri-training-data-bucket",
  "key": "data.csv"
}
```

### 9. CloudWatch Event Ruleを設定する

1. **CloudWatch Eventルールの作成**：
    - AWSマネジメントコンソールで「CloudWatch」サービスに移動します。
    - 左側のメニューから「ルール」を選択し、「ルールの作成」をクリックします。

2. **ルールの詳細の設定**：
    - イベントソースを「イベントパターン」に設定し、以下のイベントパターンを使用します：

```json
{
  "source": [
    "aws.sagemaker"
  ],
  "detail-type": [
    "SageMaker Training Job State Change"
  ],
  "detail": {
    "TrainingJobName": [
      "ogiri-training-job"
    ],
    "TrainingJobStatus": [
      "Completed"
    ]
  }
}
```

3. **ターゲットの設定**：
    - ターゲットに新しいLambda関数を選択します。関数名を（例：`EndOgiriTrainingJob`）とします。

### 10. トレーニングジョブ終了後のLambda関数の作成

1. **Lambda関数の作成**：
    - Lambdaダッシュボードに移動し、「関数の作成」をクリックします。
    - 「一から作成」を選択し、関数名（例: `EndOgiriTrainingJob`）を入力し、ランタイムをPython 3.8に設定します。
    - 実行ロールには「既存のロールを使用する」を選択し、`LambdaEndOgiriTrainingRole`を選択します。
    - 「関数の作成」をクリックします。

2. **Lambda関数にコードを追加**：
    - 作成したLambda関数に以下のコードを追加します。

<details><summary>詳細をクリック</summary>

```python
import json
import boto3
import logging

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

sagemaker = boto3.client('sagemaker')

def lambda_handler(event, context):
    try:
        training_job_name = event['detail']['TrainingJobName']
        
        # トレーニングジョブの完了を確認
        if event['detail']['TrainingJobStatus'] != 'Completed':
            logger.error(f"Training job {training_job_name} did not complete successfully.")
            return {
                'statusCode': 400,
                'body': json.dumps('Training job did not complete successfully')
            }
        
        # モデルの作成
        model_name = 'ogiri-model'
        sagemaker.create_model(
            ModelName=model_name,
            PrimaryContainer={
                'Image': '763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-inference:1.6.0-cpu-py36-ubuntu16.04',
                'ModelDataUrl': f"s3://ogiri-training-data-bucket/output/{training_job_name}/output/model.tar.gz"
            },
            ExecutionRoleArn='arn:aws:iam::123456789012:role/SageMakerEndOgiriTrainingJobRole'
        )
        
        logger.info("Model created successfully")
        
        # エンドポイント構成の作成
        endpoint_config_name = 'ogiri-endpoint-config'
        sagemaker.create_endpoint_config(
            EndpointConfigName=endpoint_config_name,
            ProductionVariants=[
                {
                    'VariantName': 'AllTraffic',
                    'ModelName': model_name,
                    'InstanceType': 'ml.m5.large',
                    'InitialInstanceCount': 1
                }
            ]
        )
        
        logger.info("Endpoint configuration created successfully")
        
        # エンドポイントの作成
        endpoint_name = 'ogiri-endpoint'
        sagemaker.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=endpoint_config_name
        )
        
        logger.info("Endpoint created successfully")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Model and endpoint created successfully')
        }
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
```

</details>
