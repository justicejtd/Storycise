//
//  ExerciseController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Justice Dreischor on 18/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import os.log
import AVFoundation

class ExerciseController: WKInterfaceController, WorkoutManagerDelegate {
    
    // Attributes
    var count : Int = 0
    var sum : Double = 0.0
    var mean : Double = 0.0
    var repsCounter : Int = 5
    var isInRange : Bool = false
    var themePlayer: AVAudioPlayer?
    var workoutManager = WorkoutManager()
    // Interface components

    @IBOutlet weak var bottomGroup: WKInterfaceGroup!
    @IBOutlet weak var lblHit: WKInterfaceLabel!
    @IBOutlet weak var hitGroup: WKInterfaceGroup!
    @IBOutlet weak var lbCounter: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let path = Bundle.main.path(forResource: "HydraPunchPain.mp3", ofType:nil, inDirectory: "/Audio/SoundEffects")!
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
                sum += userAcellerationZ
                if (count == 10){
                    mean = sum / 10
                    if (isInRange && mean < 0.20){
                        isInRange = false
                    }
                    os_log("Mean222222: %@", String(format: "%.2f", mean))
                    if (!isInRange && mean >= 0.20){
                        repsCounter -= 1
                        os_log("User has punch %@", String(repsCounter))
                        lbCounter.setText(String(repsCounter))
                        themePlayer?.stop()
                        themePlayer?.play()
                        animateHit()
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
        
        else if (repsCounter == 0){
            stopCountingRepetition()
            repsCounter -= 1
         /*   btnReset.setHidden(false)
            btnReset.setEnabled(true)*/
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.pushController(withName: "HydraDyingScene", context: nil)
            })
        }
    }

    @IBAction func Punch() {
        themePlayer?.stop()
            repsCounter -= 1
            lbCounter.setText(String(repsCounter))
            themePlayer?.play()
        animateHit()
        
        if (repsCounter == 0){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.pushController(withName: "HydraDyingScene", context: nil)
            })
        }

        }
    
    
    
      func animateHit(){
        lbCounter.setHidden(true)
          hitGroup.setHidden(false)
          lblHit.setHidden(false)
          animate(withDuration: 0.4, animations: {
              self.lblHit.setAlpha(1);
          self.bottomGroup.setHeight(70);
            })
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.animate(withDuration: 0.3, animations: {
                     self.bottomGroup.setHeight(0);
                         self.lblHit.setAlpha(0);
                     })
    
              
              
          })
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                  self.lblHit.setHidden(true)
                   self.hitGroup.setHidden(true)
            self.lbCounter.setHidden(false)

                })
      

      }
}
