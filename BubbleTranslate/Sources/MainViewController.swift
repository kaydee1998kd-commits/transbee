import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.11, alpha: 1.0)
        let screenW = UIScreen.main.bounds.width
        let padding: CGFloat = 20
        var y: CGFloat = 80

        // Icon
        let iconView = UIView(frame: CGRect(x: (screenW - 60) / 2, y: y, width: 60, height: 60))
        iconView.backgroundColor = .bubbleGradientStart
        iconView.layer.cornerRadius = 30
        iconView.clipsToBounds = true
        view.addSubview(iconView)

        let iconLbl = UILabel(frame: iconView.bounds)
        iconLbl.text = "中A"
        iconLbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        iconLbl.textColor = .white
        iconLbl.textAlignment = .center
        iconView.addSubview(iconLbl)
        y += 76

        // Title
        let titleLbl = UILabel(frame: CGRect(x: padding, y: y, width: screenW - padding * 2, height: 34))
        titleLbl.text = "Bubble Translate"
        titleLbl.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLbl.textColor = .white
        titleLbl.textAlignment = .center
        view.addSubview(titleLbl)
        y += 38

        // Subtitle
        let subLbl = UILabel(frame: CGRect(x: padding, y: y, width: screenW - padding * 2, height: 20))
        subLbl.text = "Floating Chinese -> English Translator"
        subLbl.font = UIFont.systemFont(ofSize: 14)
        subLbl.textColor = UIColor(white: 1, alpha: 0.5)
        subLbl.textAlignment = .center
        view.addSubview(subLbl)
        y += 40

        // Status card
        let statusCard = UIView(frame: CGRect(x: padding, y: y, width: screenW - padding * 2, height: 80))
        statusCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        statusCard.layer.cornerRadius = 16
        statusCard.layer.borderColor = UIColor.panelBorder.cgColor
        statusCard.layer.borderWidth = 1
        view.addSubview(statusCard)

        let statusLbl = UILabel(frame: CGRect(x: 16, y: 16, width: screenW - 64, height: 22))
        statusLbl.text = "Bubble Active - Switch to any app"
        statusLbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        statusLbl.textColor = .systemGreen
        statusCard.addSubview(statusLbl)

        let statusDetail = UILabel(frame: CGRect(x: 16, y: 44, width: screenW - 64, height: 24))
        statusDetail.text = "Tap the floating bubble to translate"
        statusDetail.font = UIFont.systemFont(ofSize: 13)
        statusDetail.textColor = UIColor(white: 1, alpha: 0.5)
        statusCard.addSubview(statusDetail)
        y += 96

        // Instructions card
        let instrCard = UIView(frame: CGRect(x: padding, y: y, width: screenW - padding * 2, height: 240))
        instrCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        instrCard.layer.cornerRadius = 16
        instrCard.layer.borderColor = UIColor.panelBorder.cgColor
        instrCard.layer.borderWidth = 1
        view.addSubview(instrCard)

        let instrTitle = UILabel(frame: CGRect(x: 16, y: 16, width: screenW - 64, height: 22))
        instrTitle.text = "How to Use with Xianyu"
        instrTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        instrTitle.textColor = .white
        instrCard.addSubview(instrTitle)

        let instrText = UILabel(frame: CGRect(x: 16, y: 44, width: screenW - 64, height: 180))
        instrText.text = "1. Open Xianyu app\n2. Navigate to a product listing\n3. Tap the floating bubble\n4. App captures screen & reads Chinese\n5. You get instant English translation!\n\nTip: Copy Chinese text first, then\ntap bubble to translate from clipboard."
        instrText.font = UIFont.systemFont(ofSize: 13)
        instrText.textColor = UIColor(white: 1, alpha: 0.6)
        instrText.numberOfLines = 0
        instrCard.addSubview(instrText)
        y += 256

        // Server info card
        let serverCard = UIView(frame: CGRect(x: padding, y: y, width: screenW - padding * 2, height: 120))
        serverCard.backgroundColor = UIColor(white: 1, alpha: 0.05)
        serverCard.layer.cornerRadius = 16
        serverCard.layer.borderColor = UIColor.panelBorder.cgColor
        serverCard.layer.borderWidth = 1
        view.addSubview(serverCard)

        let serverTitle = UILabel(frame: CGRect(x: 16, y: 16, width: screenW - 64, height: 22))
        serverTitle.text = "Translation Server"
        serverTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        serverTitle.textColor = .white
        serverCard.addSubview(serverTitle)

        let urlLabel = UILabel(frame: CGRect(x: 16, y: 44, width: screenW - 64, height: 20))
        urlLabel.text = "API: \(AppConfig.translationAPIBaseURL)"
        urlLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        urlLabel.textColor = .panelAccent
        serverCard.addSubview(urlLabel)

        let endpointLabel = UILabel(frame: CGRect(x: 16, y: 68, width: screenW - 64, height: 36))
        endpointLabel.text = "/api/translate (text)\n/api/translate-image (image)"
        endpointLabel.font = UIFont.systemFont(ofSize: 12)
        endpointLabel.textColor = UIColor(white: 1, alpha: 0.4)
        endpointLabel.numberOfLines = 0
        serverCard.addSubview(endpointLabel)
    }
}
