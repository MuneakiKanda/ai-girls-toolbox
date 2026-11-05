# AGENTS.md — AI Girls 共通の作業ルール

このファイルは、このリポジトリを使うAIエージェント向けの指示書です。
目的は「同じ環境を強制すること」ではなく、「あるものを賢く使うこと」です。

## 1. まず確認する

作業を始めるときに、使えるツールを一度だけ確認してください。

```sh
for t in rg fd fdfind jq yq sd ast-grep bat batcat delta; do command -v "$t" >/dev/null && echo "$t"; done
```

## 2. あれば優先して使う

| やりたいこと | 優先 | なければ |
|---|---|---|
| テキスト検索 | `rg` | `grep -r` |
| ファイル検索 | `fd`（Debian系では `fdfind`） | `find` |
| JSON 処理 | `jq` | — |
| YAML 処理 | `yq` | — |
| 文字列置換 | `sd` | `sed` |
| 構文を考慮した検索・置換 | `ast-grep` | `rg` + 目視確認 |
| diff 表示 | `delta` | `git diff` |

- ツールがなくても作業を止めないでください。右の列の従来コマンドで続けて構いません
- ツールの**インストールは、主催者さんから指示があったときだけ**行ってください

## 3. 出力を小さく保つ

- 検索結果が多くなりそうなときは、まず件数やファイル名だけを見る
  - `rg -l PATTERN`（ファイル名だけ）、`rg -c PATTERN`（件数だけ）
- 機械的に処理したいときは構造化出力を使う
  - `rg --json`、`fd` の結果を `jq` に渡す、など
- 長い出力は `head` で切る

## 4. 止まらない・汚さないための設定

非対話で実行するため、コマンドの前に次を設定することを推奨します。

```sh
export PAGER=cat GIT_PAGER=cat NO_COLOR=1
```

- `bat` を使うときは `--paging=never --color=never` を付ける
- `git` では `--no-pager` を付けるか、上の設定を使う

## 5. 名前の罠

- ast-grep は `ast-grep` の名前で呼ぶ（短縮名 `sg` は Linux 標準のグループ切替コマンドと衝突する）
- Debian/Ubuntu では `fd` が `fdfind`、`bat` が `batcat` という名前で入っていることがある
- 既存コマンドを alias で上書きしない（`grep` を `rg` に差し替える、など）

## 6. 環境が違うと気づいたら

`check-env.sh` を実行し、結果を `reports/<名前>-<環境>.md` として残してください（手順は README を参照）。
