import UIKit
import WebKit

/// 江戸走り（HTML5 Canvas ゲーム）を WKWebView で全画面表示するラッパー。
/// ゲームは Resources/index.html に同梱され、完全オフラインで動作する。
/// 併せて JS → ネイティブの触覚フィードバック橋渡し（"haptic"）を用意している。
class GameViewController: UIViewController, WKScriptMessageHandler {

    private var webView: WKWebView!

    // 触覚フィードバック（毎回生成せず使い回し）
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // JS からの触覚リクエストを受け取る（window.webkit.messageHandlers.haptic.postMessage("light") 等）
        let userContent = WKUserContentController()
        userContent.add(self, name: "haptic")
        config.userContentController = userContent

        webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        // 端まで使う（ゲーム側が viewport-fit=cover + env() でセーフエリアを処理）
        webView.insetsLayoutMarginsFromSafeArea = false

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let url = Bundle.main.url(forResource: "index", withExtension: "html") else {
            assertionFailure("index.html が Resources に見つからない")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

        // ジェネレータを準備（初回反応を速くする）
        impactLight.prepare(); impactMedium.prepare(); impactHeavy.prepare(); notify.prepare()
    }

    // MARK: - 全画面表示
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

    // MARK: - JS → ネイティブ 触覚ブリッジ
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "haptic", let kind = message.body as? String else { return }
        switch kind {
        case "light":   impactLight.impactOccurred();  impactLight.prepare()
        case "medium":  impactMedium.impactOccurred(); impactMedium.prepare()
        case "heavy":   impactHeavy.impactOccurred();  impactHeavy.prepare()
        case "success": notify.notificationOccurred(.success); notify.prepare()
        case "warning": notify.notificationOccurred(.warning); notify.prepare()
        case "error":   notify.notificationOccurred(.error);   notify.prepare()
        default: break
        }
    }
}
