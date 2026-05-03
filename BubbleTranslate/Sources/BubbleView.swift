import UIKit

class BubbleView: UIView {

    private let iconLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let pulseLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = AppConfig.bubbleCornerRadius
        clipsToBounds = false

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.bubbleGradientStart.cgColor, UIColor.bubbleGradientEnd.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = AppConfig.bubbleCornerRadius
        layer.insertSublayer(gradientLayer, at: 0)

        addShadow(color: UIColor.bubbleGradientStart, opacity: 0.4,
                  offset: CGSize(width: 0, height: 4), radius: 12)
        layer.borderColor = UIColor(white: 1, alpha: 0.3).cgColor
        layer.borderWidth = 1.5

        iconLabel.text = "中A"
        iconLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        iconLabel.textColor = .white
        iconLabel.textAlignment = .center
        iconLabel.numberOfLines = 2
        addSubview(iconLabel)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)

        pulseLayer.fillColor = UIColor.bubbleGradientStart.cgColor
        pulseLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: -4, dy: -4)).cgPath
        pulseLayer.opacity = 0
        pulseLayer.frame = bounds.insetBy(dx: -4, dy: -4)
        layer.insertSublayer(pulseLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
        iconLabel.frame = bounds
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func setLoading(_ loading: Bool) {
        if loading {
            iconLabel.isHidden = true
            activityIndicator.startAnimating()
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 0.4
            anim.toValue = 0
            anim.duration = 1.0
            anim.repeatCount = .infinity
            anim.autoreverses = true
            pulseLayer.add(anim, forKey: "pulse")
        } else {
            iconLabel.isHidden = false
            activityIndicator.stopAnimating()
            pulseLayer.removeAllAnimations()
            pulseLayer.opacity = 0
        }
    }
}
