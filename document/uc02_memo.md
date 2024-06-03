以下に変数名の例と具体例を示します：

- **{API_NAME}**
  - 例: `OgiriImageProcessingAPI`
  
- **{API_DESCRIPTION}**
  - 例: `API for processing images and generating captions`
  
- **{PROCESS_IMAGE_LAMBDA_NAME}**
  - 例: `ProcessImageLambda`
  
- **{S3_BUCKET_NAME}**
  - 例: `ogiri-training-data-bucket`
  
- **{DYNAMODB_TABLE_NAME}**
  - 例: `OgiriTrainingDataTable`
  
- **{AWS_REGION}**
  - 例: `us-east-1`
  
- **{AWS_ACCOUNT_ID}**
  - 例: `123456789012`
  
- **{YOUR_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME}**
  - 例: `d1234abcdefg.cloudfront.net`
  
- **{YOUR_API_DOMAIN_NAME}**
  - 例: `api.example.com`

これらの具体例をもとに、適切な変数名を設定してください。

### 1. API Gateway の設定
1. **AWS マネジメントコンソール**で「API Gateway」サービスに移動します。
2. **REST API の作成**を選択し、「新しい API を作成」を選択して、次の設定を行います。
    - **API 名**: `{API_NAME}`
    - **説明**: `{API_DESCRIPTION}`
    - **エンドポイントタイプ**: 「エッジ最適化」

3. **作成**をクリックします。

#### 1.1 リソースとメソッドの作成
1. 作成した API の左側のペインで「リソースの作成」をクリックし、次の設定を行います。
    - **リソースパス**: `/process-image`
2. 作成したリソースを選択し、「アクション」から「メソッドの作成」を選び、`POST` を選択します。
3. 「統合タイプ」を「Lambda 関数」とし、次の設定を行います。
    - **Lambda リージョン**: Lambda 関数を作成したリージョン
    - **Lambda 関数**: `{PROCESS_IMAGE_LAMBDA_NAME}`

#### 1.2 CORS の有効化
1. 作成したメソッドを選択し、「アクション」から「CORS を有効にする」を選択します。

### 2. Lambda 関数の作成
1. **AWS マネジメントコンソール**で「Lambda」サービスに移動します。
2. **関数の作成**をクリックし、次の設定を行います。
    - **関数名**: `{PROCESS_IMAGE_LAMBDA_NAME}`
    - **ランタイム**: `Python 3.8`
3. 「関数を作成」をクリックします。

#### 2.1 Lambda 関数の設定
1. 以下のコードを Lambda 関数のコードエディタに貼り付けます。

