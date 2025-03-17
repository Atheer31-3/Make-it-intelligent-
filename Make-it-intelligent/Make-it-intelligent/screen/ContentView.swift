import SwiftUI
//import UIKit
import VisionKit
//import NaturalLanguage


struct ContentView: View {
    @State private var startScanning = false
    @State private var scanText = ""
    @State private var labelPrediction = ""
    @State private var showAllergyWarning = false
    @State private var showManageAllergies = false
    @State private var showSheet = false
    @State private var selectedLanguage = "en"
    @State private var selectedAllergies: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                DataScanner(startScanning: $startScanning, scanText: $scanText, labelPrediction: $labelPrediction, showSheet: $showSheet)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    // MARK: top menu btns
                    HStack {

                        // Navigate to ManageScreen
                        NavigationLink(destination: ManageScreen()) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .foregroundColor(Color("green2"))
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }

                        Spacer()

                        // Toggle the language
//                        Button(action: {
//                            selectedLanguage = (selectedLanguage == "en") ? "ar" : "en"
//                        }) {
//                            Text(selectedLanguage == "en" ? "🇬🇧 EN" : "🇸🇦 AR")
//                                .padding()
//                                .background(Color.white.opacity(0.8))
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                        }
                    }
                    .padding()

                    Spacer()

                    // Scan btn
                    Button(action: {
                        // start scanning
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            startScanning = true
                        }
                        // write else if not supported
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .resizable()
                            .padding(20)
                            .frame(width: 100, height: 100)
                            .padding(10)
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("green1"), Color("green2")]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Circle())

                    }
                    .padding(.bottom, 30)
                }
                .sheet(isPresented: $showSheet) {

                    VStack {
                        // Show the scanned text
                        Text(scanText.isEmpty ? "No text scanned" : scanText)
                            .font(.body)
                            .padding()

                        // match the scanned text with usr allergy
                        if selectedAllergies.map({ $0.lowercased() }).contains(labelPrediction.lowercased()) {

//                            Text("printing \(selectedAllergies.map { $0.lowercased() }) and \(labelPrediction.lowercased())")
                            Text("Not Safe! ⚠️")
                                .foregroundColor(.red)
                                .bold()
                                .padding()

                            Text("Contains: \(labelPrediction)")
                                .foregroundColor(.red)
                                .padding()

                        } else if !scanText.isEmpty {
                            Text("It's Safe! ✅")
                                .foregroundColor(.green)
                                .bold()
                                .padding()
                        }

                        Button("Scan Again 🔎") {
                            showSheet = false
                            startScanning = true
                        }
                        .padding()
                        .background(Color("green1"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
                //                .task {
                //                    if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                //                        startScanning.toggle()
                //                    }
                //                }

                //  MARK: if user didn't set their allergies
                if showAllergyWarning {
                    VStack {
                        Text("Your allergies are not set yet! 😓")
                            .font(.headline)
                            .padding()

                        Text("Go to settings to customize your allergies")
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)

                        NavigationLink(destination: ManageScreen()) {
                            Text("Go to Settings ⚙️")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("green1"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
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
            .onAppear {
                // update the allergy
                if let savedAllergies = UserDefaults.standard.array(forKey: "SelectedAllergies") as? [String] {
                    selectedAllergies = savedAllergies
                }
                // show the warning if no allergy selectd
                showAllergyWarning = selectedAllergies.isEmpty
            }
        }
    }
    
}



#Preview {
    ContentView()
}
