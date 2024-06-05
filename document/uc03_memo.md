## UC03 画像の URL と結果の文字列の一覧を表示する

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
      "Action": ["dynamodb:Scan"],
      "Resource": "arn:aws:dynamodb:ap-northeast-1:765231401377:table/OgiriResultsTable"
    },
    {
      "Effect": "Allow",
      "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
      "Resource": "arn:aws:logs:ap-northeast-1:765231401377:log-group:/aws/lambda/*"
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
3. 先ほど作成したポリシー（`LambdaOgiriGetResultsPolicy`）を検索し、選択して「**次のステップ**」をクリックします。
4. ロールに名前（例: `LambdaOgiriGetResultsRole`）を付けて「**ロールの作成**」をクリックします。

### 3. Lambda 関数の作成

#### 手順

1. **Lambda 関数の作成**：
 
   - Lambda ダッシュボードに移動し、「関数の作成」をクリックします。
   - 「一から作成」を選択し、関数名（例: `OgiriGetResults`）を入力し、ランタイムを Python 3.8 に設定します。
   - 実行ロールには「既存のロールを使用する」を選択し、`LambdaOgiriGetResultsRole`を選択します。
   - 「関数の作成」をクリックします。

2. **Lambda 関数にコードを追加**：

<details><summary>詳細をクリック</summary>

```python
import json
import boto3
import logging

# CloudWatch Logsの設定
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        table_name = 'OgiriResultsTable'
        table = dynamodb.Table(table_name)

        # DynamoDBから全てのデータを取得
        response = table.scan()

        if 'Items' in response:
            results = response['Items']
            return {
                'statusCode': 200,
                'body': json.dumps(results)
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'message': 'No data found'})
            }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Unexpected error: {str(e)}")
        }
```

</details>

### 4. API Gateway 設定手順

次に、API Gateway でこの Lambda 関数を呼び出すための API エンドポイントを設定します。

#### 手順

1. **API Gateway コンソールにアクセス**

   - AWS マネジメントコンソールで「**API Gateway**」サービスに移動します。

2. **既存の REST API にリソースを追加**

   - 先ほど作成した API（例：`OgiriImageProcessingAPI`）を選択します。
   - 左側の「**Resources**」をクリックし、「**Actions**」から「**Create Resource**」を選択します。
   - **Resource Name**: `results`
     - API リソースの名前。リクエスト URL に含まれる一部です。
   - **Resource Path**: `/results`
     - API リソースのパス。リクエスト URL に使用されます。
   - 「**Create Resource**」をクリックします。
   - `/results`を選択した状態で、「**Actions**」から「**Create Method**」を選択し、`GET`を選択します。
   - 「チェックマーク」をクリックします。

3. **統合タイプの設定**

   - **Integration type**: `Lambda Function`
   - **Use Lambda Proxy integration**: チェックを入れる
     - Lambda プロキシ統合を使用することで、Lambda 関数にリクエストの詳細情報をそのまま渡します。
   - **Lambda Region**: Lambda 関数がデプロイされているリージョン(`ap-northeast-1`)を選択します。
   - **Lambda Function**: `OgiriGetResults `（新しく作成した Lambda 関数の名前）を選択します。
   - 「**Save**」をクリックし、API Gateway が Lambda 関数にアクセスできるように権限を付与します。

4. **API をデプロイ**

   - 作成した API（例：`OgiriImageProcessingAPI`）を選択します。
   - 左のナビゲーションペインで「**アクション**」をクリックし、「**API をデプロイ**」を選択します。
   - 「**デプロイメントステージ**」ドロップダウンメニューで「**prod**」を選択します。
   - 「**デプロイ**」ボタンをクリックして API をステージにデプロイします。

5. **API キーの設定**
   - すでに作成した API キー（例：`OgiriImageProcessingKey`）を使用できます。
   - 左側の「**API Keys**」をクリックし、既存の API キーを選択します。
   - 「**Usage Plans**」タブで、「**Add to Usage Plan**」をクリックし、`OgiriUsagePlan`を選択します。

### 5. CloudFront 設定手順

すでに設定済みの CloudFront ディストリビューションに API Gateway の新しいリソースを追加します。

#### 手順

1. **CloudFront コンソールにアクセス**

   - AWS マネジメントコンソールで「**CloudFront**」サービスに移動します。

2. **既存のディストリビューションの設定を更新**

   - 作成した CloudFront ディストリビューションを選択します。

3. **キャッシュ動作の設定を更新**

   - 左側の「**Behaviors**」タブをクリックし、「**Create Behavior**」を選択します。
   - **Path Pattern**: `/prod/results`
     - このパスに一致するリクエストを処理します。
   - **Viewer Protocol Policy**: `Redirect HTTP to HTTPS`
     - セキュリティのため、すべての HTTP リクエストを HTTPS にリダイレクトします。
   - **Allowed HTTP Methods**: `GET, HEAD`
     - API Gateway がサポートする HTTP メソッドを許可します。
   - **Cache Based on Selected Request Headers**: `All`
     - リクエストヘッダーに基づいてキャッシュを制御し、動的なコンテンツのキャッシュ制御を行います。
   - **Object Caching**: `Use Origin Cache Headers`
     - オリジン（API Gateway）で指定されたキャッシュヘッダーを使用してキャッシュ動作を制御します。

4. **設定の保存**
   - 「**Save**」をクリックして設定を保存します。

### 6. 呼び出し用の bat ファイル

最後に、API を呼び出すためのバッチファイルを作成します。

#### バッチファイルの内容

```batch
@echo off
set API_KEY=YOUR_API_KEY
set API_URL=https://YOUR_API_ID.execute-api.ap-northeast-1.amazonaws.com/prod/results

curl -X GET %API_URL% -H "x-api-key: %API_KEY%" -o result.json

echo API Response:
type result.json
pause
```