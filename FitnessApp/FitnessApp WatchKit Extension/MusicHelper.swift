//
//  MusicHelper.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 24/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import AVFoundation

class MusicHelper {
static let sharedHelper = MusicHelper()
var audioPlayer: AVAudioPlayer?
    var currentSong: String?

    func playBackgroundMusic(Name: String ,Path: String) {
    let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: Name, ofType: "mp3", inDirectory: Path)!)
    do {
        audioPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.prepareToPlay()
        self.currentSong = Name;
        audioPlayer?.volume = 0.5;
        audioPlayer!.play()
    }
    catch {
        print("Cannot play the file")
    }
    }
    
    
    func GetCurrentSong() -> String{
        return self.currentSong ?? ""
    }
    
    func SetVolume(amount: Float){
        self.audioPlayer?.volume = amount
    }
    
    
    func Stop(){
        if (self.audioPlayer?.isPlaying == true){
        self.audioPlayer?.stop()
    }
    }
    
}
