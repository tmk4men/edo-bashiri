# 江戸走り iOS アプリ

HTML5 Canvas ゲーム（`../index.html`）を **WKWebView** で全画面表示するネイティブ iOS ラッパー。
ゲーム本体は `EdoBashiri/Resources/index.html` に同梱され、**完全オフライン**で動作する。

## 構成
- Swift / UIKit（Storyboard なし・プログラム的に構築）/ Scene ライフサイクル
- Deployment Target: iOS 14.0
- Bundle ID: `com.edobashiri`（Android の applicationId と揃えてある）
- `GameViewController` … WKWebView 全画面。JS/localStorage/WebAudio 動作。
  さらに **JS→ネイティブの触覚フィードバック橋渡し**（`haptic`）を実装済み。

## セットアップ（Mac）
`.xcodeproj` は手書きせず **XcodeGen** で `project.yml` から生成する。

```bash
brew install xcodegen        # 初回のみ
cd ios
xcodegen generate            # EdoBashiri.xcodeproj を生成
open EdoBashiri.xcodeproj
```

1. Xcode で開いたら、ターゲット EdoBashiri > Signing & Capabilities で
   自分の **Team** を選ぶ（`project.yml` の `DEVELOPMENT_TEAM` に Team ID を書いてもよい）。
2. シミュレータを選んで ▶ Run（シミュレータなら署名不要）。
3. 実機で動かすときのみ Apple Developer アカウントでの署名が必要。

> XcodeGen を使わない場合: Xcode で新規 App プロジェクト（UIKit/Swift）を作り、
> `EdoBashiri/` 内の .swift・Info.plist・Assets.xcassets・Resources/index.html を取り込んでもよい。

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
