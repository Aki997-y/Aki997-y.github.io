# 使い方：期待値比較のテンプレートと list.txt を同じフォルダに置き、そのフォルダで実行
# list.txt：1行に1つ、xmlファイル名（.xmlはあってもなくてもよい）
$src = Get-ChildItem *_期待値比較.xlsx | Where-Object { $_.Name -match '^(請求書|診断書)_期待値比較\.xlsx$' } | Select-Object -First 1
if (-not $src) { "テンプレートが見つかりません"; return }
Get-Content .\list.txt -Encoding UTF8 | Where-Object { $_.Trim() } | ForEach-Object {
  $n = $_.Trim() -replace '\.xml$',''
  $dst = "${n}_期待値比較.xlsx"
  if (Test-Path $dst) { "既にあり: $dst" } else { Copy-Item $src.FullName $dst; "作成: $dst" }
}
