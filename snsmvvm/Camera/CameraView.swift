//
//  CameraView.swift
//  snsmvvm
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    var onImageCaptured: () -> Void
    
    // 外部からシャッターを指示するためのバインディング
    @Binding var triggerCapture: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if triggerCapture {
            uiViewController.takePhoto()
            DispatchQueue.main.async {
                self.triggerCapture = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func didCaptureImage(_ image: UIImage) {
            parent.capturedImage = image
            parent.onImageCaptured()
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = .resizeAspectFill
                // 初期フレームを設定
                previewLayer.frame = view.bounds
                view.layer.addSublayer(previewLayer)

                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession.startRunning()
                }
            }
        } catch {
            print("カメラのセットアップに失敗しました: \(error)")
        }
    }

    // 💡 ここが非常に重要です！レイアウトの変化に合わせてプレイヤーのサイズを完全に一致させます
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: imageData) else { return }
        
        // 📸 撮影された画像を「9:16」の比率に自動トリミングする
        let croppedImage = originalImage.cropTo916()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didCaptureImage(croppedImage)
        }
    }
}

// MARK: - 9:16にトリミングするためのUIImage拡張
extension UIImage {
    func cropTo916() -> UIImage {
        let targetRatio: CGFloat = 9.0 / 16.0
        let sourceSize = self.size
        let sourceRatio = sourceSize.width / sourceSize.height
        
        var cropWidth = sourceSize.width
        var cropHeight = sourceSize.height
        
        if sourceRatio > targetRatio {
            // 横長すぎる場合：幅を削る
            cropWidth = sourceSize.height * targetRatio
        } else {
            // 縦長すぎる場合：高さを削る
            cropHeight = sourceSize.width / targetRatio
        }
        
        let cropX = (sourceSize.width - cropWidth) / 2.0
        let cropY = (sourceSize.height - cropHeight) / 2.0
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
