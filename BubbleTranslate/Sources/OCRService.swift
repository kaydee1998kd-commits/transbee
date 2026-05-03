import UIKit
import Vision

class OCRService: NSObject {

    func captureScreen(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let screenRect = CGRect(
                x: 0, y: 0,
                width: UIScreen.main.bounds.width * UIScreen.main.scale,
                height: UIScreen.main.bounds.height * UIScreen.main.scale)

            if let cgImage = CGWindowListCreateImage(
                screenRect,
                .optionOnScreenBelowWindow,
                kCGNullWindowID,
                [.bestResolution]) {
                let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
                completion(image)
            } else {
                DispatchQueue.main.async {
                    completion(self.captureKeyWindow())
                }
            }
        }
    }

    private func captureKeyWindow() -> UIImage? {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(bounds: keyWindow.bounds)
        return renderer.image { ctx in
            keyWindow.layer.render(in: ctx.cgContext)
        }
    }

    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if error != nil {
                completion(nil)
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            var lines: [String] = []
            for obs in observations {
                if let candidate = obs.topCandidates(1).first {
                    let text = candidate.string
                    if text.containsChinese || self.looksLikeRelevantText(text) {
                        lines.append(text)
                    }
                }
            }

            let fullText = lines.joined(separator: "\n")
            completion(fullText.isEmpty ? nil : fullText)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try handler.perform([request])
            } catch {
                completion(nil)
            }
        }
    }

    private func looksLikeRelevantText(_ text: String) -> Bool {
        let hasNumbers = text.range(of: "\\d", options: .regularExpression) != nil
        let hasPrice = text.contains("¥") || text.contains("￥") || text.contains("$")
        return (hasNumbers || hasPrice) && text.count >= 2
    }
}
