//
//  GameOverController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 24/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import WatchKit

class GameOverController: InterfaceController{
    override func didAppear() {
        MusicHelper.sharedHelper.playBackgroundMusic(Name: "DefeatMusic", Path: "/Audio/Themes")
    }
}
