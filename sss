IT2（コンテナ間結合テスト）実施手順書

対象機能：画像OCR妥当性チェック・名前カナ相関チェック
対象環境：tes-v2（DXSuiteはMock）
作成：楊（2026/11/02）

0. 前提・準備

項目	内容
AWSアカウント	tes（203918878188）
ロール	a-nimo-dv-tn-afid-T-DevOpsRole（S3・CloudWatch・Secrets Manager・RDS）
リージョン	東京（ap-northeast-1）
作業端末	devEc2（VS Code Remote SSH）
投入バケット	dcl-pngn-tes-v2-receipt-icc
結果バケット	dcl-pngn-tes-v2-mid-file（scan/st/ 配下）
Mock	http://mock-api-service.tes-v2.dcl-pngn/it2/designation_dxsuite_case

	•	Mockのケース設定は全員共通のため、切替前後にTeamsで周知する。
	•	試験後は必ずMockを 1000_0 に戻す。

1. テストデータ

1-1. 構成

	•	投入ZIP：it2_work/input_zip/（EC2上）。ファイル名末尾2桁＝ケース番号（例：…0014.zip＝C14）
	•	Mock応答JSON：mock-api-service の app/src/dxsuite/it2/data/7026/Cxx.json
	•	画像：mock-api-service の test_images/。ケースと画像の対応は CASE_IMAGE_MAPPING で定義

1-2. 投入ZIPの作り方

	•	ZIPの中身は「画像」と「同名の.lst」をフォルダに入れず直接格納する。
	•	.lst の形式
	•	UTF-8、タブ区切り、1画像1行（請求単位情報／FormID／画像ファイル名）
	•	FormID：INV帳票は 7026（画像05は7027）
	•	最終行の末尾に改行を入れない（改行があると取り込まれない）
	•	複数画像を1ZIPにする場合、請求単位情報の日時（秒）を行ごとに連番にする
	•	ZIP名と.lst名は同一にする。同名ZIPの再投入でも処理される。
	•	画像ファイル名は既存形式（例：X9990000101X1.jpg、13桁）に合わせる。

2. 実施手順（1ケースごと）

2-1. Mockケースを切り替える（devEc2のターミナル）

curl -X POST http://mock-api-service.tes-v2.dcl-pngn/it2/designation_dxsuite_case/C01
curl http://mock-api-service.tes-v2.dcl-pngn/it2/designation_dxsuite_case

	•	GETの結果がケース名であることを確認し、画面キャプチャを証跡として保存。
	•	URLは引用符なしで入力する（引用符の閉じ忘れ・全角化を防ぐため）。

2-2. ZIPを投入する

	•	S3 dcl-pngn-tes-v2-receipt-icc にZIPをアップロードし、投入時刻を記録する。
	•	アップロード後すぐに取り込まれる（バケットから消える）。

2-3. 処理開始を確認してから次のケースへ

	•	CloudWatch ログ分析で zip_id を含むログが出たことを確認してから、次のケースのMockに切り替える。
	•	確認前に切り替えると、前のケースが次のケースのOCR結果で処理される（実績：C13とC15の結果が同一になった）。
	•	目安：1ケースあたり3分程度待つ。

2-4. 全ケース終了後

curl -X POST http://mock-api-service.tes-v2.dcl-pngn/it2/designation_dxsuite_case/1000_0

	•	Teamsで「Mockを1000_0に戻しました」と周知。

3. 結果の取得

3-1. 中間ファイルのパスをDBで確認

devEc2で psql を使用（初回のみ sudo dnf install -y postgresql15）。

psql -h dcl-pngn-tes-v2-common-db.cxoo2u2gyu4n.ap-northeast-1.rds.amazonaws.com -U root -d common

	•	パスワードは Secrets Manager の rds!db-… から取得（画面キャプチャを撮らない）。
	•	テーブルは ap1 スキーマにあるため、接続後に以下を実行する。

set search_path to ap1, public;

	•	参照のみ（select）とし、update／delete等は実行しない。
	•	結果パスの取得SQLは打鍵手順書3-1を参照。

3-2. .res をダウンロード

	•	S3 dcl-pngn-tes-v2-mid-file → scan/st/ → 「プレフィックスで検索」にパスの先頭を入力してEnter。
	•	.res（必要に応じて _AI.chu）をダウンロードし、C01.res のようにケース名へリネーム。

3-3. .res の確認

	•	.res は2行目が判定値（0：正常、1：ユーザー修正、2：既存のAI疑義、3：新機能の疑義）。
	•	確認位置：口座番号42／記号43／通帳番号44／患者名カナ・漢字7・8／受取人22・25／名義人28・30
	•	複数ファイルはPowerShellで一括集計（ファイルを置いたフォルダでPowerShellを開いて実行）。

Get-ChildItem -Recurse -Filter *.res | Sort-Object FullName | ForEach-Object {
  $f = (Get-Content $_.FullName -Encoding UTF8)[1] -split "`t"
  $t = @(); for ($i = 0; $i -lt $f.Count; $i++) { if ($f[$i] -ne '0' -and $f[$i] -ne '') { $t += "$($i+1)=$($f[$i])" } }
  "$($_.Directory.Name)  $($_.Name)  42=[$($f[41])]  " + ($t -join '  ')
}

	•	判定は必ずテストケース表の期待結果列と照合する（記憶で判断しない）。

4. ログ確認（CloudWatch ログ分析）

ロググループ：/ecs/dcl-pngn/tes-v2/st-mid-file-create-process など

確認内容	フィルター文字列
処理開始（zip_id）	zip_id
画像OCRチェックの実行	OCR image verification
名前カナ相関チェックの実行	Name correlation LLM request count summary
LLM応答の形式不正（判定破棄）	response format is invalid
判定不能	undetermined

	•	下部の「テーブル結果をフィルタリング」は表示中の最大1万件のみが対象。過去分を探す場合はクエリ本文に filter @message like /…/ を書く。
	•	日時を指定する場合、クエリ内の START=…Z はUTC（日本時間−9時間）。

5. Mock修正の反映手順

	1.	devEc2で mock-api-service を最新化し、作業ブランチを作成

cd ~/workspace/mock-api-service
git fetch origin
git checkout -b feature/xxxx origin/v2/pngn/release

	2.	JSON・画像・CASE_IMAGE_MAPPING を修正。値を変えた場合は tests/ の期待値も合わせて修正。
	3.	git diff --stat で変更ファイルを確認 → git add -A → git commit → git push -u origin feature/xxxx
	4.	GitLabでMRを作成。Target branch が v2/pngn/release（またはdevelop）になっていることを必ず確認（初期値が v1/pngn/develop になっている）。Commits・Changes の数も確認。
	5.	Merge後、Jenkinsで mock-api-service の v2/pngn/release のビルドが成功していることを確認。

6. 証跡

保存先：ケースごとにフォルダを作成

証跡	内容
Mock切替	GET結果の画面キャプチャ
投入	投入ZIP、投入時刻
結果	.res、_AI.chu
ログ	該当ログ（zip_id・判定結果）の画面キャプチャ

7. つまずいた点・注意事項
