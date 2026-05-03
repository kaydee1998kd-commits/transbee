import UIKit
import AVFoundation

class TranslationPanelView: UIView {

    private let headerView = UIView()
    private let languageLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let originalTextView = UITextView()
    private let translationTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let speakButton = UIButton(type: .system)
    private let actionStack = UIStackView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private var currentTranslation = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .panelBackground
        layer.cornerRadius = 20
        layer.borderColor = UIColor.panelBorder.cgColor
        layer.borderWidth = 1
        addShadow(opacity: 0.5, radius: 20)
        clipsToBounds = true

        headerView.backgroundColor = UIColor(white: 1, alpha: 0.03)
        addSubview(headerView)

        languageLabel.text = "Chinese -> English"
        languageLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        languageLabel.textColor = .panelAccent
        headerView.addSubview(languageLabel)

        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.panelTextSecondary, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(closeButton)

        originalTextView.isEditable = false
        originalTextView.isScrollEnabled = true
        originalTextView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        originalTextView.layer.cornerRadius = 10
        originalTextView.font = UIFont.systemFont(ofSize: 14)
        originalTextView.textColor = .panelTextSecondary
        originalTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        addSubview(originalTextView)

        translationTextView.isEditable = false
        translationTextView.isScrollEnabled = true
        translationTextView.backgroundColor = UIColor.panelAccent.withAlphaComponent(0.1)
        translationTextView.layer.cornerRadius = 10
        translationTextView.layer.borderColor = UIColor.panelAccent.withAlphaComponent(0.3).cgColor
        translationTextView.layer.borderWidth = 1
        translationTextView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        translationTextView.textColor = .panelTextPrimary
        translationTextView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        addSubview(translationTextView)

        actionStack.axis = .horizontal
        actionStack.spacing = 12
        actionStack.distribution = .fillEqually
        addSubview(actionStack)

        copyButton.setTitle("Copy", for: .normal)
        copyButton.setTitleColor(.panelTextPrimary, for: .normal)
        copyButton.backgroundColor = UIColor(white: 1, alpha: 0.08)
        copyButton.layer.cornerRadius = 10
        copyButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        copyButton.addTarget(self, action: #selector(copyTranslation), for: .touchUpInside)
        actionStack.addArrangedSubview(copyButton)

        speakButton.setTitle("Speak", for: .normal)
        speakButton.setTitleColor(.panelTextPrimary, for: .normal)
        speakButton.backgroundColor = UIColor(white: 1, alpha: 0.08)
        speakButton.layer.cornerRadius = 10
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        speakButton.addTarget(self, action: #selector(speakTranslation), for: .touchUpInside)
        actionStack.addArrangedSubview(speakButton)

        loadingView.color = .panelAccent
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)

        loadingLabel.text = "Capturing & Translating..."
        loadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .panelTextSecondary
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = true
        addSubview(loadingLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let p: CGFloat = 16
        let cw = bounds.width - p * 2

        headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        languageLabel.frame = CGRect(x: p, y: 12, width: 150, height: 20)
        closeButton.frame = CGRect(x: bounds.width - 44, y: 8, width: 36, height: 28)

        if loadingView.isAnimating {
            loadingView.center = CGPoint(x: bounds.midX, y: bounds.midY - 10)
            loadingLabel.frame = CGRect(x: p, y: bounds.midY + 15, width: cw, height: 20)
            return
        }

        var y: CGFloat = 52
        let oh = min(originalTextView.contentSize.height + 20, 80)
        originalTextView.frame = CGRect(x: p, y: y, width: cw, height: oh)
        y += oh + 8

        let th = min(translationTextView.contentSize.height + 20, bounds.height - y - 70)
        translationTextView.frame = CGRect(x: p, y: y, width: cw, height: max(th, 60))
        y += max(th, 60) + 12

        actionStack.frame = CGRect(x: p, y: y, width: cw, height: 40)
    }

    func setLoading(_ loading: Bool) {
        if loading {
            loadingView.startAnimating()
            loadingLabel.isHidden = false
            originalTextView.isHidden = true
            translationTextView.isHidden = true
            actionStack.isHidden = true
        } else {
            loadingView.stopAnimating()
            loadingLabel.isHidden = true
            originalTextView.isHidden = false
            translationTextView.isHidden = false
            actionStack.isHidden = false
        }
        setNeedsLayout()
    }

    func displayResult(original: String, translation: String, isError: Bool = false) {
        originalTextView.text = original
        translationTextView.text = translation
        currentTranslation = translation
        translationTextView.textColor = isError ? .systemRed : .panelTextPrimary
        setLoading(false)
    }

    @objc private func copyTranslation() {
        UIPasteboard.general.string = currentTranslation
        copyButton.setTitle("Copied!", for: .normal)
        copyButton.setTitleColor(.systemGreen, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.copyButton.setTitle("Copy", for: .normal)
            self.copyButton.setTitleColor(.panelTextPrimary, for: .normal)
        }
    }

    @objc private func speakTranslation() {
        let utterance = AVSpeechUtterance(string: currentTranslation)
        utterance.language = "en-US"
        utterance.rate = 0.9
        AVSpeechSynthesizer().speak(utterance)
    }
}
