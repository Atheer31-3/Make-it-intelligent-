import CoreML
import NaturalLanguage
import SwiftUI
import UIKit
import VisionKit

struct DataScanner: UIViewControllerRepresentable {

    @Binding var startScanning: Bool
    @Binding var scanText: String
    @Binding var labelPrediction: String
    @Binding var showSheet: Bool

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )

        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {

        if startScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScanner

        init(_ parent: DataScanner) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scanText = text.transcript
                parent.modelText()

                // Show the sheet only if scanText is not empty
                if !parent.scanText.isEmpty {
                    parent.showSheet = true

                    // Stop scanning when the sheet is shown
                    dataScanner.stopScanning()

                    print("Scanning stopped because sheet is shown")
                }

            default: break
            }
        }

    }
    private func modelText() {
        // Ensure this is called on the main thread for UI updates
        DispatchQueue.main.async {
            do {
                // Initialize the model with a configuration
                let mlModel = try TextClassifierModel(configuration: MLModelConfiguration()).model
                let customModel = try NLModel(mlModel: mlModel)
                let text = TextClassifierModelInput(text: self.scanText)

                // Use the text classifier model to get the most likely label
                if let label = customModel.predictedLabel(for: text.text.lowercased().replacingOccurrences(of: "[^a-z0-9]", with: " ", options: .regularExpression)) {
                    // Safely unwrap the label and process it
                    self.labelPrediction = label
                    print("Text scanned: \(text.text)")
                    print("Most likely label: \(label)")
                    print("labelPrediction: \(self.labelPrediction)")

                } else {
                    // Handle the case where no label is found
                    self.labelPrediction = "No label found"

                    print("No label found for the text.")
                }

                // Get multiple possible labels with their associated confidence scores
                let labelHypotheses = customModel.predictedLabelHypotheses(for: text.text, maximumCount: 3)
                print("Label confidence scores: \(labelHypotheses)")
                print("-----------------------------------------------------\n")

            } catch {
                // Handle errors
                self.labelPrediction = "Model Error: \(error.localizedDescription)"
            }
        }
    }

    //    private func modelText() {
    //        // Ensure this is called on the main thread for UI updates
    //        DispatchQueue.main.async {
    //            do {
    //                // Initialize the model with a configuration
    //                let configuration = MLModelConfiguration()
    //                let model = try TextClassifierModel(configuration: configuration)
    //
    //                // Prepare the input
    //                let input = TextClassifierModelInput(text: self.scanText)
    //                let output = try model.prediction(input: input)
    //
    //                // MARK: Update the label prediction
    //                // TODO: lower cased, remove all symbols
    //
    //                labelPrediction = output.label.lowercased().replacingOccurrences(of: "[^a-z0-9]", with: " ", options: .regularExpression)
    //
    //                print("output \(output.label). labelPrediction \(labelPrediction)")
    //
    //                print(output) // This will show you all properties of the output
    //
    //            } catch {
    //                // Handle errors
    //                labelPrediction = "Model Error: \(error.localizedDescription)"
    //            }
    //        }
    //    }

}
