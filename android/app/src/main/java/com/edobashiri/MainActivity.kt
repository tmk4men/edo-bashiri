package com.edobashiri

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.edobashiri.databinding.ActivityMainBinding

/**
 * 江戸走り（HTML5 Canvas ゲーム）を WebView で全画面表示するだけの薄いラッパー。
 * ゲームは app/src/main/assets/index.html に同梱されており、完全オフラインで動作する。
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ステータスバー/ナビバー裏まで描画（viewport-fit=cover と合わせて端まで使う）
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // ノッチ（ディスプレイカットアウト）領域にも描画（API 28+）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes = window.attributes.apply {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }

        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // ゲーム中は画面を消さない
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        enterImmersiveMode()
        setupWebView(binding.webView)

        binding.webView.loadUrl("file:///android_asset/index.html")

        // 端末の戻るボタン：単一画面ゲームなのでアプリ終了
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finish()
            }
        })
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView(web: WebView) {
        web.settings.apply {
            javaScriptEnabled = true          // ゲーム本体
            domStorageEnabled = true          // localStorage（ベストスコア保存）に必須
            mediaPlaybackRequiresUserGesture = false  // WebAudio（効果音）を鳴らせるように
            useWideViewPort = true            // ページ側の viewport メタを尊重
            loadWithOverviewMode = true
            builtInZoomControls = false
            setSupportZoom(false)
            textZoom = 100                    // OSのフォントサイズ設定でレイアウトが崩れないよう固定
            cacheMode = android.webkit.WebSettings.LOAD_DEFAULT
        }
        // 外部遷移は発生しない単一ページだが、念のため WebView 内に閉じ込める
        web.webViewClient = WebViewClient()
        web.setBackgroundColor(0xFF000000.toInt())
    }

    private fun enterImmersiveMode() {
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.systemBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        // 通知シェード等から戻ったときに再度フルスクリーンへ
        if (hasFocus) enterImmersiveMode()
    }

    override fun onPause() {
        super.onPause()
        binding.webView.onPause()
    }

    override fun onResume() {
        super.onResume()
        binding.webView.onResume()
    }
}
