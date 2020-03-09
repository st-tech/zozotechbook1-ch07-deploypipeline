## 本番ネットワークとデプロイパイプラインの構築
CloudFormationを用いて構築します。<br>
https://ap-northeast-1.console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/

以下の手順では東京リージョンを利用していますが、どのリージョンでも構いません。

### ネットワークの構築
network.ymlを用いてCloudFormationスタック（以後、CFnスタック）を作成します。

1. 「新しいリソースを使用（標準）」
<img width="1326" alt="01" src="https://user-images.githubusercontent.com/10104981/76183342-6eb8f980-620b-11ea-81f4-def03f681845.png">
2. 「ファイルの選択」からnetwork.ymlをアップロードし「次へ」
<img width="1326" alt="02" src="https://user-images.githubusercontent.com/10104981/76183346-72e51700-620b-11ea-80d9-9c9a35e7bd7a.png">
3. 「スタックの名前」を入力し「次へ」
<img width="1326" alt="03" src="https://user-images.githubusercontent.com/10104981/76183349-74164400-620b-11ea-8b2b-2c8af3050f2a.png">
4. 何も変更せず「次へ」
<img width="1326" alt="04" src="https://user-images.githubusercontent.com/10104981/76183352-75477100-620b-11ea-8203-13a5735f674b.png">
5. 「AWS CloudFormationによってIAMリソースが〜」にチェックを入れて「スタックの作成」
<img width="1326" alt="05" src="https://user-images.githubusercontent.com/10104981/76183353-76789e00-620b-11ea-8687-0016dd9af2d1.png">


5分〜10分程度で、3つのAZにまたがる本番を想定したネットワークが構築されます。

### デプロイパイプラインの構築
deploypipeline.ymlを用いてCloudFormationスタックを作成します。手順はネットワークの構築と同様です。<br>
**1点。スタックの名前をつける画面で、network.ymlから作成したCFnスタックの名前を入力して下さい。**

<img width="1326" alt="06" src="https://user-images.githubusercontent.com/10104981/76183356-77a9cb00-620b-11ea-904d-302909993865.png">

5分〜10分程度で、CodePipelineを用いたデプロイパイプラインが構築されます。

## CIの準備と設定
CircleCIで利用する情報を取得し、masterブランチの内容を継続的にAWSへデリバリします。

### CircleCIに設定する情報の取得
CircleCIで利用するために、S3 Bucket名とアクセスキーをメモします。

1. deploypipeline.ymlから作成したCFnスタックを選択し「リソース」から`S3BucketCodePipelineSource`の物理ID(以後、a)をメモ
<img width="1326" alt="07" src="https://user-images.githubusercontent.com/10104981/76184679-218b5680-6210-11ea-820d-c26cd694b3a7.png">

2. [IAM Userの画面](https://ap-northeast-1.console.aws.amazon.com/iam/home?region=ap-northeast-1#/users)へ移動し、deploypipeline.ymlから作成したCFnスタックの名前で検索
<img width="1326" alt="08" src="https://user-images.githubusercontent.com/10104981/76184687-26500a80-6210-11ea-87e3-e63dcd179e2b.png">

3. 「アクセスキーの作成」にて、新しいアクセスキーを作成し、アクセスキーID(以後、b)とシークレットアクセスキー(以後、c)をメモ
<img width="1326" alt="09" src="https://user-images.githubusercontent.com/10104981/76184691-2819ce00-6210-11ea-850e-132852d4d8bb.png">

### CircleCIの設定
ここから先はCircleCIで作業します。

1. リポジトリの追加画面（※）から`zozotechbook1-ch07-deploypipeline`を「Set Up Project」<br>
（※）`https://onboarding.circleci.com/project-dashboard/github/<リポジトリをforkしたユーザ名 or Org名>`
<img width="1326" alt="10" src="https://user-images.githubusercontent.com/10104981/76190004-5eab1500-621f-11ea-94a0-e8471fc348a4.png">

2. 「Start Building」
<img width="1326" alt="11" src="https://user-images.githubusercontent.com/10104981/76190012-636fc900-621f-11ea-9a92-0770e16d12a2.png">

3. もし、Add this config to your repoのポップアップが出た場合、「Add Manually」
<img width="1326" alt="12" src="https://user-images.githubusercontent.com/10104981/76190018-64a0f600-621f-11ea-808f-374e217b52df.png">

4. 「Project Settings」
<img width="1326" alt="13" src="https://user-images.githubusercontent.com/10104981/76190024-65d22300-621f-11ea-8cb3-581310917e36.png">

5. 環境変数を設定する
<img width="1326" alt="14" src="https://user-images.githubusercontent.com/10104981/76190028-67035000-621f-11ea-9a5e-1af12fba8b61.png">
設定する環境変数は以下の4つ

| Name | Value | Example |
| --- | --- | --- |
| S3\_BUCKET\_NAME | (a)をコピー | `sample-deploy-s3bucketcodepipelinesource-yk7stq65mtv8` |
| AWS\_ACCESS\_KEY\_ID | (b)をコピー | `AKIAIOSFODNN7EXAMPLE` |
| AWS\_SECRET\_ACCESS\_KEY| (c)をコピー | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| AWS\_DEFAULT\_REGION| CFnスタックを作成したリージョン | `ap-northeast-1` |

これですべての準備は完了です。

## CDの実行
トリガーは次の2つです。

* GitHubで、マスターブランチを更新したとき
* CircleCIで、過去のパイプラインを再実行したとき


<img width="1435" alt="15" src="https://user-images.githubusercontent.com/10104981/76192126-65885680-6224-11ea-9873-2f72f2d7b99a.png">


