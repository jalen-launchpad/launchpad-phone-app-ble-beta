import AVFoundation
import UIKit

class VideoPreview : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var permissionGranted = false
    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.medium
    weak var delegate: VideoPreviewDelegate?
    private let context = CIContext()

    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] (granted) in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            // The user has explicitly granted permission for media capture
            permissionGranted = true
            break
            
        case .notDetermined:
            // The user has not yet granted or denied permission
            requestPermission()
            break
            
        default:
            // The user has denied permission
            permissionGranted = false
            break
        }
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    
    private func configureSession() {
        guard permissionGranted else {return}
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else {return}
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        guard captureSession.canAddInput(captureDeviceInput) else {return}
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else {return}
        captureSession.addOutput(videoOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Got a frame!")
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

protocol VideoPreviewDelegate : class{
    func captured(image: UIImage)
}

