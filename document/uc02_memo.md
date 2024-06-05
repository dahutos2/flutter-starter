## UC02 画像をアップロードして結果の文字列を取得する
### 1. IAM ポリシーの作成
#### 手順:
 
1. **AWS マネジメントコンソール**にログインし、**IAM**ダッシュボードに移動します。
2. 左側のメニューから「**ポリシー**」を選択し、「**ポリシーを作成**」ボタンをクリックします。
3. **JSON**タブを選択し、以下のポリシーを貼り付けます:
 
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
                "arn:aws:s3:::ogiri-images-bucket",
                "arn:aws:s3:::ogiri-images-bucket/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
            ],
            "Resource": "arn:aws:dynamodb:ap-northeast-1:765231401377:table/OgiriResultsTable"
        },
{
            "Effect": "Allow",
            "Action": "rekognition:DetectLabels",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Resource": "arn:aws:sagemaker:ap-northeast-1:765231401377:endpoint/ogiri-endpoint"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-northeast-1:765231401377:log-group:/aws/lambda/OgiriImageProcessing:*"
            ]
        }
    ]
}
```
 
</details>
 
4. 「**次のステップ: タグ**」をクリックし、任意のタグを追加します（省略可能）。
5. 「**次のステップ: 確認**」をクリックし、ポリシーに名前（例: `LambdaOgiriImageProcessingPolicy`）と説明を入力して「**ポリシーの作成**」をクリックします。

### 2. IAM ロールの作成
#### 手順:
 
1. IAM ダッシュボードの左側のメニューから「**ロール**」を選択し、「**ロールを作成**」ボタンをクリックします。
2. 「**信頼されたエンティティのタイプを選択**」画面で「**AWS サービス**」を選択し、「**Lambda**」を選択します。「**次のステップ**」をクリックします。
3. 先ほど作成したポリシー（`LambdaOgiriImageProcessingPolicy`）を検索し、選択して「**次のステップ**」をクリックします。
4. ロールに名前（例: `LambdaOgiriImageProcessingRole`）を付けて「**ロールの作成**」をクリックします。
 
### 3. S3バケットの作成
#### 手順:
1. AWSマネジメントコンソールにログインします。
2. 「**S3**」サービスに移動します。
3. 「**バケットを作成**」をクリックします。
4. バケット名を入力します（例：`ogiri-images-bucket`）。
5. 他の設定はデフォルトのままにし、「**バケットを作成**」をクリックします。

### 4. CloudFrontの設定
#### 4.1. ディストリビューションの作成
1. AWSマネジメントコンソールで「**CloudFront**」サービスに移動します。
2. 「**新しいディストリビューションの作成**」をクリックし、「Web」ディストリビューションを選択します。
3. 以下のオリジン設定を行います。
   - **Origin Domain Name**: S3バケットのドメイン名（`ogiri-images-bucket.s3.amazonaws.com`）を入力します。
     - **説明**: CloudFrontがコンテンツを取得するオリジンサーバーのドメイン名を指定します。
     - **理由**: S3バケットのドメイン名を指定することで、CloudFrontがS3バケット内のコンテンツをキャッシュし、<br>
     配信することができます。例として{YOUR_BUCKET_NAME}.s3.amazonaws.comとします。
   - **Restrict Bucket Access**: 「**No**」を選択します。
     - **説明**: S3バケットへのアクセスをCloudFront経由に限定するかどうかを指定します。
     - **理由**: 「**No**」を選択することで、S3バケットがパブリックアクセスを許可するように設定されている場合に、CloudFrontが直接アクセスできます。<br>
     今回のサービスでは、設定が簡単でパブリックアクセスを前提としているため、「**No**」を選択します。
   - **Origin ID**: 自動生成されたIDを使用します。
     - **説明**: オリジンを識別する一意のIDを指定します。
     - **理由**: CloudFrontがオリジンを識別するために必要な情報です。<br>
     自動生成されたIDを使用することで、一意性が保証されます。
4. 以下のデフォルトキャッシュ動作の設定を行います。
   - **Viewer Protocol Policy**: 「**Redirect HTTP to HTTPS**」を選択します。
     - **説明**: クライアントがどのプロトコルでCloudFrontにアクセスするかを制御します。
     - **理由**: 「**Redirect HTTP to HTTPS**」を選択することで、すべてのHTTPリクエストをHTTPSにリダイレクトし、通信の安全性を確保します。
   - **Allowed HTTP Methods**: 「**GET, HEAD**」を選択します。
     - **説明**: CloudFrontが許可するHTTPメソッドを指定します。
     - **理由**: 「**GET, HEAD**」を選択することで、主に静的コンテンツの配信に使用されるHTTPメソッドのみを許可し、セキュリティを強化します。
   - **Cache Based on Selected Request Headers**: 「**None**」を選択します。
     - **説明**: CloudFrontがリクエストヘッダーに基づいてキャッシュを制御するかどうかを指定します。
     - **理由**: 「**None**」を選択することで、リクエストヘッダーに基づくキャッシュ制御を行わず、<br>
     キャッシュの一貫性を保ちます。これは、シンプルなキャッシュ設定を希望する場合に有効です。
   - **Object Caching**: 「**Use Origin Cache Headers**」を選択します。
     - **説明**: オリジンのキャッシュヘッダーに基づいてオブジェクトをキャッシュするかどうかを指定します。
     - **理由**: 「**Use Origin Cache Headers**」を選択することで、<br>
     オリジン（S3バケット）のキャッシュヘッダー設定を尊重し、キャッシュの管理を柔軟に行います。
5. 以下のディストリビューション設定を行います。
   - **Price Class**: 「**Use Only U.S., Canada, and Europe**」を選択します。
     - CloudFrontが使用するエッジロケーションの範囲を指定します。
     - このオプションは、U.S., Canada, Europeのエッジロケーションを使用します。<br>
     これにより、特定の地域（日本含む）だけでの配信が可能になります。<br>
     すべてのエッジロケーションを使用する場合は、「**Use All Edge Locations**」を選択します。
   - **Alternate Domain Names (CNAMEs)**: ここは空のままにします。
     - **説明**: CloudFrontディストリビューションに対する代替ドメイン名を指定します。
     - **理由**: 空のままにすることで、デフォルトのCloudFrontドメイン名を使用し、設定を簡素化します。
   - **SSL Certificate**: 「**Default CloudFront Certificate (CloudFront domain name)**」を選択します。
     - **説明**: CloudFrontディストリビューションに対するSSL証明書を指定します。
     - **理由**: 「**Default CloudFront Certificate (CloudFront domain name)**」を選択することで、<br>
     CloudFrontのデフォルトドメイン名用のSSL証明書を使用し、HTTPS通信を容易に実装できます。
   - **Default Root Object**: 必要に応じて設定します（例：`index.html`）
     - **説明**: クライアントがルートURLにアクセスしたときに返すデフォルトのオブジェクトを指定します。
     - **理由**: 必要に応じて設定します（例：index.html）。これにより、特定のページを表示させることができます。
6. 「**ディストリビューションの作成**」をクリックして、ディストリビューションを作成します。

#### 4.2. CloudFrontディストリビューションの情報の取得
1. 新しいディストリビューションが作成されたら、ディストリビューションのリストが表示されます。
2. 各ディストリビューションの「**ID**」列にディストリビューションIDが表示されています。これをS3のポリシーで使用しますのでコピーします。 
1. リストから今回作成したリディストリビューションを選択します。
2. 「**Distribution Settings**」ページで「**Domain Name**」フィールドに記載されているCloudFrontドメイン名（例：`d123456abcdef8.cloudfront.net`）をコピーします。

### 5. S3バケットポリシーの設定
#### 手順:
1. AWSマネジメントコンソールで「**S3**」サービスに移動します。
2. [3](#3-s3バケットの作成)で作成した、`ogiri-images-bucket`の詳細ページに移動します。
3. S3コンソールの「**Permissions**」タブから「**Bucket Policy**」を編集します。
4. 以下のポリシーを追加します。

<details><summary>詳細を開く</summary>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::ogiri-images-bucket/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::765231401377:distribution/{YOUR_CLOUD_FRONT_DISTRIBUTION_ID}"
                }
            }
        }
    ]
}
```

