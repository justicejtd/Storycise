//
//  HintController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 24/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import WatchKit

class HintController: InterfaceController{
    override func didAppear() {
        super.didAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.dismiss()
            self.pushController(withName: "Introduction", context: nil)
        })
    }
}
