#!/bin/sh
# ai-girls-toolbox: 環境チェック（読み取りのみ。何もインストール・変更しません）
# 出力は Markdown です。そのままレポートとして保存できます。

have() { command -v "$1" >/dev/null 2>&1; }

echo "# 環境レポート"
echo
echo "- 判定: PASS / FAIL / BLOCKED（いずれか一つを残して書き換えてください）"
echo "- 日時: $(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"
echo

echo "## システム"
echo
echo "- OS: $(uname -s 2>/dev/null) $(uname -r 2>/dev/null)"
echo "- アーキテクチャ: $(uname -m 2>/dev/null)"
if [ -r /etc/os-release ]; then
  . /etc/os-release
  echo "- ディストリビューション: ${PRETTY_NAME:-unknown}"
fi
if [ -n "$SHELL" ]; then
  echo "- ログインシェル(\$SHELL): $SHELL"
else
  echo "- ログインシェル(\$SHELL): 未設定（シェルがないという意味ではない）"
fi
echo "- 実行中のシェル: $(ps -p $$ -o comm= 2>/dev/null || readlink /proc/$$/exe 2>/dev/null || echo 不明)"
echo

echo "## 権限"
echo
echo "- UID: $(id -u 2>/dev/null)"
if [ "$(id -u 2>/dev/null)" = "0" ]; then
  echo "- root: はい"
elif have sudo && sudo -n true 2>/dev/null; then
  echo "- sudo: パスワードなしで使える"
elif have sudo; then
  echo "- sudo: あるが、パスワードなしでは使えない"
else
  echo "- sudo: なし"
fi
if [ -d "$HOME/.local/bin" ]; then
  echo "- ~/.local/bin: あり"
else
  echo "- ~/.local/bin: なし"
fi
case ":$PATH:" in
  *":$HOME/.local/bin:"*) echo "- ~/.local/bin が PATH に: 入っている" ;;
  *) echo "- ~/.local/bin が PATH に: 入っていない" ;;
esac
if [ -w "$HOME" ]; then
  echo "- ホームに書き込み: できる"
else
  echo "- ホームに書き込み: できない"
fi
echo

echo "## ネットワーク（接続確認のみ・5秒でタイムアウト）"
echo
check_url() {
  if have curl; then
    if curl -sS -o /dev/null -m 5 -I "$1" 2>/dev/null; then echo "つながる"; else echo "つながらない"; fi
  elif have wget; then
    if wget -q --spider -T 5 "$1" 2>/dev/null; then echo "つながる"; else echo "つながらない"; fi
  else
    echo "確認手段なし（curl/wget がない）"
  fi
}
echo "- github.com: $(check_url https://github.com)"
echo "- PyPI: $(check_url https://pypi.org/simple/)"
echo "- npm: $(check_url https://registry.npmjs.org/)"
echo

echo "## パッケージマネージャ"
echo
for pm in apt-get dnf apk pacman brew nix mise cargo pip3 npm; do
  if have "$pm"; then echo "- $pm: あり"; else echo "- $pm: なし"; fi
done
echo

echo "## ツール"
echo
# 書式: 表示名:コマンド名[:別名]
# ast-grep は sg の名前で入ることがあるが、sg は Linux 標準のグループ切替コマンドと衝突するので ast-grep を先に見る
ver_of() { "$1" --version 2>/dev/null | head -n 1 | cut -d' ' -f1-3; }
for spec in rg:rg fd:fd:fdfind jq:jq yq:yq sd:sd ast-grep:ast-grep bat:bat:batcat delta:delta git:git curl:curl; do
  name=$(echo "$spec" | cut -d: -f1)
  cmd=$(echo "$spec" | cut -d: -f2)
  alt=$(echo "$spec" | cut -d: -f3)
  if have "$cmd"; then
    echo "- $name: あり（$(ver_of "$cmd")）"
  elif [ -n "$alt" ] && have "$alt"; then
    echo "- $name: 別名 \`$alt\` であり（$(ver_of "$alt")）"
  else
    echo "- $name: なし"
  fi
done
echo

echo "## 出力まわりの設定"
echo
echo "- PAGER: ${PAGER:-（未設定）}"
echo "- NO_COLOR: ${NO_COLOR:-（未設定）}"
echo "- TERM: ${TERM:-（未設定）}"
echo

echo "## 補足（自由記述）"
echo
echo "<!-- スクリプトで分からない制限や、使ってみた感想があればここに -->"
