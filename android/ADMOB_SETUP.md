# AdMob 導入手順（今後導入予定）

現状のアプリは広告なしで完動する。AdMob を入れるときは、以下のコメントを外す＋コードを足すだけ。
**まずは Google 公式のテスト ID で動作確認 → 本番配信の直前に自分の ID へ差し替える**（テスト ID のまま公開すると規約違反）。

---

## 1. 依存を有効化
`app/build.gradle.kts` の該当行のコメントを外す:
```kotlin
implementation("com.google.android.gms:play-services-ads:23.6.0")
```

## 2. マニフェストを有効化
`app/src/main/AndroidManifest.xml`:
- `INTERNET` と `ACCESS_NETWORK_STATE` の 2 permission のコメントを外す
- `com.google.android.gms.ads.APPLICATION_ID` の `<meta-data>` のコメントを外す
  （値はテスト用 App ID `ca-app-pub-3940256099942544~3347511713`。本番は自分の App ID に）

## 3. SDK 初期化（MainActivity.onCreate 内）
```kotlin
import com.google.android.gms.ads.MobileAds
// ...
MobileAds.initialize(this) {}
```

## 4. バナー広告（画面下 `adContainer` に載せる）
```kotlin
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView

private fun setupBanner() {
    val adView = AdView(this)
    adView.setAdSize(AdSize.BANNER)
    // ↓ テスト用バナー ID。本番は自分の広告ユニット ID に差し替え
    adView.adUnitId = "ca-app-pub-3940256099942544/6300978111"
    binding.adContainer.addView(adView)
    adView.loadAd(AdRequest.Builder().build())
}
```
`onCreate` の最後で `setupBanner()` を呼ぶ。

## 5. インタースティシャル（ゲームオーバー時）
ゲームオーバーは HTML/JS 側で起きるので、**JS → Kotlin の橋渡し**を 1 つ足す。

### 5-1. MainActivity に JS ブリッジを登録
```kotlin
import android.webkit.JavascriptInterface
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError

private var interstitial: InterstitialAd? = null

private fun loadInterstitial() {
    InterstitialAd.load(
        this,
        "ca-app-pub-3940256099942544/1033173712", // テスト用。本番は差し替え
        AdRequest.Builder().build(),
        object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) { interstitial = ad }
            override fun onAdFailedToLoad(e: LoadAdError) { interstitial = null }
        }
    )
}

inner class GameBridge {
    @JavascriptInterface
    fun onGameOver() {
        runOnUiThread {
            interstitial?.show(this@MainActivity) ?: return@runOnUiThread
            interstitial = null
            loadInterstitial() // 次回用に先読み
        }
    }
}
```
WebView 設定に登録（`setupWebView` 内）:
```kotlin
web.addJavascriptInterface(GameBridge(), "Android")
```
`onCreate` で最初の `loadInterstitial()` を呼んでおく。

### 5-2. ゲーム側（index.html）からブリッジを呼ぶ
ゲームオーバー処理（`state = STATE.OVER` になる箇所）で、毎回は鬱陶しいので数回に1回だけ:
```js
if (window.Android && window.Android.onGameOver) {
  // 3回に1回だけ全画面広告（頻度は調整可）
  if (((window.__overCount = (window.__overCount||0)+1) % 3) === 0) {
    window.Android.onGameOver();
  }
}
```
> ProGuard/R8 を有効にする場合、`@JavascriptInterface` は `proguard-rules.pro` で保持済み。

---

## テスト ID 一覧（動作確認用・そのまま公開しないこと）
| 種類 | テスト ID |
|---|---|
| App ID | `ca-app-pub-3940256099942544~3347511713` |
| バナー | `ca-app-pub-3940256099942544/6300978111` |
| インタースティシャル | `ca-app-pub-3940256099942544/1033173712` |
| リワード | `ca-app-pub-3940256099942544/5224354917` |

## 本番リリース前チェック
- [ ] AdMob 管理画面でアプリ登録し、本番 App ID / 広告ユニット ID を発行
- [ ] 上記テスト ID をすべて本番 ID に差し替え
- [ ] `AndroidManifest` の App ID も本番に
- [ ] Play Console の「広告」欄で「広告あり」を申告
- [ ] （必要に応じ）同意管理 UMP SDK で GDPR/同意フォーム対応
