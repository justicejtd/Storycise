//
//  SelectStoryController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Justice Dreischor on 10/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation


class SelectStoryController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        MusicHelper.sharedHelper.Stop()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
