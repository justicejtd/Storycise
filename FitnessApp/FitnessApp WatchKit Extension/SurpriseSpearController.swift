//
//  SurpriseSpearController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 25/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import WatchKit

class SurpriseSpearController: WKInterfaceController{
    
    @IBAction func next() {
        self.pushController(withName: "ThrowingSpearsScene", context: nil)
    }
    
}