```python
import json
import boto3
import logging
import base64
from botocore.exceptions import NoCredentialsError, ClientError

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    try:
        # 画像ファイルのデータを取得
        image_data = base64.b64decode(event['body'])
        image_key = event['headers']['image_key']
        bucket = '{S3_BUCKET_NAME}'
        
        # S3に画像をアップロード
        s3.put_object(Bucket=bucket, Key=image_key, Body=image_data)
        logger.info(f"Uploaded image to S3: {image_key}")
        
        # Rekognitionで画像を分析
        rekognition_response = rekognition.detect_labels(
            Image={'S3Object': {'Bucket': bucket, 'Name': image_key}},
            MaxLabels=10
        )
        labels = [label['Name'] for label in rekognition_response['Labels']]
        
        # DynamoDBに保存
        table = dynamodb.Table('{DYNAMODB_TABLE_NAME}')
        table.put_item(
            Item={
                'ImageKey': image_key,
                'Labels': labels
            }
        )
        logger.info(f"Saved labels to DynamoDB: {labels}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'labels': labels})
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

#### 2.2 Lambda 関数の権限設定
1. Lambda 関数の「権限」タブで「実行ロールの設定」をクリックし、次のポリシーを追加します。
   - **S3 アクセス**: 
   ```json
   {
       "Effect": "Allow",
       "Action": [
           "s3:PutObject",
           "s3:GetObject",
           "s3:ListBucket"
       ],
       "Resource": [
           "arn:aws:s3:::{S3_BUCKET_NAME}",
           "arn:aws:s3:::{S3_BUCKET_NAME}/*"
       ]
   }
   ```
   - **DynamoDB アクセス**:
   ```json
   {
       "Effect": "Allow",
       "Action": [
           "dynamodb:PutItem",
           "dynamodb:GetItem",
           "dynamodb:UpdateItem",
           "dynamodb:Scan",
           "dynamodb:Query"
       ],
       "Resource": "arn:aws:dynamodb:{AWS_REGION}:{AWS_ACCOUNT_ID}:table/{DYNAMODB_TABLE_NAME}"
   }
   ```
   - **Rekognition アクセス**:
   ```json
   {
       "Effect": "Allow",
       "Action": "rekognition:DetectLabels",
       "Resource": "*"
   }
   ```
   - **CloudWatch Logs アクセス**:
   ```json
   {
       "Effect": "Allow",
       "Action": [
           "logs:CreateLogGroup",
           "logs:CreateLogStream",
           "logs:PutLogEvents"
       ],
       "Resource": "arn:aws:logs:{AWS_REGION}:{AWS_ACCOUNT_ID}:log-group:/aws/lambda/{PROCESS_IMAGE_LAMBDA_NAME}"
   }
   ```

### 3. S3 バケットの作成
1. **AWS マネジメントコンソール**で「S3」サービスに移動します。
2. **バケットの作成**をクリックし、次の設定を行います。
    - **バケット名**: `{S3_BUCKET_NAME}`
3. その他の設定を行い、「作成」をクリックします。

### 4. DynamoDB テーブルの作成
1. **AWS マネジメントコンソール**で「DynamoDB」サービスに移動します。
2. **テーブルの作成**をクリックし、次の設定を行います。
    - **テーブル名**: `{DYNAMODB_TABLE_NAME}`
    - **プライマリキー**: `ImageKey`（文字列）
3. その他の設定を行い、「作成」をクリックします。

### 5. CloudFront ディストリビューションの設定
1. **AWS マネジメントコンソール**で「CloudFront」サービスに移動します。
2. **ディストリビューションの作成**をクリックし、次の設定を行います。
    - **オリジンドメイン名**: API Gateway のエンドポイント（例: `abcd1234.execute-api.{AWS_REGION}.amazonaws.com`）
    - **プロトコル**: HTTP and HTTPS
3. 「作成」をクリックします。

### 6. Route 53 ドメインの設定
1. **AWS マネジメントコンソール**で「Route 53」サービスに移動します。
2. 「ホストゾーン」を選択し、新しいレコードセットを作成します。
    - **名前**: `{YOUR_API_DOMAIN_NAME}`
    - **タイプ**: `A - IPv4 address`
    - **エイリアス**: `Yes`
    - **エイリアスターゲット**: CloudFront のディストリビューション

### 7. cURL を使用してバッチファイルを作成
1. テキストエディタを開き、以下の内容を貼り付けます。

```batch
@echo off
setlocal

REM 画像ファイルパスとAPIエンドポイントURLを設定
set "IMAGE_PATH=C:\path\to\your\image.jpg"
set "API_ENDPOINT=https://{YOUR_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME}/process-image"
set "IMAGE_KEY=your_image_key.jpg"

REM 画像をAPIにPOST
curl -X POST "%API_ENDPOINT%" -H "Content-Type: application/octet-stream" -H "image_key: %IMAGE_KEY%" --data-binary "@%IMAGE_PATH%"

