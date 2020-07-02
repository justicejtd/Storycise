//
//  MotionManager.swift
//  FocusMotion WatchKit Extension
//
//  Created by Justice Dreischor on 03/06/2020.
//  Copyright © 2020 Justice Dreischor. All rights reserved.
//

/*Abstract:
 This class manages the CoreMotion interactions and
 provides a delegate to indicate changes in data.
 */

import Foundation
import CoreMotion
import WatchKit
import os.log
import AVFoundation
/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    //    func didUpdateForehandSwingCount(_ manager: MotionManager, forehandCount: Int)
    //    func didUpdateBackhandSwingCount(_ manager: MotionManager, backhandCount: Int)
    func didUpdateMotion (_ manager: MotionManager, userAcellerationZ: Double, userAcellerationY: Double, userAccelerationX: Double)
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

class MotionManager{
    
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    var gravity1 : String = ""
    var rotationRate1 : String = ""
    var userAccel : String = ""
    var attitude : String = ""
    var count : Int = 0
    var sum1 : Double = 0.0
    var mean : Double = 0.0
    var pushCounter = 0.0
    var isInRange : Bool = false
    var themePlayer: AVAudioPlayer?
    
    // MARK: Application Specific Constants
    
    // These constants were derived from data and should be further tuned for your needs.
    let yawThreshold = 1.95 // Radians
    let rateThreshold = 5.5    // Radians/sec
    let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 100// / 50
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    weak var delegate: MotionManagerDelegate?
    
    /// Swing counts.
    var forehandCount = 0
    var backhandCount = 0
    
    var recentDetection = false
    
    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        
        let path = Bundle.main.path(forResource: "HydraPain2.mp3", ofType:nil, inDirectory: "/Audio/SoundEffects")!
        let url = URL(fileURLWithPath: path)
        
        do {
            themePlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Couldnt play background music")
        }
        
    }
    
    // MARK: Motion Manager
    
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        // Reset everything when we start.
        resetAllState()
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: Motion Processing
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        //        let gravity = deviceMotion.gravity
        //        let rotationRate = deviceMotion.rotationRate
        //
        //        let rateAlongGravity = rotationRate.x * gravity.x // r⃗ · ĝ
        //                             + rotationRate.y * gravity.y
        //                             + rotationRate.z * gravity.z
        //        rateAlongGravityBuffer.addSample(rateAlongGravity)
        //
        //        if !rateAlongGravityBuffer.isFull() {
        //            return
        //        }
        //
        //        let accumulatedYawRot = rateAlongGravityBuffer.sum() * sampleInterval
        //        let peakRate = accumulatedYawRot > 0 ?
        //            rateAlongGravityBuffer.max() : rateAlongGravityBuffer.min()
        //
        //        if (accumulatedYawRot < -yawThreshold && peakRate < -rateThreshold) {
        //            // Counter clockwise swing.
        //            if (wristLocationIsLeft) {
        //                incrementBackhandCountAndUpdateDelegate()
        //            } else {
        //                incrementForehandCountAndUpdateDelegate()
        //            }
        //        } else if (accumulatedYawRot > yawThreshold && peakRate > rateThreshold) {
        //            // Clockwise swing.
        //            if (wristLocationIsLeft) {
        //                incrementForehandCountAndUpdateDelegate()
        //            } else {
        //                incrementBackhandCountAndUpdateDelegate()
        //            }
        //        }
        //
        //        // Reset after letting the rate settle to catch the return swing.
        //        if (recentDetection && abs(rateAlongGravityBuffer.recentMean()) < resetThreshold) {
        //            recentDetection = false
        //            rateAlongGravityBuffer.reset()
        //        }
        //
        // 1. These strings are to show on the UI. Trying to fit
        // x,y,z values for the sensors is difficult so we’re
        // just going with one decimal point precision.
        //        gravity1 = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
        //                            deviceMotion.gravity.x,
        //                            deviceMotion.gravity.y,
        //                            deviceMotion.gravity.z)
        //        userAccel = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
        //                           deviceMotion.userAcceleration.x,
        //                           deviceMotion.userAcceleration.y,
        //                           deviceMotion.userAcceleration.z)
        //        rotationRate1 = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
        //                              deviceMotion.rotationRate.x,
        //                              deviceMotion.rotationRate.y,
        //                              deviceMotion.rotationRate.z)
        //        attitude = String(format: "r: %.1f p: %.1f y: %.1f" ,
        //                                 deviceMotion.attitude.roll,
        //                                 deviceMotion.attitude.pitch,
        //                                 deviceMotion.attitude.yaw)
        //we need a value to determine when the user is standing up
        // we need a value when the user did a punch
        // state
        //if (deviceMotion.userAcceleration.y >=)
        // 2. Since this is timeseries data, we want to include the
        //    time we log the measurements (in ms since it's
        //    recording every .02s)
        //        var isRangeFoward = true;
        //        var isRangeBackward = false;
        //        let userStartingPointStanding = deviceMotion.userAcceleration.y >= 0 && deviceMotion.userAcceleration.y <= 1 && deviceMotion.userAcceleration.z == 0
        //        var userHasPunch = deviceMotion.gravity.y >= -0.24 && deviceMotion.gravity.y <= -0.35
        //        isRangeBackward = deviceMotion.gravity.y >= -0.17 && deviceMotion.gravity.y <= -0.20
        //        let timestamp = Date().millisecondsSince1970
        // 3. Log this data so we can extract it later
        //        os_log("Motion: y %@, y %@" ,//, z %@, ay %@, az %@, ry %@, rz %@",
        ////               String(timestamp),
        ////               String(deviceMotion.gravity.x),
        //
        //            String(format: "%.2f", deviceMotion.userAcceleration.z),
        //            String(format: "%.2f", deviceMotion.gravity.y))
        //              String(deviceMotion.gravity.z)
        ////               String(deviceMotion.userAcceleration.x),
        //               String(deviceMotion.ç.y),
        //               String(deviceMotion.userAcceleration.z),
        ////               String(deviceMotion.rotationRate.x),
        //               String(deviceMotion.rotationRate.y),
        //               String(deviceMotion.rotationRate.z))
        //               String(deviceMotion.attitude.roll),
        //               String(deviceMotion.attitude.pitch),
        //               String(deviceMotion.attitude.yaw))
        //        // 4. update values in the UI
