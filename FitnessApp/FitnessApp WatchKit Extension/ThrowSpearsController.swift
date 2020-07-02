//
//  ThrowSpearsController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 19/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation
import CoreFoundation
import os.log

class ThrowSpearsController: WKInterfaceController, WorkoutManagerDelegate {
    
    // Attributes
    var count : Int = 0
    var rangeCount : Int = 0
    var sum : Double = 0.0
    var mean : Double = 0.0
    var repsCounter : Int = 0
    var isInRange : Bool = false
    var themePlayer: AVAudioPlayer?
    var workoutManager = WorkoutManager()
    
    // Interface components
    @IBOutlet weak var btnThrow: WKInterfaceButton!
    @IBOutlet weak var lblCount: WKInterfaceLabel!
    @IBOutlet weak var bottomGroup: WKInterfaceGroup!
    @IBOutlet weak var lblHit: WKInterfaceLabel!
    @IBOutlet weak var hitGroup: WKInterfaceGroup!
    var player:AVAudioPlayer?
    var player2:AVAudioPlayer?
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let path = Bundle.main.path(forResource: "SpearPain.mp3", ofType:nil, inDirectory: "/Audio/SoundEffects")!
        let url = URL(fileURLWithPath: path)
        

        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error playing spear sound effect")
        }

        
        workoutManager.delegate = self
        startCountingRepetition()
    }
    
    @IBAction func throwSpear() {
        playSound()
    }
    
    func playSound(){
        if (repsCounter < 3){
            player?.stop()
          repsCounter += 1;
        lblCount.setText(String(repsCounter))
         animateHit()
            player?.play()
        }
        
        if (repsCounter == 3)
        {

            let path2 = Bundle.main.path(forResource: "HydraGrowling2.mp3", ofType:nil, inDirectory: "/Audio/Sound_effects")!
                        let url2 = URL(fileURLWithPath: path2)
              do {
                self.player2 = try AVAudioPlayer(contentsOf: url2)
                 } catch {
                     print("Error playing spear sound effect")
                 }
                self.player2?.play()
                
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.70, execute: {
                self.player2?.stop()
                  self.pushController(withName: "PostThrowingSpears", context: nil)
              })
            repsCounter += 1
        }

    }
    
    func startCountingRepetition() {
        workoutManager.startWorkout()
    }
    
      func animateHit(){
        lblCount.setHidden(true)
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
            self.lblCount.setHidden(false)

                })
      
      }
    
 

    func stopCountingRepetition() {
        workoutManager.stopWorkout()
    }
    
    @objc func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        
    }
    
    func didUpdateMotion(_ manager: WorkoutManager, userAcellerationZ: Double, userAcellerationY: Double, userAccelerationX: Double) {
        if (repsCounter < 3){
            if (count <= 10){
                sum += userAcellerationY
                if (count == 10){
                    mean = sum / 10
                    if (isInRange && mean < 1.10){
                        isInRange = false
                    }
                    if (!isInRange && mean >= 1.10){
                        //if (rangeCount == 2){
                        playSound()
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
        else if (repsCounter == 3){
            stopCountingRepetition()
            playSound()
            os_log("testtest")
//            if(player?.isPlaying == false){
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.70, execute: {
//                    self.pushController(withName: "PostThrowingSpears", context: nil)
//                })
//
//            }
        }
    }
}
