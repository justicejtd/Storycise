//
//  PreRunController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 18/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class PreRunController: WKInterfaceController{
    var player:AVQueuePlayer?
    var phrasesArray: [String] = []
    @IBOutlet weak var lblSubtitles: WKInterfaceLabel!
    
    @IBOutlet weak var btnRun: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        btnRun.setHidden(true)
        
        phrasesArray = ["Hercules: What was that?", "Soldier: Hercules" , "Soldier: Did you hear that?", "(Distant growling)", "Hercules: Is that the Hydra? ", "Hercules: I better go check it out.."]
        
         let soundsArray = GetFilesFromFolder(path: "/Audio/PreRunScene")
        
         let sortedArray = soundsArray.sorted { $0.lastPathComponent < $1.lastPathComponent }

               var audioItems: [AVPlayerItem] = []
               for audioName in sortedArray {
                   var audioString = audioName.lastPathComponent
                   audioString = audioString.replacingOccurrences(of: ".mp3", with: "")
        let path = Bundle.main.path(forResource: audioString, ofType: "mp3", inDirectory: "/Audio/PreRunScene")!
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
        self.player?.volume = 0.3
        player?.play()

      }
    

    @IBAction func next() {
        self.pushController(withName: "Run", context: nil)

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
// Slow the dialoug down and speed it up appropriately
        if (phrasesArray.count == 4){
        DispatchQueue.main.asyncAfter(deadline: .now()) {[weak self] in
            self?.player?.play()
        }
        }
        
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
                self?.player?.play()
            }
        }
        if(phrasesArray.count == 3){
            // Hydra sounds, lower volume to sound distant + vibrations
            player?.volume = 0.3
        }
        
        if (phrasesArray.count == 6 || phrasesArray.count == 2){
            player?.volume = 1.0
        }
        
        self.lblSubtitles.setAlpha(0.0)
        
        animate(withDuration: 0.3) {
            self.lblSubtitles.setAlpha(1.0)
        }
        
        let text = phrasesArray.first;
        self.lblSubtitles.setText(text)
  
    
        if (phrasesArray.count>0){phrasesArray.removeFirst() }
        else{
            btnRun.setHidden(false)
            btnRun.setEnabled(true)
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
            let quote = "Objective: Find the Hydra"
            let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
            lblSubtitles.setAttributedText(attributedQuote)
        }


    }
}