endlocal
pause
```

2. ファイルを保存し、拡張子を `.bat` として保存します（例: `upload_image.bat`）。
3. バッチファイルをダブルクリックして実行します。

これで、ローカルから画像をPOSTしてAPIを呼び出し、結果を受け取ることができます。

了解しました。以下は、外部のアプリから画像をPOSTして、モデルを使って画像の検証結果の文字列を返し、画像と検証結果の文字列をDBに保存するためのAWSのUIを使用した手順です。

## 1. S3バケットの作成

1. AWSマネジメントコンソールにログインします。
2. 「**S3**」サービスに移動します。
3. 「**バケットを作成**」をクリックします。
4. バケット名を入力します（例：`ogiri-images-bucket`）。
5. 他の設定はデフォルトのままにし、「**バケットを作成**」をクリックします。

## 2. DynamoDBテーブルの作成

1. AWSマネジメントコンソールで「**DynamoDB**」サービスに移動します。
2. 「**テーブルの作成**」をクリックします。
3. テーブル名を入力します（例：`OgiriResultsTable`）。
4. プライマリキーを設定します：
   - **パーティションキー**：`ImageKey`（文字列）
5. 「**テーブルの作成**」をクリックします。

## 3. Lambda関数の作成

1. AWSマネジメントコンソールで「**Lambda**」サービスに移動します。
2. 「**関数の作成**」をクリックします。
3. 「**一から作成**」を選択し、関数名を入力します（例：`ProcessImageFunction`）。
4. 実行ロールを作成するため、「**新しいロールを作成（基本的なLambdaの権限を持つ）**」を選択します。
5. 「**関数の作成**」をクリックします。
6. 作成した関数のページで、「**コードソース**」セクションに移動し、以下のコードを入力します：

```python
import json
import boto3
import requests
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    try:
        # 画像データを取得
        image = event['image']
        image_key = event['image_key']
        bucket = 'ogiri-images-bucket'
        
        # 画像をS3にアップロード
        s3.put_object(Bucket=bucket, Key=image_key, Body=image)
        
        # Rekognitionで画像を分析
        response = rekognition.detect_labels(Image={'S3Object': {'Bucket': bucket, 'Name': image_key}}, MaxLabels=10)
        labels = [label['Name'] for label in response['Labels']]
        
        # DynamoDBに画像URLと結果を保存
        table = dynamodb.Table('OgiriResultsTable')
        table.put_item(
            Item={
                'ImageKey': image_key,
                'ImageUrl': f"https://{bucket}.s3.amazonaws.com/{image_key}",
                'Labels': labels,
                'Result': 'Random Result'  # ランダムな結果を保存（今回は固定値として記載）
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'image_url': f"https://{bucket}.s3.amazonaws.com/{image_key}",
                'labels': labels,
                'result': 'Random Result'  # ランダムな結果を返す（今回は固定値として記載）
            })
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing image: {str(e)}")
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
```

7. 「**デプロイ**」をクリックして関数を保存します。

## 4. API Gatewayの作成

1. AWSマネジメントコンソールで「**API Gateway**」サービスに移動します。
2. 「**REST API**」を選択し、「**新しいAPIを作成**」をクリックします。
3. API名を入力します（例：`OgiriAPI`）。
4. 「**APIの作成**」をクリックします。
5. 新しく作成したAPIのページで、「**リソースの作成**」をクリックします。
6. 「**リソースパス**」を入力します（例：`/process-image`）。
7. 「**リソースの作成**」をクリックします。
8. 新しいリソースを選択し、「**アクション**」->「**メソッドの作成**」をクリックします。
9. 「**POST**」を選択し、「**チェックマーク**」をクリックします。
10. 統合タイプとして「**Lambda関数**」を選択し、Lambda関数名を入力します（例：`ProcessImageFunction`）。
11. 「**保存**」をクリックします。
12. 「**メソッドリクエスト**」->「**クエリ文字列パラメータ**」をクリックし、`image_key`パラメータを追加します。
13. 「**メソッドの応答**」をクリックし、ステータスコード `200` と `500` のレスポンスモデルを設定します。
14. 「**リソースポリシー**」を設定し、適切なアクセス許可を設定します。
15. APIをデプロイします：
    - 「**アクション**」->「**APIのデプロイ**」をクリックします。
    - 新しいステージを作成し（例：`prod`）、デプロイします。

## 5. CloudFrontの設定

1. AWSマネジメントコンソールで「**CloudFront**」サービスに移動します。
2. 「**ディストリビューションの作成**」をクリックします。
3. **オリジンドメイン**としてAPI Gatewayのエンドポイントを指定します。
4. 他の設定を行い、「**作成**」をクリックします。

## 6. Route 53の設定

1. AWSマネジメントコンソールで「**Route 53**」サービスに移動します。
2. 「**ホストゾーン**」を作成します（もしまだ作成していない場合）。
3. 新しいレコードセットを作成し、CloudFrontディストリビューションを指すCNAMEを設定します。

これにより、外部のアプリケーションが画像をPOSTして検証結果を取得し、画像と結果をDynamoDBに保存する仕組みが構築されます。

以下の手順で、指定されたユースケース（UC）をAWSのUIを使って構築します。今回のUCでは、外部アプリケーションから画像をPOSTし、SageMakerモデルを使って画像の検証結果を返し、画像と検証結果をDynamoDBに保存するフローを設定します。

### 1. S3バケットの作成

1. **S3サービス**に移動します。
2. **「バケットを作成」**をクリックします。
3. バケット名を入力（例: `ogiri-images-bucket`）。
4. **「作成」**をクリックします。

### 2. DynamoDBテーブルの作成

1. **DynamoDBサービス**に移動します。
2. **「テーブルを作成」**をクリックします。
3. テーブル名を入力（例: `OgiriResultsTable`）。
4. プライマリキーを設定します。
   - パーティションキー: `ImageKey` (文字列)
5. **「テーブルを作成」**をクリックします。

### 3. SageMakerモデルのデプロイ

1. **SageMakerサービス**に移動します。
2. **「トレーニングジョブ」**を作成し、モデルをトレーニングします。
3. **「モデル」**を作成し、トレーニングしたモデルを登録します。
4. **「エンドポイント構成」**を作成し、モデルをデプロイするためのエンドポイントを設定します。
5. **「エンドポイント」**を作成し、エンドポイント構成を指定してエンドポイントをデプロイします。

### 4. API Gatewayの作成

1. **API Gatewayサービス**に移動します。
2. **「REST APIを作成」**を選択します。
3. API名を入力（例: `OgiriAPI`）。
4. **「エンドポイントの種類」**を選択し、「地域」を選択します。
5. **「リソースを作成」**をクリックし、リソース名を設定（例: `/upload`）。
6. **「メソッドを作成」**をクリックし、HTTPメソッドをPOSTに設定します。
7. **統合タイプ**として「Lambda関数」を選択し、前ステップで作成したLambda関数を指定します。

### 5. Lambda関数の作成

1. **Lambdaサービス**に移動します。
2. **「関数を作成」**をクリックします。
3. 関数名を入力（例: `OgiriFunction`）。
4. **「ランタイム」**をPythonに設定します。
5. 関数の作成後、以下のコードを貼り付けます。

```python
import json
import boto3
import base64
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sagemaker_runtime = boto3.client('sagemaker-runtime')