</details>

### 6. DynamoDB テーブルの作成
 
#### 手順:
 
1. **DynamoDB**ダッシュボードに移動し、「**テーブルを作成**」をクリックします。
2. テーブル名を入力します（例: `OgiriResultsTable`）。
3. プライマリキー(**パーティションキー**)として「**ImageKey**」（タイプ：文字列）を設定します。
4. 「**テーブルの作成**」をクリックします。

### 7. Lambda 関数の作成
#### 手順
1. **Lambda関数の作成**：
    - Lambdaダッシュボードに移動し、「関数の作成」をクリックします。
    - 「一から作成」を選択し、関数名（例: `OgiriImageProcessing`）を入力し、ランタイムをPython 3.8に設定します。
    - 実行ロールには「既存のロールを使用する」を選択し、`LambdaOgiriImageProcessingRole`を選択します。
    - 「関数の作成」をクリックします。
 
2. **Lambda関数にコードを追加**：
 
<details><summary>詳細をクリック</summary>
 
```python
import json
import boto3
import base64
from botocore.exceptions import ClientError
import logging

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
rekognition = boto3.client('rekognition')
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
        
        # S3のURLを生成
        cloudfront_domain = 'your-cloudfront-domain.cloudfront.net'
        image_url = f"https://{cloudfront_domain}/{image_key}"
        
        # Rekognitionを使用して画像を分析
        rekognition_response = rekognition.detect_labels(
            Image={'S3Object': {'Bucket': bucket_name, 'Name': image_key}},
            MaxLabels=10
        )
        labels = [label['Name'] for label in rekognition_response['Labels']]
        
        # SageMakerエンドポイントを呼び出して予測
        sagemaker_input = {
            "image": base64.b64encode(image_data).decode('utf-8'),
            "labels": labels
        }
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName='ogiri-endpoint',
            ContentType='application/json',
            Body=json.dumps(sagemaker_input)
        )
        
        result = json.loads(response['Body'].read().decode())
        
        # DynamoDBに保存
        table = dynamodb.Table('OgiriResultsTable')
        table.put_item(
            Item={
                'ImageKey': image_key,
                'ImageUrl': image_url,
                'Result': result
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'結果': result})
        }
        
    except ClientError as e:
        logger.error(f"クライアントエラー: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"クライアントエラー: {str(e)}")
        }
    except Exception as e:
        logger.error(f"予期せぬ例外: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"予期せぬ例外: {str(e)}")
        }
```

