#!/usr/bin/env bash
#
# 江戸走り iOS ワンコマンドセットアップ（Mac 専用）
#
# 使い方（Terminal）:
#   cd ios
#   bash setup.sh                 … Team は Xcode 上で選ぶ
#   bash setup.sh ABCDE12345      … Apple Developer の Team ID を渡すと署名まで自動設定
#
# やること: Homebrew と XcodeGen を（無ければ）入れて、project.yml から
#           EdoBashiri.xcodeproj を生成し、Xcode で開く。
#
set -euo pipefail
cd "$(dirname "$0")"

echo "▶ 江戸走り iOS セットアップを開始"

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "  Homebrew が見つからないのでインストールします（パスワードを求められることがあります）"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon の brew を今のシェルで使えるように
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
fi

# 2. XcodeGen
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "  XcodeGen をインストールします"
  brew install xcodegen
fi

# 3. Team ID（任意）を project.yml に反映
if [ "${1:-}" != "" ]; then
  echo "  DEVELOPMENT_TEAM を $1 に設定"
  /usr/bin/sed -i '' "s/DEVELOPMENT_TEAM: .*/DEVELOPMENT_TEAM: \"$1\"/" project.yml
fi

# 4. .xcodeproj を生成
echo "  Xcode プロジェクトを生成中..."
xcodegen generate

# 5. Xcode で開く
open EdoBashiri.xcodeproj

echo ""
echo "✅ 完了。Xcode が開きます。"
echo "   1) 上部でシミュレータを選び ▶ で試遊"
echo "   2) 実機/申請時は Signing & Capabilities で自分の Team を選択"
echo "   3) Product > Archive → Distribute App → App Store Connect でアップロード"
