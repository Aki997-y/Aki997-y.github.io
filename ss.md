本番ログ確認手順（画像OCR妥当性チェック・名前カナ相関チェック）

1. 目的
・新機能（画像OCR妥当性チェック・名前カナ相関チェック）が本番で実行されていることを確認する。
・新機能に関連するエラー・警告が発生していないことを確認する。
・参照のみの作業とし、設定変更等は行わない。

2. 前提
・入口：BXO → AWSアカウントポータル
・アカウント：dcl-pngn-prd
・ロール：ReadOnlyAccess
・リージョン：アジアパシフィック（大阪）
・画面：CloudWatch → ログ分析
・ロググループ：/aws/containerinsights/dcl-pngn-prd-s-main/application

3. 手順
3-1. ログインと画面表示
（1）BXOからAWSアカウントポータルにアクセスする。
（2）dcl-pngn-prdを展開し、ReadOnlyAccessを選択してコンソールを開く。
（3）画面右上のアカウント表示がdcl-pngn-prd / ReadOnlyAccessであることを確認する。
（4）リージョンを「アジアパシフィック（大阪）」にする。
（5）CloudWatch → ログ分析を開く。

3-2. ロググループと期間の指定
（1）「ロググループ」のプルダウンから上記ロググループを選択する。
（2）期間を選択する（リリース翌朝：12h、日中の定期確認：3h）。
（3）クエリ1行目に「SOURCE …」が自動で入る。この行は残し、2行目以降にクエリを貼り付ける。

3-3. クエリ①：新機能の実行確認
filter @message like /Name correlation LLM request count summary|for OCR image verification/
| stats sum(strcontains(@message, "Name correlation LLM request count summary")) as name_cnt, sum(strcontains(@message, "for OCR image verification")) as ocr_cnt by bin(5m) as t
| sort t asc

・name_cnt：名前カナ相関チェックの実行件数
・ocr_cnt：画像OCR妥当性チェックの実行件数
・いずれかが1以上の行があれば実行されている。

3-4. クエリ②：エラー・警告の確認
filter (ispresent(log.details.error_code) or @message like /response format is invalid|judgment is undetermined/) and log.level != "INFO"
| stats count(*) as cnt, min(@timestamp) as first, max(@timestamp) as last by kubernetes.container_name, log.level, log.details.error_code, substr(log.message, 0, 60) as msg
| sort cnt desc

・「and log.level != "INFO"」を必ず付ける。本番ではINFOログにもerror_code（値はNone）が出力されるため、付けないと正常ログが大量に表示される。

4. 結果の見方
4-1. 時刻
・結果の時刻はUTC。日本時間は＋9時間（例：00:10Z → 9:10）。

4-2. 新機能に関連するログ（要確認）
・response format is invalid：LLM応答の形式不正（既存フラグを維持）→ 少数なら許容、急増時は報告
・judgment is undetermined：判定不能 → 件数を報告
・SQS_CHANGE_VISIBILITY_TIMEOUT_ERROR：SQS可視性タイムアウト → 報告
・PROXY_SERVICE_CONNECTION_ERROR／PROXY_SERVICE_RESPONSE_ERROR：プロキシ接続・応答エラー → 報告
・EXTERNAL_CONNECT_RESPONSE_ERROR（503／500）：外部接続エラー → 報告
・LLM_REQUEST_VALIDATION_ERROR：LLMリクエスト不正 → 報告（新機能が動かない可能性）

4-3. 新機能と無関係なログ（確認不要）
・token-auth-service EXPIRED_TOKEN_ERROR：トークン期限切れ（認証側の通常動作）
・alertmanager：監視系
・personal-information-delete-batch：個人情報削除バッチ
・郵便番号・住所取得失敗：既存処理

4-4. 判定
・クエリ①で実行件数あり、かつクエリ②で4-2のログがない（または少数）→ 問題なし。
・クエリ①が0件の場合：対象帳票の受付がない時間帯の可能性もあるため、期間を広げて再確認し、それでも0件なら報告する。

5. 報告例
本番ログを確認しました（直近12時間）。
・画像OCRチェック、名前カナ相関チェックとも実行されています
・新機能関連のERROR/WARNINGはありません

6. つまずいた点・注意事項
・「not authorized to perform StartQuery」でロググループが選べない → アカウントまたはロールの誤り。右上の表示を確認し、ポータルから入り直す
・ロググループが表示されない → リージョンが大阪か確認する
・エラー確認で正常ログ（INFO）が大量に出る → クエリ②に「and log.level != "INFO"」を付ける
・結果の時刻がずれて見える → UTC表示のため＋9時間する
・「テーブル結果をフィルタリング」で探しても見つからない → 表示中の結果のみが対象。条件はクエリのfilterに書く
