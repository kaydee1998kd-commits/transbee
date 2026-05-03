import UIKit
import ObjectiveC

class FloatingBubbleManager: NSObject {

    static let shared = FloatingBubbleManager()

    private var overlayWindow: UIWindow?
    private var bubbleView: BubbleView?
    private var translationWindow: UIWindow?
    private var translationPanel: TranslationPanelView?

    private(set) var isBubbleVisible = false
    private(set) var isTranslating = false
    private var isPanelVisible = false
    private var bubbleInitialCenter: CGPoint = .zero
    private var dragStartPoint: CGPoint = .zero
    private var keepAliveTimer: Timer?

    private let ocrService = OCRService()
    private let translationService = TranslationService()

    private override init() { super.init() }

    func start() {
        createOverlayWindow()
        showBubble()
        startKeepAliveTimer()
    }

    func stop() {
        hideBubble()
        overlayWindow = nil
        keepAliveTimer?.invalidate()
        keepAliveTimer = nil
    }

    private func createOverlayWindow() {
        let window = UIWindow.createOverlayWindow(frame: UIScreen.main.bounds)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        self.overlayWindow = window
    }

    private func showBubble() {
        guard let window = overlayWindow else { return }
        let screenBounds = UIScreen.main.bounds
        let initialX = screenBounds.width - AppConfig.bubbleSize - AppConfig.bubbleEdgePadding
        let initialY = screenBounds.height / 2 - AppConfig.bubbleSize / 2

        let bubble = BubbleView(frame: CGRect(x: initialX, y: initialY,
                                              width: AppConfig.bubbleSize, height: AppConfig.bubbleSize))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(bubbleDragged(_:)))
        bubble.addGestureRecognizer(tapGesture)
        bubble.addGestureRecognizer(panGesture)

        window.addSubview(bubble)
        window.makeKeyAndVisible()
        window.isHidden = false

        self.bubbleView = bubble
        self.isBubbleVisible = true

