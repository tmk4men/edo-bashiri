# AdMob 導入手順（iOS・今後導入予定）

現状は広告なしで完動。導入時の手順。**まずテスト ID で確認 → 本番配信直前に自分の ID へ差し替え**
（テスト ID のまま公開は規約違反）。

## 1. SDK 追加（どちらか）
**Swift Package Manager（推奨）**
Xcode > File > Add Package Dependencies… に
`https://github.com/googleads/swift-package-manager-google-mobile-ads.git` を追加。

**CocoaPods**
```ruby
# Podfile
pod 'Google-Mobile-Ads-SDK'
```
→ `pod install` 後は `.xcworkspace` を開く。

## 2. Info.plist に App ID（必須・無いと起動時クラッシュ）
`Info.plist` のコメントを外す（値はテスト用 App ID、本番は差し替え）:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

## 3. 初期化（AppDelegate.swift）
```swift
import GoogleMobileAds
// didFinishLaunchingWithOptions 内:
GADMobileAds.sharedInstance().start(completionHandler: nil)
```

## 4. バナー（画面下）
`GameViewController` にバナー用の `GADBannerView` を追加し、WKWebView の下に置く。
WebView を全画面固定にしている場合は、バナー分だけ下部を空けてレイアウトする。
```swift
import GoogleMobileAds
let banner = GADBannerView(adSize: GADAdSizeBanner)
banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" // テスト用バナー(iOS)。本番は差し替え
banner.rootViewController = self
banner.load(GADRequest())
```

## 5. インタースティシャル（ゲームオーバー時）
ゲームオーバーは JS 側で起きるので、触覚と同じ **JS→ネイティブのメッセージ橋渡し**を使う。

`GameViewController` の `userContentController` 登録に `gameover` を追加:
```swift
userContent.add(self, name: "gameover")
```
ハンドラでインタースティシャル表示:
```swift
import GoogleMobileAds
private var interstitial: GADInterstitialAd?

func loadInterstitial() {
    GADInterstitialAd.load(
        withAdUnitID: "ca-app-pub-3940256099942544/4411468910", // テスト用(iOS)。本番は差し替え
        request: GADRequest()
    ) { [weak self] ad, _ in self?.interstitial = ad }
}
// message.name == "gameover" のとき:
interstitial?.present(fromRootViewController: self)
interstitial = nil
loadInterstitial()
```
`index.html` のゲームオーバー処理で（頻度調整して）:
```js
window.webkit?.messageHandlers?.gameover?.postMessage(1);
```

## テスト ID（iOS・そのまま公開しないこと）
| 種類 | テスト ID |
|---|---|
| App ID | `ca-app-pub-3940256099942544~1458002511` |
| バナー | `ca-app-pub-3940256099942544/2934735716` |
| インタースティシャル | `ca-app-pub-3940256099942544/4411468910` |
| リワード | `ca-app-pub-3940256099942544/1712485313` |

## 本番前チェック
- [ ] AdMob 管理画面で iOS アプリ登録し本番 ID 発行
- [ ] 上記テスト ID をすべて本番 ID に差し替え（Info.plist の App ID 含む）
- [ ] App Store Connect の「App のプライバシー」で広告 SDK のデータ収集を申告
- [ ] 必要に応じ ATT（App Tracking Transparency）と UMP 同意フォーム対応
