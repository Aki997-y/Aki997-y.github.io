$src = "請求書_期待値比較.xlsx"
if (-not (Test-Path $src)) { "テンプレートが見つかりません"; return }
$list = (Invoke-WebRequest "https://raw.githubusercontent.com/Aki997-y/Aki997-y.github.io/work/n1.txt" -UseBasicParsing).Content
$list -split "`n" | ForEach-Object { $_.Trim() -replace '\.xml$','' -replace '_期待値比較$','' } | Where-Object { $_ } | ForEach-Object {
  $dst = "${_}_期待値比較.xlsx"
  if (Test-Path $dst) { "既にあり: $dst" } else { Copy-Item $src $dst; "作成: $dst" }
}
