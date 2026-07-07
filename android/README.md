# 江戸走り Android アプリ

HTML5 Canvas ゲーム（`../index.html`）を WebView で全画面表示するネイティブ Android ラッパー。
ゲーム本体は `app/src/main/assets/index.html` に同梱され、**完全オフライン**で動作する。

## 構成
- 言語: Kotlin / AGP 8.7.3 / Gradle 8.9 / compileSdk 35
- minSdk 26 (Android 8.0) / targetSdk 35
- `MainActivity` … WebView を全画面・イマーシブ表示。JS/DOMストレージ/WebAudio 有効。
- `applicationId` = `com.edobashiri`

## ビルド手順（Android Studio）
1. Android Studio で **この `android/` フォルダ**を開く（`江戸走り/android`）。
   ルートの `江戸走り` ではなく `android` を開くこと。
2. 初回は Gradle Sync が走る（wrapper が無ければ Studio が自動取得）。
3. 実機/エミュレータを選んで ▶ Run。

> コマンドラインで叩く場合（Java 17 が必要）:
> `cd android && ./gradlew assembleDebug`
> wrapper jar が無い環境では先に `gradle wrapper` を一度実行。

## ゲームを更新したら
Web版（`../index.html`）を更新したら、同梱コピーを差し替える:
```
cp ../index.html app/src/main/assets/index.html
```
（プロジェクトルートに `sync-assets` 用のスクリプトを足すのも可）

## AdMob（今後導入予定）
`ADMOB_SETUP.md` に、コメントを外すだけで有効化できる手順を記載。
バナーは `activity_main.xml` の `adContainer`、インタースティシャルはゲームオーバー時が定石。

## リリース
- `versionCode` / `versionName` を `app/build.gradle.kts` で更新
- 署名付き AAB を生成（Build > Generate Signed Bundle / APK > Android App Bundle）
- Play Console にアップロード