</details>
 
### 8. API Gateway設定手順

1. **API Gatewayコンソールにアクセス**
  - AWSマネジメントコンソールで「**API Gateway**」サービスに移動します。

2. **新しいREST APIの作成**
  - 「**Create API**」をクリックし、「**REST API**」を選択します。
    - 「**New API**」を選択し、以下の情報を入力します。
      - **API Name**: `OgiriImageProcessingAPI`
        - APIの識別名。わかりやすく一意な名前を設定します。
    - **Description**: `API for processing Ogiri images`
      - APIの説明。後で何のためのAPIかを理解しやすくするための説明です。
    - **Endpoint Type**: `Regional`
      - ローバルエンドポイントも設定できますが、特定のリージョンでホストしたい場合に`Regional`を選びます。
  - 「**Create API**」をクリックします。

3. **リソースとメソッドの設定**
  - 左側の「**Resources**」をクリックし、「**Actions**」から「**Create Resource**」を選択します。
  - **Resource Name**: `result`
    - APIリソースの名前。リクエストURLに含まれる一部です。
  - **Resource Path**: `/result`
    - APIリソースのパス。リクエストURLに使用されます。
  - 「**Create Resource**」をクリックします。
  - `/images`を選択した状態で、「**Actions**」から「**Create Method**」を選択し、`POST`を選択します。
  - 「チェックマーク」をクリックします。

4. **統合タイプの設定**
  - **Integration type**: `Lambda Function`
  - **Use Lambda Proxy integration**: チェックを入れる
    - Lambdaプロキシ統合を使用することで、Lambda関数にリクエストの詳細情報をそのまま渡します。
  - **Lambda Region**: Lambda関数がデプロイされているリージョン(`ap-northeast-1`)を選択します。
  - **Lambda Function**: `OgiriImageProcessing`（Lambda関数の名前）を選択します。
  - 「**Save**」をクリックし、API GatewayがLambda関数にアクセスできるように権限を付与します。

