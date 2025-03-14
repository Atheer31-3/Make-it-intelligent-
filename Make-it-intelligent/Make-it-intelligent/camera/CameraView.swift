
import AVFoundation
import SwiftUI
import Vision
import SwiftUI
import NaturalLanguage
import CoreML

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraModel = CameraModel()
    @State private var showSheet: Bool = false
    @State private var selectedLanguage = "en"
    @State private var allergiesSet = false
    @State private var showAllergyWarning = false
    @State private var showManageAllergies = false
    @State private var storedScannedText: String = ""
    @State private var storedAllergyResult: String = "لم يتم التحليل بعد"

    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview(session: cameraModel.session, scannedText: $cameraModel.scannedText)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        NavigationLink(destination: ManageScreen()) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }

                        Spacer()

                        Button(action: {
                            selectedLanguage = (selectedLanguage == "en") ? "ar" : "en"
                        }) {
                            Text(selectedLanguage == "en" ? "🇬🇧 EN" : "🇸🇦 AR")
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding()
                    Spacer()
                     
                    Button(action: {
                        storedScannedText = cameraModel.scannedText  // ✅ حفظ النص قبل التحليل
                        print("✅ Stored Scanned Text: \(storedScannedText)") // ✅ طباعة المكونات
                        analyzeIngredients(using: storedScannedText)  // 🔹 تحليل المكونات
                        showSheet.toggle()  // فتح الشيت
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .resizable()
                            .padding(10)
                            .frame(width: 80, height: 80)
                            .padding()
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green1, Color.green2]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Circle())
                    }
                }
                .sheet(isPresented: $showSheet) {
                    VStack {
                        Text(storedScannedText.isEmpty ? "No text scanned" : storedScannedText)
                            .font(.body)
                            .padding()

                        Text(storedAllergyResult)
                            .foregroundColor(storedAllergyResult.contains("غير آمن") ? .red : .green)
                            .bold()
                            .padding()
                    }
                }
                
                if !allergiesSet {
                    AllergyWarningView(showManageAllergies: $showManageAllergies)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    let selectedAllergies = UserDefaults.standard.array(forKey: "SelectedAllergies") as? [String] ?? []
                    allergiesSet = !selectedAllergies.isEmpty
                }
            }
            .onAppear {
                cameraModel.startSession()
            }
            .onDisappear {
                cameraModel.stopSession()
            }
            
        }
        
    }

    func analyzeIngredients(using text: String) {
        cameraModel.processScannedText(text)
        storedAllergyResult = cameraModel.allergyResult  // ✅ تحديث النتيجة فورًا
    }
}
// MARK: If user didn't select their allergies
struct AllergyWarningView: View {
    @Binding var showManageAllergies: Bool

    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.6))
                .padding(.bottom, 20)

            Text("Your allergies are not set yet.")
                .font(.headline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Go to settings to customize your allergies")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            
            NavigationLink(destination: ManageScreen()) {
                Text("Go to Settings")
                    .frame(maxWidth: .infinity, maxHeight: 15)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green1, Color.green2]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
    
}
#Preview {
    CameraView()
}
