//
//  JumpingJacksController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Justice Dreischor on 24/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import os.log
import AVFoundation


class JumpingJacksController: WKInterfaceController, WorkoutManagerDelegate {

    // Attributes
    var count : Int = 0
    var rangeCount : Int = 0
    var sum : Double = 0.0
    var mean : Double = 0.0
    var repsCounter : Int = 10
    var isInRange : Bool = false
    var themePlayer: AVAudioPlayer?
    var workoutManager = WorkoutManager()
    
    // Interface components
    @IBOutlet weak var lbCounter: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        let path = Bundle.main.path(forResource: "HydraPain2.mp3", ofType:nil, inDirectory: "/Audio/SoundEffects")!
        let url = URL(fileURLWithPath: path)
        
        do {
            themePlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Couldnt play background music")
        }
        
        workoutManager.delegate = self
        startCountingRepetition()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func startCountingRepetition() {
        workoutManager.startWorkout()
    }
    
    func stopCountingRepetition() {
        workoutManager.stopWorkout()
    }
    
    func didUpdateMotion(_ manager: WorkoutManager, userAcellerationZ: Double, userAcellerationY: Double, userAccelerationX: Double) {
        if (repsCounter != 0){
            if (count <= 10){
                sum += userAcellerationY
                if (count == 10){
                    mean = sum / 10
                    if (isInRange && mean < 1.50){
                        isInRange = false
                    }
                    os_log("Mean222222: %@", String(format: "%.2f", mean))
                    if (!isInRange && mean >= 1.50){
                        //if (rangeCount == 2){
                            themePlayer?.play()
                            repsCounter -= 1
                            os_log("User did jumping jacks %@", String(repsCounter))
                            lbCounter.setText(String(repsCounter))
                            rangeCount = 0
//                        }
//                        else{
//                            rangeCount += 1
//                        }
                            isInRange = true
                    }
                    count = 0
                    sum = 0
                }
                    
                else{
                    count += 1
                }
            }
        }
        else if (repsCounter == 10){
            stopCountingRepetition()

        }
    }
    @IBAction func btnResetOnClick() {
        repsCounter = 10
    }
    
}
