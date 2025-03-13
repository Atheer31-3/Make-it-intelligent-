//
//  s.swift
//  Make-it-intelligent
//
//  Created by atheer alshareef on 06/03/2025.
//
import AVFoundation
import SwiftUI
import Vision


// View to manage camera session
import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    var session: AVCaptureSession
    @Binding var scannedText: String

    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(session: session, scannedText: $scannedText)
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

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
}
