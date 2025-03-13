//
//  AllergyModel.swift
//  Make-it-intelligent
//
//  Created by atheer alshareef on 06/03/2025.
//
import CoreML
import Vision
import Foundation
import AVFoundation

// اللي شغالين عليها
// MARK: - Allergy Model

class AllergyModel {
    var model: randombest?
    // استبدل NewModel باسم المودل الجديدة

    init() {
        do {
            self.model = try randombest(configuration: MLModelConfiguration()) // تحميل المودل
        } catch {
            print("❌ Failed to load Core ML model: \(error)")
        }
    }

    func predict(ingredients: String, completion: @escaping (String, String) -> Void) {
        guard let model = model else {
            completion("Model not loaded", "Error")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let input = randombestInput(
                    product_name: "Unknown Product", // ✅ أدخل اسم المنتج هنا
                    ingredients_text: ingredients
                )
                
                let prediction = try model.prediction(input: input)

                // ✅ استخراج `ingredients_text` من المودل
                let extractedAllergens = prediction.allergens_tags

                // ✅ استخراج `allergens_tagsProbability` بأعلى احتمال
                let sortedProbabilities = prediction.allergens_tagsProbability.sorted { $0.value > $1.value }
                let topPrediction = sortedProbabilities.first?.key ?? "Unknown"

                DispatchQueue.main.async {
                    completion(extractedAllergens, topPrediction)
                }
            } catch {
                print("❌ خطأ في تحليل البيانات: \(error)")
            }
        }
    }
}
