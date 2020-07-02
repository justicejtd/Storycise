//
//  PostRunController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 19/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class PostRunController: WKInterfaceController {
    var player:AVQueuePlayer?
    var phrasesArray: [String] = []
    
    
    @IBOutlet weak var lblSubtitles: WKInterfaceLabel!
    @IBOutlet weak var btnBait: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
         super.awake(withContext: context)
        btnBait.setHidden(true)
             phrasesArray = ["Hercules: I see it", "Hercules: I better draw it out.."]
        
          let soundsArray = GetFilesFromFolder(path: "/Audio/PostRunScene")
        
        let sortedArray = soundsArray.sorted { $0.lastPathComponent < $1.lastPathComponent }

                var audioItems: [AVPlayerItem] = []
                for audioName in sortedArray {
                    var audioString = audioName.lastPathComponent
                    audioString = audioString.replacingOccurrences(of: ".mp3", with: "")
         let path = Bundle.main.path(forResource: audioString, ofType: "mp3", inDirectory: "/Audio/PostRunScene")!
                    let url = URL(fileURLWithPath: path)
                    let item = AVPlayerItem(url: url)
                    audioItems.append(item)
                }
                print(audioItems.count)
                //Add it to the player
                player = AVQueuePlayer.init(items: audioItems)
                
                
                NotificationCenter.default.addObserver(self,
                       selector: #selector(playerItemDidReadyToPlay(notification:)),
                       name: .AVPlayerItemNewAccessLogEntry,
                       object: player?.currentItem)
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)

        MusicHelper.sharedHelper.playBackgroundMusic(Name: "BattleMusic", Path: "/Audio/Themes")

         
     }
    
    override func didDeactivate() {
           NotificationCenter.default.removeObserver(self, name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
           NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)

       }
    
    
    override func didAppear() {
          super.didAppear()
          animate(withDuration: 0.3) {
              self.lblSubtitles.setAlpha(1.0)

           }
        player?.play()

      }
    
    
    func GetFilesFromFolder(path:String)->[URL]{
           let fileManager = FileManager.default
           let bundleURL = Bundle.main.bundleURL
           let assetURL = bundleURL.appendingPathComponent(path)
           var contents: [URL] = []
               
           do {
              contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)

             for item in contents
             {
                 print(item.lastPathComponent)
             }
           }
           catch let error as NSError {
             print(error)
           }
           
           return contents
           
       }
    
    @objc func playerItemDidReadyToPlay(notification: Notification) {
    if let _ = notification.object as? AVPlayerItem {

    }
    }
    
    // Add delay between player items
    
    @objc func playerEndedPlaying(_ notification: Notification) {
        
        self.player?.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
        self?.player?.play()
    }
        
        lblSubtitles.setText(phrasesArray.first)
        if (phrasesArray.count>0){phrasesArray.removeFirst() }
        else{
            // setting up attributed text
            
            let font = UIFont.systemFont(ofSize: 27)
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.green
            shadow.shadowBlurRadius = 5

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .shadow: shadow
                
            ]
            let quote = "Objective: Draw the Hydra out"
            let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
            lblSubtitles.setAttributedText(attributedQuote)
            
            btnBait.setHidden(false)
        }

    }
}
