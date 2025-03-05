import AVFoundation
import SwiftUI
import Vision

// Main ContentView
struct tst: View {
    @StateObject private var cameraModel = CameraModel()
    @State private var showSheet: Bool = false
    @State private var selectedLanguage = "en"

    var body: some View {
        NavigationStack {
            ZStack {
                CameraView1(session: cameraModel.session, scannedText: $cameraModel.scannedText)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        // Setting button
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

                        // Languages button
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
                        showSheet.toggle()
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
                    
                    Text(cameraModel.scannedText.isEmpty ? "No text scanned" : cameraModel.scannedText)
                        .presentationDetents([.medium])  // Specify the size of the sheet
                        .padding()
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
}

// View to manage camera session
struct CameraView1: UIViewControllerRepresentable {
    var session: AVCaptureSession
    @Binding var scannedText: String

    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(session: session, scannedText: $scannedText)
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// Camera management and text recognition
class CameraModel: ObservableObject {
    @Published var scannedText: String = ""
    var session = AVCaptureSession()

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
}

// CameraViewController to handle AVCapture session
class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureSession
    @Binding var scannedText: String
    private var previewLayer: AVCaptureVideoPreviewLayer!

    init(session: AVCaptureSession, scannedText: Binding<String>) {
        self.session = session
        _scannedText = scannedText
        super.init(nibName: nil, bundle: nil)
        setupCamera()
        setupPreview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCamera() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))

        if let videoDevice = AVCaptureDevice.default(for: .video) {
            let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
            if let videoInput = videoInput {
                session.addInput(videoInput)
                session.addOutput(videoOutput)
            }
        }
    }

    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = view.layer.bounds
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNRecognizeTextRequest { (request, error) in
            if let results = request.results as? [VNRecognizedTextObservation] {
                let recognizedText = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                DispatchQueue.main.async {
                    self.scannedText = recognizedText.isEmpty ? "No text found" : recognizedText
                }
            }
        }

        request.recognitionLevel = .accurate

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }
}

#Preview {
    tst()
}
