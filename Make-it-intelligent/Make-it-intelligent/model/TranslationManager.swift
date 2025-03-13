//
//  TranslationManager.swift
//  Make-it-intelligent
//
//  Created by atheer alshareef on 06/03/2025.
//

import NaturalLanguage

class TranslationManager {
    static let shared = TranslationManager()
    
    private let languageRecognizer = NLLanguageRecognizer()
    
    func translate(text: String, to targetLanguage: String, completion: @escaping (String) -> Void) {
        let sourceLanguage = detectLanguage(for: text)
        
        let translationRequest = NSMutableURLRequest(url: URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLanguage)&tl=\(targetLanguage)&dt=t&q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
        
        translationRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: translationRequest as URLRequest) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(text) // فشل الترجمة، نعرض النص الأصلي
                }
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[Any]],
                   let firstArray = jsonArray.first as? [[Any]],
                   let translatedText = firstArray.first as? String {
                    DispatchQueue.main.async {
                        completion(translatedText)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(text) // في حال فشل الترجمة، نعرض النص الأصلي
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(text) // في حال حدوث خطأ، نعرض النص الأصلي
                }
            }
        }
        
        task.resume()
    }
    
    private func detectLanguage(for text: String) -> String {
        languageRecognizer.processString(text)
        guard let language = languageRecognizer.dominantLanguage else { return "en" }
        return language.rawValue
    }
}
