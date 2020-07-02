//
//  WarningController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 23/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class WarningController: WKInterfaceController {
    @IBOutlet weak var leftGroup: WKInterfaceGroup!
    @IBOutlet weak var rightGroup: WKInterfaceGroup!
    @IBOutlet weak var warningLabel: WKInterfaceLabel!
    @IBOutlet weak var timelbl: WKInterfaceLabel!
    var time =  15;
    var timer = Timer.init()
    
     override func awake(withContext context: Any?) {
            super.awake(withContext: context)
        
    animateDangerLeft()
  timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        if (MusicHelper.sharedHelper.currentSong == "DefeatMusic"){
        MusicHelper.sharedHelper.playBackgroundMusic(Name: "BattleMusic", Path: "/Audio/Themes")
        }

        
    }
    
    override func didDeactivate() {
        timer.invalidate()

    }
    
    @objc func fireTimer() {
        if (time > 0){
        time  -= 1;
        timelbl.setText(String(time) + " Seconds")
        }
        else{
            timer.invalidate()
             self.pushController(withName: "NoChoiceDefeat", context: nil)
        }
        
    }
    
    func animateDangerLeft(){
        animate(withDuration: 0.1, animations: {
           self.leftGroup.setWidth(35);
               self.rightGroup.setWidth(0);
           })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animateDangerRight()
        })
    }
    

    
    func animateDangerRight(){
    animate(withDuration: 0.1, animations: {
    self.leftGroup.setWidth(0);
        self.rightGroup.setWidth(35);
      })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.animateDangerLeft()
        })
    }

}
    

