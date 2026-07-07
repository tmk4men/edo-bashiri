# 江戸走り iOS アプリ

HTML5 Canvas ゲーム（`../index.html`）を **WKWebView** で全画面表示するネイティブ iOS ラッパー。
ゲーム本体は `EdoBashiri/Resources/index.html` に同梱され、**完全オフライン**で動作する。

## 構成
- Swift / UIKit（Storyboard なし・プログラム的に構築）/ Scene ライフサイクル
- Deployment Target: iOS 14.0
- Bundle ID: `com.edobashiri`（Android の applicationId と揃えてある）
- `GameViewController` … WKWebView 全画面。JS/localStorage/WebAudio 動作。
  **ネイティブ機能を実装済み**（4.2 対策）:
  - **触覚フィードバック** … ピタリ/500里突破=light、新記録=success、転倒=error（配線済み・自動で振動する）
  - **Game Center** … 起動時に自動サインイン、リザルトで自己ベストをリーダーボード送信、
    タイトル/リザルトに Game Center アクセスポイント（ランキング）を表示

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
- [ ] **Game Center を有効化＋リーダーボード作成**（下記「Game Center」参照）
- [ ] Xcode の Archive をアップロード → ビルドが Connect に表示されるのを待つ
- [ ] スクリーンショット（6.7"/6.5" 等の必須サイズ）、説明文、カテゴリ、年齢レーティング入力
- [ ] プライバシー：現状データ収集なし（AdMob 未導入）。導入時は再申告
- [ ] 「審査へ提出」

## Game Center（4.2 対策・実装済み）
アプリ側のコードは配線済み。App Store Connect で 1 つだけ設定が要る:

1. アプリの **「サービス > Game Center」** を有効化
2. **リーダーボード**を 1 つ作成し、**リーダーボード ID を `edo_bashiri_distance`** にする
   （`GameViewController.swift` の `leaderboardID` と一致させること。変える場合は両方直す）
   - スコアの形式: 整数（大きいほど上位）＝「走破距離（里）」
3. これで、ゲームオーバー時に自己ベストが自動送信され、
   タイトル/リザルトのアクセスポイントからランキングが見られる。

> リーダーボード未作成でも、サインインとアクセスポイント表示は動く（スコア送信だけ無効）。
> ただし審査・体験の観点から、リーダーボードは作成しておくのを推奨。

## 広告について
**初期リリースは AdMob オフ**（SDK 未統合・広告表示なし）。
導入は後日 `ADMOB_SETUP.md` の手順で。

## ゲームを更新したら
Web版（`../index.html`）を更新したら同梱コピーを差し替える:
```bash
cp ../index.html EdoBashiri/Resources/index.html
```

## ⚠️ App Store 審査の注意（4.2 Minimum Functionality）
App Store は「Webサイトを包んだだけ」のアプリに厳しい。本プロジェクトは対策として
**触覚フィードバック**と **Game Center**（サインイン・アクセスポイント・スコア送信）を
ネイティブ実装済み。上記「Game Center」のリーダーボードを作成しておけば、
ネイティブ機能が揃った状態で申請できる。

> `index.html` 側の橋渡しは全てガード付き（`window.webkit?.messageHandlers…`）なので、
> web／Android では自動的に何もしない。iOS アプリのときだけ触覚・Game Center が働く。

## リリース
- `project.yml` の `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` を更新
- Xcode > Product > Archive → Distribute App → App Store Connect
- App Store Connect でアプリ作成（Bundle ID `com.edobashiri`）→ 審査提出

## AdMob（今後導入予定）
`ADMOB_SETUP.md` 参照（Swift Package か CocoaPods で SDK 追加 → Info.plist に App ID → バナー/インタースティシャル）。
