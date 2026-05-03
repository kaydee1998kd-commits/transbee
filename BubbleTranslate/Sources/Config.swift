import UIKit
import AVFoundation
import Foundation
import Vision
import ObjectiveC
import CoreImage

// MARK: - App Configuration

struct AppConfig {
    static let translationAPIBaseURL = "http://localhost:3000"
    static let translateTextEndpoint = "\(translationAPIBaseURL)/api/translate"
    static let translateImageEndpoint = "\(translationAPIBaseURL)/api/translate-image"
    static let bubbleSize: CGFloat = 52
    static let bubbleCornerRadius: CGFloat = 26
    static let bubbleEdgePadding: CGFloat = 8
    static let translationPanelWidth: CGFloat = 320
    static let translationPanelMaxHeight: CGFloat = 400
    static let bubbleAppearAnimationDuration: TimeInterval = 0.3
    static let panelAppearAnimationDuration: TimeInterval = 0.25
}

// MARK: - Translation Result

struct TranslationResult: Codable {
    let translation: String?
    let original: String?
    let error: String?
}

// MARK: - UIColor Theme

extension UIColor {
    static let bubbleGradientStart = UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0)
    static let bubbleGradientEnd = UIColor(red: 0.58, green: 0.34, blue: 0.93, alpha: 1.0)
    static let panelBackground = UIColor(red: 0.06, green: 0.07, blue: 0.11, alpha: 0.95)
    static let panelBorder = UIColor(white: 1.0, alpha: 0.1)
    static let panelAccent = UIColor(red: 0.39, green: 0.40, blue: 0.95, alpha: 1.0)
    static let panelTextPrimary = UIColor.white
    static let panelTextSecondary = UIColor(white: 1.0, alpha: 0.6)
    static let panelTextMuted = UIColor(white: 1.0, alpha: 0.4)
}

// MARK: - String Extension

extension String {
    var containsChinese: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
}

// MARK: - UIView Extension

extension UIView {
    func addShadow(color: UIColor = .black, opacity: Float = 0.3,
                   offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 8) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}

// MARK: - UIWindow Overlay

extension UIWindow {
    static func createOverlayWindow(frame: CGRect) -> UIWindow {
        let window = UIWindow(frame: frame)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isUserInteractionEnabled = true
        return window
    }
}
