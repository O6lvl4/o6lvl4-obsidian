#!/usr/bin/env bash
set -euo pipefail

# Usage: ./setup.sh [vault_directory]
# If no directory is given, a folder called "YourVault" will be created in the current directory.

VAULT_DIR="${1:-$PWD/vault}"
DATE_STAMP=$(date +"%Y%m%d%H%M")
YEAR_MONTH=$(date +"%Y-%m")

echo "📁 Creating vault at: $VAULT_DIR"

# ----------------------------------------------------------------------------------
# 1. Create directory structure (Zettelkasten style)
# ----------------------------------------------------------------------------------
mkdir -p "$VAULT_DIR"/{00_Inbox,01_Fleeting,02_Literature,03_Permanent,04_MOCs,90_Archive,templates}
mkdir -p "$VAULT_DIR/assets/$YEAR_MONTH"

# ----------------------------------------------------------------------------------
# 2. Create .gitignore
# ----------------------------------------------------------------------------------
cat > "$VAULT_DIR/.gitignore" <<'EOF'
.obsidian/cache/
.obsidian/workspace.json
.obsidian/plugins/
.DS_Store
EOF

# ----------------------------------------------------------------------------------
# 3. Create .gitattributes and enable Git LFS for assets
# ----------------------------------------------------------------------------------
cat > "$VAULT_DIR/.gitattributes" <<'EOF'
assets/** filter=lfs diff=lfs merge=lfs -text
EOF

# ----------------------------------------------------------------------------------
# 4. Create sample markdown files
# ----------------------------------------------------------------------------------

cat > "$VAULT_DIR/00_Inbox/${DATE_STAMP}-quick-idea.md" <<EOF
# 📌 ひらめき：Zettelkasten のメタ情報を自動付与したい

- **思いつき**  
  新規ノート作成時点で ID・作成日時・リンク先候補を自動で挿入するプラグインが欲しい  
- **次にやる**  
  - Obsidian API を調査  
  - GitHub に Issue 起票
EOF

cat > "$VAULT_DIR/01_Fleeting/${DATE_STAMP}-fleeting-note.md" <<EOF
# 📝 Fleeting Note – ZK とアウトライナー併用

- Dynalist の階層アウトラインを Zettelkasten とどう両立するか？  
- 24 時間以内に Permanent へ昇格させられるか判断。
EOF

cat > "$VAULT_DIR/02_Literature/${DATE_STAMP}-ahrens-zk-book-summary.md" <<EOF
# 📚 書籍メモ『実践的メモ術 Zettelkasten入門』(Sönke Ahrens)

> *“Writing is not the outcome of thinking, it is the thinking itself.”*

## 要点
1. カードは「1 アイデア = 1 ノート"
2. Fleeting ➜ Literature ➜ Permanent の三階層
3. リンクとタグでネットワークを拡張

## 引用 & コメント
- p.42 「永続ノートは文章の最小単位」  
  → ブログ下書きにもそのまま流用できる！
EOF

cat > "$VAULT_DIR/03_Permanent/${DATE_STAMP}-principle-atomic-notes.md" <<EOF
# 🧠 永続ノート：原子性と可組合せ性

**主張**  
1 アイデアを 1 ファイルに閉じ込めることで、  
後から「文脈を変えて再利用」できる（ブログ・論文・講義資料など）。

## つながり
- [[${DATE_STAMP}-ahrens-zk-book-summary]] — 出典
- [[${DATE_STAMP}-moc-zettelkasten]] — MOC
EOF

cat > "$VAULT_DIR/04_MOCs/${DATE_STAMP}-moc-zettelkasten.md" <<EOF
# 🗺️ MOC: Zettelkasten 速習ガイド

- **概念**  
  - [[${DATE_STAMP}-principle-atomic-notes]] — 原子性
- **プロセス**  
  - [[${DATE_STAMP}-fleeting-note]] — Fleeting ➜ Permanent 流れ
- **参考文献**  
  - [[${DATE_STAMP}-ahrens-zk-book-summary]]
EOF

cat > "$VAULT_DIR/90_Archive/202404020900-old-workflow.md" <<'EOF'
# 🔒 旧ワークフロー（2024-04-02）

Zettelkasten 導入前に使っていたフォルダ手動整理方式のメモ。  
必要があれば参照するが、現在は非推奨。
EOF

cat > "$VAULT_DIR/templates/zettel-template.md" <<'EOF'
# <% tp.date.now("🧩 YYYYMMDDHHmm") %> タイトル

- **主張 / アイデア**  
- **背景 / 参考**  
  - [[リンク先ノート]]
- **タグ**  
  - #zk #idea
EOF

# ----------------------------------------------------------------------------------
# 5. Initialise Git repo and Git LFS
# ----------------------------------------------------------------------------------

cd "$VAULT_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ Git is not installed. Please install Git and run this script again."
  exit 1
fi

if ! command -v git-lfs >/dev/null 2>&1; then
  echo "⚠️  git-lfs not found. Attempting to install..."
  OS="$(uname -s)"
  if [[ "$OS" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    brew install git-lfs
  elif [[ "$OS" == "Linux" ]] && command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y git-lfs
  elif [[ "$OS" == "Linux" ]] && command -v yum >/dev/null 2>&1; then
    sudo yum install -y git-lfs
  else
    echo "❌ Automatic install failed. Install git-lfs manually."
    exit 1
  fi
fi

if [ ! -d ".git" ]; then
  git init
fi

git lfs install --skip-repo
git add .gitattributes
git lfs track "assets/**"

# ----------------------------------------------------------------------------------
# 6. Initial commit
# ----------------------------------------------------------------------------------
git add .
git commit -m "chore: init Zettelkasten vault with Git LFS and sample notes"

echo "✅ Setup complete! Vault directory: $VAULT_DIR"
echo "👉 To add a remote and push:"
echo "   cd \"$VAULT_DIR\" && git remote add origin <URL-of-your-repo>"
echo "   git push -u origin main"
