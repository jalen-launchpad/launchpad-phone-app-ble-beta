//
//  ViewController.swift
//  phoneapp
//
//  Created by Jalen Gabbidon on 9/11/20.
//  Copyright © 2020 Jalen Gabbidon. All rights reserved.
//

import UIKit
import MLKit
import AVFoundation

class ViewController: UIViewController {
    
    var videoPreview = VideoPreview()
    
    
    @IBOutlet var img: UIImageView?
    private lazy var annotationOverlayView: UIView = {
        precondition(isViewLoaded)
        let annotationOverlayView = UIView(frame: .zero)
        annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return annotationOverlayView
    }()
    
    var poseDetect: PoseDetect?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        poseDetect = PoseDetect()
        videoPreview.delegate = self
        // When app enters foreground or background...
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    //
    // Bluetooth Connectivity
    //
    var bleManager = BLEManager()
    
    @IBAction func goodRep() {
        if bleManager.isConnected {
            bleManager.addGoodRep()
        }
        print("Good rep clicked")
    }
    @IBAction func badRep() {
        if bleManager.isConnected {
            bleManager.addBadRep()
        }
        print("Bad rep clicked")
    }
    @IBAction func positiveCoachingTip() {
        if bleManager.isConnected {
            bleManager.sendPositiveCoachingTip(tip: "Great Tempo!")
        }
        print("Positive coaching tip clicked")
    }
    @IBAction func negativeCoachingTip() {
        if bleManager.isConnected {
            bleManager.sendNegativeCoachingTip(tip: "Back straight!")
        }
        print("Negative coaching tip clicked")
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        bleManager.stopAdvertising()
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        bleManager.startAdvertising()
    }
}

extension ViewController: VideoPreviewDelegate {
    
    func captured(sampleBuffer: CMSampleBuffer, height: CGFloat, width: CGFloat) {
        

        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        DispatchQueue.main.sync {
            img?.image = self.convert(cmage: ciimage)
        }
        
        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .front)
        if poseDetect != nil {
            let poses = poseDetect!.detect(image: visionImage, height: height, width: width)
            print("Pose analysis finished")
        }
    }
    
    func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return cameraPosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return cameraPosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            fatalError()
        }
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
}


