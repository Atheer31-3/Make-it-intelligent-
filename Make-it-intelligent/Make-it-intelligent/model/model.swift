//
//  model.swift
//  ch6
//
//  Created by atheer alshareef on 16/02/2025.
//
import CoreML
import Vision
import Foundation

// استجابة API
struct OpenFoodFactsResponse: Codable {
    let products: [Product]
}

// نموذج المنتج
struct Product: Codable, Identifiable {
    let code: String?  // ✅ إضافة `code` حتى يتم فك التشفير بدون خطأ
    var id: String { code ?? UUID().uuidString }
    let productName: String?
    let imageURL: String?
    let allergens: String?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case imageURL = "image_url"
        case allergens = "allergens"
    }
}

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false

    func fetchProducts(for allergen: String) {
        guard let url = URL(string: "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(allergen)&search_simple=1&action=process&json=true") else {
            print("❌ Invalid URL")
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data, error == nil else {
                print("❌ Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.products = jsonResponse.products
                }
            } catch {
                print("❌ Error parsing JSON: \(error)")
            }
        }.resume()
    }
}



// اللي شغالين عليها
// MARK: - Allergy Model
import CoreML

class AllergyModel {
    var model: random?

    init() {
        DispatchQueue.global(qos: .background).async {
            do {
                let coreMLModel = try random(configuration: MLModelConfiguration())
                DispatchQueue.main.async {
                    self.model = coreMLModel
                }
            } catch {
                print("Failed to load Core ML model: \(error)")
            }
        }
    }

    func predict(text: String, completion: @escaping (String) -> Void) {
        guard let model = model else {
            completion("Model not loaded yet")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let input = randomInput(text: text)
                let prediction = try model.prediction(input: input)
                let result = prediction.label

                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("Error performing ML prediction: \(error)")
                DispatchQueue.main.async {
                    completion("Error analyzing text")
                }
            }
        }
    }
}
