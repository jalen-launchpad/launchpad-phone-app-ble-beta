//
//  pose.swift
//  phoneapp
//
//  Created by Jalen Gabbidon on 9/15/20.
//  Copyright © 2020 Jalen Gabbidon. All rights reserved.
//

import Foundation
import AVFoundation
import MLKit

class PoseDetect : NSObject{
    // Fast detection and tracking
    private let poseDetectorQueue = DispatchQueue(label: "com.google.mlkit.pose")
    
    /// The detector used for detecting poses. The pose detector's lifecycle is managed manually, so
    /// it is initialized on-demand via the getter override and set to `nil` when a new detector is
    /// chosen.
    private var _poseDetector: PoseDetector? = nil
    private var poseDetector: PoseDetector? {
        get {
            var detector: PoseDetector? = nil
            poseDetectorQueue.sync {
                if _poseDetector == nil {
                    let options = PoseDetectorOptions()
                    options.detectorMode = .stream
                    options.performanceMode = .accurate;
                    _poseDetector = PoseDetector.poseDetector(options: options)
                }
                detector = _poseDetector
            }
            
            return detector
        }
        set(newDetector) {
            poseDetectorQueue.sync {
                _poseDetector = newDetector
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func detect(image: VisionImage, height: CGFloat, width: CGFloat) -> [Pose] {
        print(image.orientation.rawValue)
        var poses: [Pose]
        if let poseDetector = self.poseDetector {
            do {
                poses = try poseDetector.results(in: image)
                print("Pose detection worked")
            } catch let error {
                print("Pose detection returned with error: \(error.localizedDescription)")
                return []
            }
            guard !poses.isEmpty else {
              print("Pose detector returned no results.")
              return []
            }
            return poses
        } else {
            return []
        }
    }
    
    
}
