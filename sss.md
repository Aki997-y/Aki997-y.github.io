## 4. ログ確認（CloudWatch ログ分析）

### 4-1. 画面の開き方
1. AWSマネジメントコンソール（tesアカウント、afidロール、東京リージョン）で CloudWatch を開く
2. 左メニュー「ログ」→「ログ分析」
3. 「ロググループ」で st-mid-file-create-process のロググループを選択（tes-v2 のもの。dev-v2 ではない）
4. 右上の時間範囲で投入時刻を含む範囲を選択（例：「30m」「1h」）。投入時刻を指定する場合は「カスタム」→「絶対」で日本時間を入力
5. クエリを入力して「クエリの実行」

### 4-2. 確認ごとのクエリ
クエリ欄の1行目（SOURCE…）は残し、2行目以降を以下に置き換える。

① 処理開始（zip_id）の確認
```
fields @timestamp, @message
| filter @message like /zip_id/
| sort @timestamp desc
| limit 50
```
→ 投入時刻以降の行があればOK。行を展開し、詳細の "zip_id" を控えておく（結果の特定に使用）

② 新機能が実行されたかの確認
```
fields @timestamp, @message
| filter @message like /OCR image verification|Name correlation LLM request count summary/
| sort @timestamp desc
| limit 50
```
→ 投入したケースごとに「Before calling "Bedrock" for OCR image verification」（画像OCR）、「Name correlation LLM request count summary」（名前カナ）が出ていればOK

③ エラー・警告の確認
```
filter log.level = "ERROR" or log.level = "WARNING"
| stats count(*) as cnt by log.level, log.message
| sort cnt desc
```

### 4-3. 判定の目安

| ログ | 意味 | 判断 |
|---|---|---|
| Before calling "Bedrock" for OCR image verification | 画像OCRチェックでLLMを呼び出した | 正常 |
| Name correlation LLM request count summary | 名前カナ相関チェックでLLMを呼び出した | 正常 |
| OCR image verification judgment is undetermined; existing flag is retained | LLMの回答が「判定不能」。既存フラグのまま | 判定不能のケースならOK。想定外のケースで出た場合は要確認 |
| OCR image verification response format is invalid; existing flags are retained | LLMの回答形式が不正で判定を破棄。既存フラグのまま | 要確認。期待値どおり3が立たない原因になる |
| LLM_REQUEST_VALIDATION_ERROR（例：top_k is deprecated） | Bedrock呼び出し自体が失敗 | NG。全件判定されないため、実装・設定の修正が必要 |
| 郵便番号取得に失敗しました／住所取得に失敗しました | テストデータの住所が実在しない | 既存のWARNING。試験には影響なし |

- ログが出ていること自体はOKの判断材料にならない。上表のどのログが出ているかで判断する。
- ①〜③の結果（件数・該当ログ）は画面キャプチャを証跡として保存する。

### 4-4. 注意事項
- 下部の「テーブル結果をフィルタリング」は表示中の最大1万件のみが対象。過去分を探す場合はクエリ本文に filter @message like /…/ を書く。
- クエリ内に日時を直接書く場合（START=…Z）はUTC（日本時間−9時間）。
- 何も表示されない場合は、リージョン（東京）、ロググループ（tes-v2）、時間範囲を確認する。