def lambda_handler(event, context):
    try:
        # 画像データを取得
        body = json.loads(event['body'])
        image_data = base64.b64decode(body['image'])
        image_key = body['filename']
        
        # 画像をS3に保存
        bucket_name = 'ogiri-images-bucket'
        s3.put_object(Bucket=bucket_name, Key=image_key, Body=image_data)
        
        # SageMakerエンドポイントを呼び出して予測
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName='ogiri-endpoint',
            ContentType='image/jpeg',
            Body=image_data
        )
        
        result = json.loads(response['Body'].read().decode())
        
        # DynamoDBに保存
        table = dynamodb.Table('OgiriResultsTable')
        table.put_item(
            Item={
                'ImageKey': image_key,
                'ImageUrl': f'https://{bucket_name}.s3.amazonaws.com/{image_key}',
                'Result': result
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'result': result})
        }
        
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Client error: {str(e)}")
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
```

### 6. Lambdaに適切なロールを設定

1. **Lambda関数**の詳細ページに移動します。
2. **「アクセス権限」**タブに移動し、**「ロール」**を設定します。
3. 既存のロールを選択するか、新しいロールを作成し、以下のポリシーを設定します。

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
                "arn:aws:s3:::ogiri-images-bucket",
                "arn:aws:s3:::ogiri-images-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:GetItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/OgiriResultsTable"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": "arn:aws:sagemaker:us-east-1:123456789012:endpoint/ogiri-endpoint"
        }
    ]
}
```

### 7. CloudFrontの設定

1. **CloudFrontサービス**に移動します。
2. **「ディストリビューションの作成」**をクリックします。
3. **「オリジン」**タブで、新しいオリジンを追加します。
   - **オリジンタイプ**：API Gateway
   - **ドメイン名**：API GatewayのエンドポイントURL
4. **「キャッシュビヘイビア」**タブで、新しいビヘイビアを追加します。
   - **パスパターン**：`/upload*`
   - **キャッシュポリシー**：No-Cacheを選択します。
5. **「作成」**をクリックします。

### 8. テストと検証

