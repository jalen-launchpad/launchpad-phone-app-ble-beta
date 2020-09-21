//
//  Posenet.swift
//  phoneapp
//
//  Created by Jalen Gabbidon on 9/7/20.
//  Copyright © 2020 Jalen Gabbidon. All rights reserved.
//

import SwiftUI
import UIKit
import MLKit

class Posenet : NSObject {
    
    let options = PoseDetectorOptions()
    var poseDetector: PoseDetector?
    
    override init() {
        super.init()
        options.detectorMode = PoseDetectorMode.stream
        options.performanceMode = PoseDetectorPerformanceMode.accurate
        poseDetector = PoseDetector.poseDetector(options: options)
    }
        
    func detectPose(image: VisionImage) -> [Pose] {
        var results: [Pose]
        do {
            results = try poseDetector!.results(in: image)
        } catch let error{
            print("Failed to detect pose with error: \(error.localizedDescription)")
            return []
        }
        let detectedPoses = results
        if detectedPoses.isEmpty {
            print("Pose detector returned no results")
            return []
        }
        return detectedPoses
    }
    
    
}