//        if (count <= 10){
//            sum1 += deviceMotion.userAcceleration.z
//            if (count == 10){
//                mean = sum1 / 10
//                if (isInRange && mean < 0.30){
//                    isInRange = false
//                }
//                os_log("Mean1111111: %@", String(format: "%.2f", mean))
//                if (!isInRange && mean >= 0.30){
//                    pushCounter += 1
//                    os_log("User has push %@", String(pushCounter))
//                    themePlayer?.play()
//                    isInRange = true
//                }
//                count = 0
//                sum1 = 0
//            }
//            else{
//                count += 1
//            }
//            
//        }
        //        if (userHasPunch && isRangeFoward){
        //            count += 1
        //            //var test = "Motion: user has punch \(count)"
        //            os_log("Motion: User has punch %@", String(count))
        //            isRangeFoward = false
        //        }
        //        else if (isRangeBackward){
        //            isRangeFoward = true
        //            isRangeBackward = false
        //        }
        delegate?.didUpdateMotion (self, userAcellerationZ: deviceMotion.userAcceleration.z, userAcellerationY: deviceMotion.userAcceleration.y, userAccelerationX: deviceMotion.userAcceleration.x)
    }
    
    // MARK: Data and Delegate Management
    
    func resetAllState() {
        rateAlongGravityBuffer.reset()
        
        forehandCount = 0
        backhandCount = 0
        recentDetection = false
        
        //        updateForehandSwingDelegate()
        //        updateBackhandSwingDelegate()
    }
    
    //    func incrementForehandCountAndUpdateDelegate() {
    //        if (!recentDetection) {
    //            forehandCount += 1
    //            recentDetection = true
    //
    //            print("Forehand swing. Count: \(forehandCount)")
    //            updateForehandSwingDelegate()
    //        }
    //    }
    //
    //    func incrementBackhandCountAndUpdateDelegate() {
    //        if (!recentDetection) {
    //            backhandCount += 1
    //            recentDetection = true
    //
    //            print("Backhand swing. Count: \(backhandCount)")
    //            updateBackhandSwingDelegate()
    //        }
    //    }
    
    //    func updateForehandSwingDelegate() {
    //        delegate?.didUpdateForehandSwingCount(self, forehandCount:forehandCount)
    //    }
    //
    //    func updateBackhandSwingDelegate() {
    //        delegate?.didUpdateBackhandSwingCount(self, backhandCount:backhandCount)
    //    }
}