        bubble.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: AppConfig.bubbleAppearAnimationDuration, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            bubble.transform = .identity
        }
    }

    func hideBubble() {
        UIView.animate(withDuration: AppConfig.bubbleAppearAnimationDuration, animations: {
            self.bubbleView?.alpha = 0
            self.bubbleView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            self.bubbleView?.removeFromSuperview()
            self.bubbleView = nil
            self.isBubbleVisible = false
        })
    }

    func keepBubbleAlive() {
        overlayWindow?.isHidden = false
        overlayWindow?.alpha = 1.0
        overlayWindow?.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }

    func restoreBubbleIfNeeded() {
        if overlayWindow == nil || bubbleView == nil {
            createOverlayWindow()
            showBubble()
        }
        overlayWindow?.isHidden = false
    }

    private func startKeepAliveTimer() {
        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.ensureBubbleVisible()
        }
    }

    private func ensureBubbleVisible() {
        guard isBubbleVisible else { return }
        overlayWindow?.isHidden = false
        overlayWindow?.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }

    @objc private func bubbleTapped() {
        if isPanelVisible {
            hideTranslationPanel()
        } else {
            captureAndTranslate()
        }
    }

    @objc private func bubbleDragged(_ gesture: UIPanGestureRecognizer) {
        guard let bubble = bubbleView else { return }
        let translation = gesture.translation(in: bubble.superview)
        let location = gesture.location(in: bubble.superview)

        switch gesture.state {
        case .began:
            bubbleInitialCenter = bubble.center
            dragStartPoint = location
            UIView.animate(withDuration: 0.15) {
                bubble.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }
        case .changed:
            bubble.center = CGPoint(x: bubbleInitialCenter.x + translation.x,
                                    y: bubbleInitialCenter.y + translation.y)
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.15) { bubble.transform = .identity }
            snapBubbleToEdge(bubble)
            let distance = hypot(location.x - dragStartPoint.x, location.y - dragStartPoint.y)
            if distance < 5 { bubbleTapped() }
        default: break
        }
    }

    private func snapBubbleToEdge(_ bubble: BubbleView) {
        let screenBounds = UIScreen.main.bounds
        let padding = AppConfig.bubbleEdgePadding
        let midX = screenBounds.width / 2
        let targetX: CGFloat = bubble.center.x < midX
            ? padding + AppConfig.bubbleSize / 2
            : screenBounds.width - padding - AppConfig.bubbleSize / 2
        let minY = padding + AppConfig.bubbleSize / 2 + 40
        let maxY = screenBounds.height - padding - AppConfig.bubbleSize / 2 - 40
        let targetY = max(minY, min(maxY, bubble.center.y))

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            bubble.center = CGPoint(x: targetX, y: targetY)
        }
    }

    private func captureAndTranslate() {
        guard !isTranslating else { return }
        isTranslating = true
        bubbleView?.setLoading(true)
        showTranslationPanel(loading: true)

        ocrService.captureScreen { [weak self] image in
            guard let self = self else { return }
            if let image = image {
                self.ocrService.recognizeText(in: image) { [weak self] recognizedText in
                    guard let self = self else { return }
                    if let text = recognizedText, !text.isEmpty {
                        self.translateText(text)
                    } else {
                        self.translateFromClipboard()
                    }
                }
            } else {
                self.translateFromClipboard()
            }
        }
    }

    private func translateText(_ text: String) {
        translationService.translate(text: text) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.bubbleView?.setLoading(false)
                self.isTranslating = false
                switch result {
                case .success(let r):
                    self.showTranslationResult(original: text,
                                               translation: r.translation ?? r.error ?? "Failed")
                case .failure(let err):
                    self.showTranslationResult(original: text,
                                               translation: err.localizedDescription, isError: true)
                }
            }
        }
    }

    private func translateFromClipboard() {
        let clipboardText = UIPasteboard.general.string ?? ""
        if clipboardText.containsChinese {
            translateText(clipboardText)
        } else {
            DispatchQueue.main.async {
                self.bubbleView?.setLoading(false)
                self.isTranslating = false
                self.showTranslationResult(
                    original: "No text captured",
                    translation: "Could not read screen. Copy Chinese text first, then tap the bubble.",
                    isError: true)
            }
        }
    }

    private func showTranslationPanel(loading: Bool = false) {
        guard !isPanelVisible else { return }
        let screenBounds = UIScreen.main.bounds
        let panelWidth = min(AppConfig.translationPanelWidth, screenBounds.width - 32)
        let panelHeight: CGFloat = loading ? 150 : AppConfig.translationPanelMaxHeight

        let panelWindow = UIWindow.createOverlayWindow(frame: screenBounds)
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        rootVC.view.isUserInteractionEnabled = true
        panelWindow.rootViewController = rootVC

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissPanelTapped))
        rootVC.view.addGestureRecognizer(dismissTap)

        let panel = TranslationPanelView(frame: CGRect(
            x: (screenBounds.width - panelWidth) / 2,
            y: (screenBounds.height - panelHeight) / 2,
            width: panelWidth, height: panelHeight))
        if loading { panel.setLoading(true) }
        rootVC.view.addSubview(panel)

        panelWindow.isHidden = false
        panelWindow.makeKeyAndVisible()

        self.translationWindow = panelWindow
        self.translationPanel = panel
        self.isPanelVisible = true

        panel.alpha = 0
        panel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: AppConfig.panelAppearAnimationDuration, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3,
                       options: .curveEaseOut) {
            panel.alpha = 1
            panel.transform = .identity
        }
    }

    private func showTranslationResult(original: String, translation: String, isError: Bool = false) {
        DispatchQueue.main.async {
            self.translationPanel?.setLoading(false)
            self.translationPanel?.displayResult(original: original, translation: translation, isError: isError)
            self.bubbleView?.setLoading(false)
            self.isTranslating = false
        }
    }

    @objc private func dismissPanelTapped() {
        hideTranslationPanel()
    }

    private func hideTranslationPanel() {
        guard isPanelVisible else { return }
        UIView.animate(withDuration: 0.2, animations: {
            self.translationPanel?.alpha = 0
            self.translationPanel?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.translationWindow?.isHidden = true
            self.translationWindow = nil
            self.translationPanel = nil
            self.isPanelVisible = false
        })
    }
}
