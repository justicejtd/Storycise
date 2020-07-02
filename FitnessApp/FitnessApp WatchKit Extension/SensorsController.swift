//
//  SensorsController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Justice Dreischor on 11/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import os.log

class SensorsController: WKInterfaceController {
    func didUpdateMotion(_ manager: WorkoutManager, userAcellerationZ: Double, userAcellerationY: Double, userAccelerationX: Double) {
        os_log("tesetttttttttttt %@", userAcellerationZ)
    }
    

    // MARK: Properties
    let workoutManager = WorkoutManager()
    var active = false
    var forehandCount = 0
    var backhandCount = 0
    var gravity : String = ""
    var userAccel : String = ""
    var rotationRate : String = ""
    var attitude : String = ""
    
    // MARK: Interface Properties
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var gravityCountLabel: WKInterfaceLabel!
    @IBOutlet weak var userAccelerationCountLabel: WKInterfaceLabel!
    @IBOutlet weak var rotationCountLabel: WKInterfaceLabel!
    @IBOutlet weak var altitudeCountLabel: WKInterfaceLabel!

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //workoutManager.delegate = self
        active = true
        statusLabel.setText("Workout started")
        workoutManager.startWorkout()
        updateLabels()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        active = true

        // On re-activation, update with the cached values.
        updateLabels()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        active = false
    }
    
    // MARK: Interface Bindings
    
    @IBAction func start() {
        statusLabel.setText("Workout started")
        workoutManager.startWorkout()
    }

    @IBAction func stop() {
        statusLabel.setText("Workout stopped")
        workoutManager.stopWorkout()
    }
    
    // MARK: Convenience
    
    func updateLabels() {
        if active {
            func updateLabels() {
                    // The active check is set when we start and stop recording.
                    if active {
                        gravityCountLabel.setText(gravity)
                        userAccelerationCountLabel.setText(userAccel)
                        rotationCountLabel.setText(rotationRate)
                        altitudeCountLabel.setText(attitude)
                    }
            }
        }
    }
    
    // MARK: WorkoutManagerDelegate
    func didUpdateMotion(_ manager: WorkoutManager, gravity1: String, rotationRate: String, userAccel: String, attitude: String) {
//        self.gravity = gravity
//        self.userAccel = userAccel
//        self.rotationRate = rotationRate
//        self.attitude = attitude
//        self.updateLabels();
        os_log("tesetttttttttttt %@", gravity1)
        gravityCountLabel.setText(gravity1)
    }

}