1. **Postman**などのAPIテストツールを使用して、API Gatewayのエンドポイントに画像をPOSTします。
2. 画像をPOSTした際に、SageMakerモデルが呼び出され、結果が返され、DynamoDBに画像と結果が保存されることを確認します。

### 補足

- **同じ画像に対するリクエストの処理**：DynamoDBの`put_item`メソッドは既存の項目を上書きするため、同じキーでリクエストされた場合でも問題ありません。
- **同時リクエストの処理**：API GatewayとLambdaの組み合わせは高いスケーラビリティを持っており、同時リクエストの処理に耐えられます。

以上の手順で、指定されたユースケースをAWSのUIで構築できます。

Route 53を使用することで、APIのドメイン管理や統一が容易になります。以下に、Route 53を使用してAPIのドメインを設定する手順を示します。

### Route 53を使用したドメイン設定手順

#### 1. ドメインの登録または移管

1. **Route 53サービス**に移動します。
2. 左側メニューの「**ドメインの登録**」をクリックします。
3. 新しいドメインを登録するか、既存のドメインをRoute 53に移管します。

#### 2. ホストゾーンの作成

1. **Route 53コンソール**に移動します。
2. 左側メニューの「**ホストゾーン**」をクリックします。
3. **「ホストゾーンの作成」**をクリックします。
4. ドメイン名を入力し、**「パブリックホストゾーン」**を選択して作成します。

#### 3. CloudFrontディストリビューションとカスタムドメインの設定

1. **CloudFrontサービス**に移動します。
2. 作成済みのディストリビューションを選択し、**「ディストリビューション設定」**をクリックします。
3. **「代替ドメイン名 (CNAME)」**にカスタムドメイン名を入力します（例: `api.example.com`）。
4. SSL/TLS証明書を選択またはリクエストします。無料のAWS Certificate Manager (ACM)を使用できます。

#### 4. Route 53でエイリアスレコードを作成

1. **Route 53コンソール**に戻ります。
2. ホストゾーンのリストから作成したホストゾーンを選択します。
3. **「レコードセットの作成」**をクリックします。
4. レコードタイプを**「A – IPv4 アドレス」**または**「AAAA – IPv6 アドレス」**に設定し、**「エイリアス」**を**「はい」**に設定します。
5. **「エイリアス先」**にCloudFrontディストリビューションを選択します。
6. **「作成」**をクリックします。

### APIのドメイン統一と追加APIの設定

今後、他のAPIを追加する場合も同じドメインを使用することができます。新しいAPIを追加する手順は以下の通りです。

#### 1. API Gatewayで新しいAPIを作成

1. **API Gatewayサービス**に移動します。
2. **「REST APIの作成」**をクリックします。
3. APIの名前と説明を入力します。
4. **「作成」**をクリックします。

#### 2. 新しいリソースとメソッドを作成

1. **リソースの作成**：
   - **「アクション」**メニューから**「リソースの作成」**を選択します。
   - リソース名を入力し、**「リソースパス」**にパスを設定します（例: `/newapi`）。
2. **メソッドの作成**：
   - 作成したリソースを選択し、**「アクション」**メニューから**「メソッドの作成」**を選択します。
   - メソッドタイプ（例: `GET`）を選択し、**「チェックマーク」**をクリックします。
   - 統合タイプを**「Lambda関数」**に設定し、Lambda関数の名前を入力します。
   - **「保存」**をクリックします。

#### 3. APIキーの設定

新しいAPIについても、既存のAPIキーとUsage Planを再利用できます。

#### 4. CloudFrontで新しいビヘイビアを追加

1. **CloudFrontサービス**に移動します。
2. 既存のディストリビューションを選択し、**「キャッシュビヘイビア」**タブで**「ビヘイビアの追加」**をクリックします。
3. パスパターン（例: `/newapi*`）を設定し、API Gatewayエンドポイントをオリジンとして指定します。
4. **「保存」**をクリックします。

### まとめ

Route 53を使用してカスタムドメインを設定することで、APIのドメイン管理が容易になり、統一されたドメインで複数のAPIを提供することができます。また、APIキーの使用により、セキュリティも強化されます。

以上の手順を実施することで、外部のアプリから画像をポストし、モデルを使って検証結果を返し、データベースに保存するAPIを構築し、将来的に他のAPIを追加する際も同じドメインを使用することができます。
