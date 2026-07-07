# 江戸走り iOS アプリ

HTML5 Canvas ゲーム（`../index.html`）を **WKWebView** で全画面表示するネイティブ iOS ラッパー。
ゲーム本体は `EdoBashiri/Resources/index.html` に同梱され、**完全オフライン**で動作する。

## 構成
- Swift / UIKit（Storyboard なし・プログラム的に構築）/ Scene ライフサイクル
- Deployment Target: iOS 14.0
- Bundle ID: `com.edobashiri`（Android の applicationId と揃えてある）
- `GameViewController` … WKWebView 全画面。JS/localStorage/WebAudio 動作。
  さらに **JS→ネイティブの触覚フィードバック橋渡し**（`haptic`）を実装済み。

## セットアップ（Mac・Terminal → Xcode → App Store Connect だけ）

### 1. ダウンロード（Terminal）
```bash
git clone https://github.com/tmk4men/edo-bashiri.git
cd edo-bashiri/ios
```
アプリアイコン（`Assets.xcassets/AppIcon.appiconset/icon-1024.png`）も一緒に落ちてくる。

### 2. ワンコマンドで生成＆起動（Terminal）
```bash
bash setup.sh
# ↓ Team ID が分かっていれば渡すと署名まで自動設定（任意）
# bash setup.sh ABCDE12345
```
`setup.sh` が Homebrew と XcodeGen を（無ければ）入れて `EdoBashiri.xcodeproj` を生成し、Xcode で開く。

### 3. Xcode
1. 上部でシミュレータを選び ▶ Run で試遊（シミュレータは署名不要）
2. 実機/申請時のみ **Signing & Capabilities** で自分の Team を選択
3. **Product > Archive** → Distribute App → App Store Connect でアップロード

> `.xcodeproj` は `project.yml` から生成する方式なので git には含めない（`setup.sh` でいつでも再生成）。

## App Store 申請チェックリスト（App Store Connect）
- [ ] App Store Connect でアプリ作成（Bundle ID `com.edobashiri` / 名称「江戸走り」）
- [ ] Xcode の Archive をアップロード → ビルドが Connect に表示されるのを待つ
- [ ] スクリーンショット（6.7"/6.5" 等の必須サイズ）、説明文、カテゴリ、年齢レーティング入力
- [ ] プライバシー：現状データ収集なし（AdMob 未導入）。導入時は再申告
- [ ] **⚠️ 4.2 対策**（下記）を入れてから審査提出するのが安全
- [ ] 「審査へ提出」

## 広告について
**初期リリースは AdMob オフ**（SDK 未統合・広告表示なし）。
導入は後日 `ADMOB_SETUP.md` の手順で。

## ゲームを更新したら
Web版（`../index.html`）を更新したら同梱コピーを差し替える:
```bash
cp ../index.html EdoBashiri/Resources/index.html
```

## ⚠️ App Store 審査の注意（重要）
App Store は「Webサイトを包んだだけ」のアプリに厳しい（ガイドライン **4.2 Minimum Functionality**）。
WebView 1 枚だけだとリジェクトされることがある。通すために **ネイティブらしさ**を足すのが定石:
- **触覚フィードバック**（本プロジェクトは橋渡し実装済み。下記フックを index.html に足すと有効化）
- **Game Center**（ネイティブのランキング/実績）← 効果大。導入推奨
- ネイティブなスプラッシュ/設定画面 など

### 触覚フィードバックの有効化（任意・推奨）
`index.html` の該当箇所に、無害なガード付きで 1 行足すだけ（iOS 以外では自動的に何もしない）:
```js
function haptic(k){ try{ window.webkit?.messageHandlers?.haptic?.postMessage(k); }catch(e){} }
// 走る成功: haptic('light')   /  転倒(ゲームオーバー): haptic('error')  /  新記録: haptic('success')
```

## リリース
- `project.yml` の `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` を更新
- Xcode > Product > Archive → Distribute App → App Store Connect
- App Store Connect でアプリ作成（Bundle ID `com.edobashiri`）→ 審査提出

## AdMob（今後導入予定）
`ADMOB_SETUP.md` 参照（Swift Package か CocoaPods で SDK 追加 → Info.plist に App ID → バナー/インタースティシャル）。
