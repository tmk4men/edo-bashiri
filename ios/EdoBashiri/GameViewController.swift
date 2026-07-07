import UIKit
import WebKit
import GameKit

/// 江戸走り（HTML5 Canvas ゲーム）を WKWebView で全画面表示するラッパー。
/// ゲームは Resources/index.html に同梱され、完全オフラインで動作する。
/// JS → ネイティブの橋渡しとして「触覚フィードバック(haptic)」と「Game Center(gc)」を実装。
class GameViewController: UIViewController, WKScriptMessageHandler {

    /// App Store Connect で作成するリーダーボードの ID（同じ値で作成すること）
    private let leaderboardID = "edo_bashiri_distance"

    private var webView: WKWebView!

    // 触覚フィードバック（毎回生成せず使い回し）
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notify = UINotificationFeedbackGenerator()

    // JS からアクセスポイント表示要求が来ても、認証完了までは保留する
    private var wantsAccessPoint = false

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // JS からのメッセージを受け取る
        let userContent = WKUserContentController()
        userContent.add(self, name: "haptic")   // 触覚
        userContent.add(self, name: "gc")        // Game Center
        config.userContentController = userContent

        webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
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

        impactLight.prepare(); impactMedium.prepare(); impactHeavy.prepare(); notify.prepare()

        authenticateGameCenter()
    }

    // MARK: - 全画面表示
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

    // MARK: - Game Center
    private func authenticateGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, _ in
            guard let self = self else { return }
            if let vc = viewController {
                // サインインが必要なら Game Center のログイン画面を出す
                self.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                GKAccessPoint.shared.location = .topLeading
                GKAccessPoint.shared.showHighlights = false
                GKAccessPoint.shared.isActive = self.wantsAccessPoint
            }
        }
    }

    private func submitScore(_ value: Int) {
        guard GKLocalPlayer.local.isAuthenticated, value > 0 else { return }
        GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [leaderboardID]) { _ in }
    }

    private func setAccessPoint(_ on: Bool) {
        wantsAccessPoint = on
        if GKLocalPlayer.local.isAuthenticated {
            GKAccessPoint.shared.isActive = on
        }
    }

    // MARK: - JS → ネイティブ ブリッジ
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case "haptic":
            handleHaptic(message.body)
        case "gc":
            handleGameCenter(message.body)
        default:
            break
        }
    }

    private func handleHaptic(_ body: Any) {
        guard let kind = body as? String else { return }
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

    private func handleGameCenter(_ body: Any) {
        guard let dict = body as? [String: Any],
              let action = dict["action"] as? String else { return }
        switch action {
        case "score":
            let value = (dict["value"] as? NSNumber)?.intValue ?? 0
            submitScore(value)
        case "access":
            let on = (dict["value"] as? NSNumber)?.boolValue ?? false
            setAccessPoint(on)
        default:
            break
        }
    }
}
