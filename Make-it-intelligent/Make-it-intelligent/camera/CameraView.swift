// MARK: - Camera & OCR Processing

import SwiftUICore
import SwiftUI
import AVFoundation
import Vision

// her frontend on camera
// MARK: - Camera View
struct CameraView: View {
    @State private var showManageAllergies = false
    @State private var allergiesSet = false
    @State private var showAllergyWarning = false
    @State private var recognizedText: String = ""
    @State private var scanResult: String = ""
    @State private var selectedLanguage = "en"
    let ocrProcessor = OCRProcessor()
    let allergyModel = AllergyModel()

    var body: some View {
        ZStack {
            CameraPreview(ocrProcessor: ocrProcessor, recognizedText: $recognizedText, scanResult: $scanResult, allergyModel: allergyModel)
                .edgesIgnoringSafeArea(.all)
            VStack {
                      // 🔹 زر الإعدادات وزر تغيير اللغة
                      HStack {
                          Button(action: {
                              showManageAllergies = true
                          }) {
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
                      
                      // 🔹 إشعار إدارة الحساسية
                      if !allergiesSet {
                          AllergyWarningView(showManageAllergies: $showManageAllergies)
                      }
                  }
              }
        .onAppear {
            checkUserAllergies()
        }
        .fullScreenCover(isPresented: $showManageAllergies) {
            ManageScreen()
        }
    }
    
    func checkUserAllergies() {
        if let savedAllergies = UserDefaults.standard.dictionary(forKey: "SelectedAllergies") as? [String: Bool] {
            allergiesSet = savedAllergies.values.contains(true)
        }
        showAllergyWarning = !allergiesSet
    }
}

// MARK: - Scan Result View
struct ScanResultView: View {
    let text: String
    
    var body: some View {
        VStack {
            Text("Recognized Text:")
                .font(.headline)
            ScrollView {
                Text(text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
            }
        }
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
        .padding()
    }
}

// MARK: - OCR Processor
class OCRProcessor {
    func recognizeText(from image: CGImage, completion: @escaping (String) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion("Error in OCR")
                return
            }
            let recognizedText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")
            
            completion(recognizedText)
        }
        request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error performing OCR: \(error)")
                completion("OCR Failed")
            }
        }
    }
}
extension Notification.Name {
    static let ocrDidDetectText = Notification.Name("ocrDidDetectText")
}
// backend camera
// MARK: - Camera Preview Layer
struct CameraPreview: UIViewControllerRepresentable {
    let ocrProcessor: OCRProcessor
    @Binding var recognizedText: String
    @Binding var scanResult: String
    let allergyModel: AllergyModel
    static let captureSession = AVCaptureSession() // تأكد من إعادة استخدام نفس الجلسة

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraPreview

        init(parent: CameraPreview) { self.parent = parent }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()

            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                self.parent.ocrProcessor.recognizeText(from: cgImage) { text in
                    DispatchQueue.main.async {
                        self.parent.recognizedText = text
                        self.parent.allergyModel.predict(text: text) { result in
                            self.parent.scanResult = result
                        }
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()

        // ✅ تأكد من أن الجلسة لم تبدأ من قبل
        if !CameraPreview.captureSession.isRunning {
            CameraPreview.captureSession.sessionPreset = .high

            guard let camera = AVCaptureDevice.default(for: .video) else {
                print("No camera available")
                return controller
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if CameraPreview.captureSession.canAddInput(input) {
                    CameraPreview.captureSession.addInput(input)
                }

                let previewLayer = AVCaptureVideoPreviewLayer(session: CameraPreview.captureSession)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = controller.view.bounds
                controller.view.layer.addSublayer(previewLayer)

                let dataOutput = AVCaptureVideoDataOutput()
                dataOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
                if CameraPreview.captureSession.canAddOutput(dataOutput) {
                    CameraPreview.captureSession.addOutput(dataOutput)
                }

                DispatchQueue.global(qos: .background).async {
                    CameraPreview.captureSession.startRunning()
                }
            } catch {
                print("Error setting up camera: \(error)")
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    static func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

// her small sheet if not slected your Allergy
//اذا بتستخدمونها هنا ديزاينها الشيت الصغيره

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
            
            Button(action: {
                showManageAllergies = true
            }) {
                Text("Go to Manage")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                    .shadow(radius: 5)
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
