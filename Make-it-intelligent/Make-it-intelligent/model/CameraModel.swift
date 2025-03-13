//
//  cameramodel.swift
//  Make-it-intelligent
//
//  Created by atheer alshareef on 06/03/2025.
//

import AVFoundation
import Vision
import CoreML
import AVFoundation
import Vision
import CoreML

class CameraModel: ObservableObject {
    @Published var scannedText: String = ""
    @Published var allergyResult: String = "Scanning..."
    var session = AVCaptureSession()
    
    let model: randombest

    init() {
        do {
            self.model = try randombest(configuration: MLModelConfiguration())
        } catch {
            fatalError("❌ فشل تحميل المودل: \(error)")
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }
    
    func processScannedText(_ text: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("📸 OCR Scanned Text: \(text)")  // ✅ تحقق مما تم مسحه

            do {
                let input = try randombestInput(product_name: "Unknown", ingredients_text: text)
                let prediction = try self.model.prediction(input: input)

                DispatchQueue.main.async {
                    self.scannedText = text
                    print("📊 Extracted Ingredients for Analysis: \(text)")  // ✅ طباعة النص قبل تحليله
                    self.analyzeAllergyResult(prediction.allergens_tags)
                }
            } catch {
                DispatchQueue.main.async {
                    self.allergyResult = "❌ خطأ في تحليل المكونات"
                }
                print("❌ فشل التنبؤ: \(error)")
            }
        }
    }

    func analyzeAllergyResult(_ detectedAllergens: String) {
        let userAllergies = UserDefaults.standard.array(forKey: "SelectedAllergies") as? [String] ?? []
        let matchedAllergens = userAllergies.filter { detectedAllergens.contains($0) }
        
        if matchedAllergens.isEmpty {
            allergyResult = "✅ المنتج آمن!"
        } else {
            allergyResult = "⚠️ غير آمن! يحتوي على: \(matchedAllergens.joined(separator: ", "))"
        }
    }
}