5. **APIをデプロイ**
  - 作成したAPI（例：`OgiriImageProcessingAPI`）を選択します。
  - 左のナビゲーションペインで「**アクション**」をクリックし、「**APIをデプロイ**」を選択します。
  - 「**デプロイメントステージ**」ドロップダウンメニューで「**新しいステージ**」を選択します。
  - 以下の設定を行います：
    - **ステージ名**: `prod`
    - **説明**: `Production environment`
    - **バージョン説明**: `Initial deployment`
  - 必要に応じて、ステージでキャッシュを有効にする設定を行います。
    - キャッシュを有効にすることで、レスポンス時間を短縮できます。ただし、デフォルト設定で問題ない場合はスキップしても構いません。
  - ステージの設定でCloudWatchログを有効にします
    - **CloudWatchログの有効化**: はい
    - **ログレベル**: `INFO` または `ERROR`
    - **データトレースの有効化**: 必要に応じて有効にします（パフォーマンスに影響する可能性があるため、通常はオフにします）。
  - ステージ変数を定義します。
    - 変数名: `ENV`
    - 値: `prod`
  - 「**デプロイ**」ボタンをクリックしてAPIをステージにデプロイします

6. **APIキーの設定**
  - 左側の「**API Keys**」をクリックし、「**Create API Key**」を選択します。
  - **API Key Name**: `OgiriImageProcessingKey`
    - APIキーの識別名。後でどのキーがどの用途に使われているかを特定するために設定設定します。
  - **API Key**: 自動生成されたキーまたはカスタムキーを使用
    - 自動生成されたキーを使うことで安全性を確保しますが、カスタムキーを使っても構いません。
  - 「**Save**」をクリックします。
  - 「**Actions**」から「**Create Usage Plan**」を選択します。
    - **Name**: `OgiriUsagePlan`
      - 使用プランの名前。わかりやすく一意な名前を設定します。
    - **Throttle**: `Rate: 10 requests per second`, `Burst: 2`
      - APIのスロットリング設定。APIの過負荷を防ぐためのレート制限です。
    - **Quota**: 必要に応じて設定（例：`5000 requests per month`）
      - 月間のリクエスト数の上限。無料利用枠やコスト管理のために設定します。
  - 「**Next**」をクリックし、「**Add API Stage**」を選択
    - **API**: 作成したAPI(`OgiriImageProcessingAPI`)を指定します。
    - **Stage**: `prod`（事前に作成したステージ）
      - ステージを選択します。プロダクション環境用に設定します。
  - 「**Add**」をクリックし、「**Next**」をクリックし、「**Create Usage Plan**」をクリックします。
  - 「**API Keys**」タブで、`OgiriImageProcessingKey`を選択し、「**Add to Usage Plan**」をクリックし、`OgiriUsagePlan`を選択します。

### 9. CloudFront設定手順

1. **CloudFrontコンソールにアクセス**
  - AWSマネジメントコンソールで「**CloudFront**」サービスに移動します。

2. **新しいディストリビューションの作成**
  - 「**Create Distribution**」をクリックします。
  - **Web**を選択します。

3. **オリジン設定**
  - **Origin Domain Name**: APIのドメイン名（`{YOUR_API_ID}.execute-api.ap-northeast-1.amazonaws.com`）を入力します。
    - API Gatewayのデフォルトエンドポイントを指定することで、CloudFrontを介してAPI Gatewayにリクエストをルーティングします。
  - **Restrict Bucket Access**: `No`
    - 今回はAPI Gatewayをオリジンとして使用するため、バケットアクセス制限は不要です。
  - **Origin ID**: 自動生成されたIDを使用します。
    - オリジンの識別IDを自動生成させます。

4. **デフォルトキャッシュ動作の設定**
  - **Viewer Protocol Policy**: `Redirect HTTP to HTTPS`
    - セキュリティのため、すべてのHTTPリクエストをHTTPSにリダイレクトします。
  - **Allowed HTTP Methods**: `GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE`
    - API GatewayがサポートするすべてのHTTPメソッドを許可し、完全なAPI操作を可能にします。
  - **Cache Based on Selected Request Headers**: `All`
    - リクエストヘッダーに基づいてキャッシュを制御し、動的なコンテンツのキャッシュ制御を行います。
  - **Object Caching**: `Use Origin Cache Headers`
    - オリジン（API Gateway）で指定されたキャッシュヘッダーを使用してキャッシュ動作を制御します。

