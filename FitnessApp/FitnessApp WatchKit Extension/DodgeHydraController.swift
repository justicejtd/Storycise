//
//  DodgeHydraController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 24/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import WatchKit
import AVFoundation
import os.log

class DodgeHydraController: WKInterfaceController, WorkoutManagerDelegate{
    
    @IBOutlet weak var warningLabel: WKInterfaceLabel!
    @IBOutlet weak var rightGroup: WKInterfaceGroup!
    @IBOutlet weak var leftGroup: WKInterfaceGroup!
    @IBOutlet weak var lblCount: WKInterfaceLabel!
    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    
    @IBOutlet weak var lblDodged: WKInterfaceLabel!
    @IBOutlet weak var dodgeGroup: WKInterfaceGroup!
    @IBOutlet weak var bottomGroup: WKInterfaceGroup!
    var time =  11;
    var timer = Timer.init()
    var hydraPlayer: AVAudioPlayer?
    var herculesPlayer: AVAudioPlayer?
    
    var count : Int = 0
    var rangeCount : Int = 0
    var sum : Double = 0.0
    var mean : Double = 0.0
    var repsCounter : Int = 0
    var isInRange : Bool = false
    var workoutManager = WorkoutManager()

    
    
    override func didAppear() {
        super.didAppear()
        // Lowering the volume
        MusicHelper.sharedHelper.SetVolume(amount: 0.2)
        
        // Setting up the hydra sounds
        let path = Bundle.main.path(forResource: "HydraAttack.mp3", ofType:nil, inDirectory: "/Audio/DodgingHydra")!
               let url = URL(fileURLWithPath: path)

               do {
                   hydraPlayer = try AVAudioPlayer(contentsOf: url)
               } catch {
                   print("Error playing spear sound effect")
               }
        
        //--------------------------

        // Setting up the hercules sound
        let herculesPath = Bundle.main.path(forResource: "Jumping.mp3", ofType:nil, inDirectory: "/Audio/DodgingHydra")!
               let herculesUrl = URL(fileURLWithPath: herculesPath)

               do {
                   herculesPlayer = try AVAudioPlayer(contentsOf: herculesUrl)
               } catch {
                   print("Error playing spear sound effect")
               }
        
        //--------------------------
        
          timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        if (MusicHelper.sharedHelper.currentSong == "DefeatMusic"){
        MusicHelper.sharedHelper.playBackgroundMusic(Name: "BattleMusic", Path: "/Audio/Themes")
        }
        
        hydraPlayer?.play()
        workoutManager.delegate = self
        startCountingRepetition()
    }
    
    func startCountingRepetition() {
        workoutManager.startWorkout()
    }
    
    func stopCountingRepetition() {
        workoutManager.stopWorkout()
    }
    
     func didUpdateMotion(_ manager: WorkoutManager, userAcellerationZ: Double, userAcellerationY: Double, userAccelerationX: Double) {
            if (repsCounter != 3){
                if (count <= 10){
                    sum += userAcellerationY
                    if (count == 10){
                        mean = sum / 10
                        if (isInRange && mean < 1.50){
                            isInRange = false
                        }
                        if (!isInRange && mean >= 1.50){
                            //if (rangeCount == 2){
                            hydraPlayer?.volume = 0.25
                            herculesPlayer?.play()
                            animateDangerLeft()
                            animateDodge()
                            resetTimer()
                            repsCounter += 1;
                            lblCount.setText(String(repsCounter))
                            hydraPlayer?.volume = 0.70
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
                repsCounter += 1
                timer.invalidate()
                hydraPlayer?.stop()
                MusicHelper.sharedHelper.SetVolume(amount: 0.7)
                self.pushController(withName: "PrePunchScene", context: nil)
            }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }

    func resetTimer(){
        timer.invalidate()
        time = 11;
        startTimer()
    }
    
    @IBAction func DoAJumpingJack() {
        hydraPlayer?.volume = 0.25
        herculesPlayer?.play()
        animateDangerLeft()
        animateDodge()
        resetTimer()
        repsCounter += 1;
        lblCount.setText(String(repsCounter))
        hydraPlayer?.volume = 0.70
        
        if (repsCounter == 3){
            timer.invalidate()
            hydraPlayer?.stop()
            MusicHelper.sharedHelper.SetVolume(amount: 0.7)
            self.pushController(withName: "PrePunchScene", context: nil)

        }
    }
    
    @objc func fireTimer() {
        if (time > 0){
        time  -= 1;
        lblTimer.setText(String(time) + " Seconds")
        }
        else{
            timer.invalidate()
            hydraPlayer?.stop()
             self.pushController(withName: "NoChoiceDefeat", context: nil)
        }
        
    }
    
    
    func animateDangerLeft(){
          animate(withDuration: 0.1, animations: {
             self.leftGroup.setWidth(40);
                 self.rightGroup.setWidth(0);
             })
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
              self.animateDangerRight()
          })
      }
      
      func animateDangerRight(){
      animate(withDuration: 0.1, animations: {
      self.leftGroup.setWidth(0);
          self.rightGroup.setWidth(40);
        })
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animate(withDuration: 0.1, animations: {
                     self.leftGroup.setWidth(0);
                         self.rightGroup.setWidth(0);
                     })          })
      }
    
    
    func animateDodge(){
        lblCount.setHidden(true)
        dodgeGroup.setHidden(false)
        lblDodged.setHidden(false)
        animate(withDuration: 0.4, animations: {
            self.lblDodged.setAlpha(1);
        self.bottomGroup.setHeight(70);
          })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
          self.animate(withDuration: 0.3, animations: {
                   self.bottomGroup.setHeight(0);
                       self.lblDodged.setAlpha(0);
                   })
  
            
            
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.lblDodged.setHidden(true)
                 self.dodgeGroup.setHidden(true)
            self.lblCount.setHidden(false)

              })
    

    }
    
    
    
}
