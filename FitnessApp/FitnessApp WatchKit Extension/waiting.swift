//
//  waiting.swift
//  FitnessApp WatchKit Extension
//
//  Created by Elahe on 12/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import WatchKit
import Foundation


class LandingController: WKInterfaceController {

    @IBOutlet weak var image: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        image.setImageNamed("step")
        image.startAnimatingWithImages(in: NSMakeRange(0, 100), duration: 0.5, repeatCount: 5)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