5. **ディストリビューション設定**
  - **Price Class**: `Use Only US, Canada, Europe and Asia`
    - 日本向けの配信が主なため、US, カナダ、ヨーロッパのエッジロケーションを使用します。
  - **Alternate Domain Names (CNAMEs)**: 空のままにします。
    - 独自ドメインを使用しないため、このフィールドは空にします。
  - **SSL Certificate**: `Default CloudFront Certificate (CloudFront domain name)`
    - CloudFrontのデフォルト証明書を使用してHTTPSを提供します。
  - **Default Root Object**: 空のままにします。
    - デフォルトルートオブジェクトが不要なため空にします。

6. **ディストリビューションの作成**
  - 「**Create Distribution**」をクリックします。

### 10. batファイルの作成

以下の内容で`call_api.bat`ファイルを作成します。

<details><summary>詳細をクリック</summary>

```bat
@echo off
set /p imagePath="Enter the path to the image file: "
set /p fileName="Enter the file name to save as: "
set /p apiKey="Enter your API Key: "

:: Convert image to base64
for /f "delims=" %%A in ('certutil -encode %imagePath% temp.b64 ^& findstr /v /c:- temp.b64') do set base64Image=%%A

:: Define the API URL
set apiUrl=https://{YOUR_API_ID}.execute-api.ap-northeast-1.amazonaws.com/prod/result

:: Send the request
curl -X POST %apiUrl% -H "x-api-key: %apiKey%" -H "Content-Type: application/json" -d "{\"image\": \"%base64Image%\", \"filename\": \"%fileName%\"}"

:: Clean up
del temp.b64
pause
```

</details>

#### バッチファイルの処理順序と役割

1. **バッチファイルの実行**
   - バッチファイルをダブルクリックして実行します。
   - `@echo off`:
     - **役割**: コマンドのエコーをオフにして、バッチファイルのコマンドがコンソールに表示されないようにします。

2. **ユーザー入力の促進**
   - `set /p imagePath="Enter the path to the image file: "`
     - **役割**: ユーザーに画像ファイルのパスを入力させます。
   - `set /p fileName="Enter the file name to save as: `
     - **役割**: ユーザーにファイル名を入力させます。
   - `set /p apiKey="Enter your API Key: "`
     - **役割**: ユーザーにAPIキーを入力させます。

3. **画像ファイルのBase64エンコード**
   - `for /f "delims=" %%A in ('certutil -encode %imagePath% temp.b64 ^& findstr /v /c:- temp.b64') do set base64Image=%%A`
       - `certutil -encode %imagePath% temp.b64`:
         - **役割**: 指定された画像ファイルをBase64形式にエンコードし、一時ファイル`temp.b64`に保存します。
       - `findstr /v /c:- temp.b64`:
         - **役割**: `temp.b64`から不要な行を削除し、エンコードされた画像データを抽出します。
       - `set base64Image=%%A`:
         - **役割**: エンコードされた画像データを環境変数`base64Image`に設定します。

4. **API URLの設定**
   - `set apiUrl=https://api.example.com/result`
     - **役割**: APIのエンドポイントURLを設定します。

5. **APIリクエストの送信**
   - `curl -X POST %apiUrl% -H "x-api-key: %apiKey%" -H "Content-Type: application/json" -d "{\"image\": \"%base64Image%\", \"filename\": \"%fileName%\"}" `
     - **役割**:
       - `curl -X POST %apiUrl%`:
         - **役割**: APIのエンドポイントに対してHTTP POSTリクエストを送信します。
       - `-H "x-api-key: %apiKey%"`:
         - **役割**: リクエストヘッダーにAPIキーを追加します。
       - `-H "Content-Type: application/json"`:
         - **役割**: リクエストのContent-TypeをJSONに設定します。
       - `-d "{\"image\": \"%base64Image%\", \"filename\": \"%fileName%\"}" `:
         - **役割**: リクエストボディに画像データ（Base64エンコード）とファイル名をJSON形式で含めます。

6. **一時ファイルの削除**
   - `del temp.b64`
     - **役割**: エンコードされた画像データが保存された一時ファイル`temp.b64`を削除します。
