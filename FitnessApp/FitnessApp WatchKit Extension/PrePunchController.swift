//
//  PrePunchScene.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 25/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import Foundation
import AVFoundation
import WatchKit

class PrePunchController: WKInterfaceController{
    @IBOutlet weak var lblSubtitles: WKInterfaceLabel!
    var player:AVQueuePlayer?

    @IBOutlet weak var btnBeat: WKInterfaceButton!
    var phrasesArray = [ "Hercules: The Hydra is tired" , "Hercules: Now is my chance!"]
    
    override func awake(withContext context: Any?) {
          super.awake(withContext: context);
        btnBeat.setHidden(true)
            let soundsArray = GetFilesFromFolder(path: "/Audio/PrePunchingScene")
          
          let sortedArray = soundsArray.sorted { $0.lastPathComponent < $1.lastPathComponent }

                       var audioItems: [AVPlayerItem] = []
                       for audioName in sortedArray {
                           var audioString = audioName.lastPathComponent
                           audioString = audioString.replacingOccurrences(of: ".mp3", with: "")
                let path = Bundle.main.path(forResource: audioString, ofType: "mp3", inDirectory: "/Audio/PrePunchingScene")!
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
          animate(withDuration: 0.3) {
               self.lblSubtitles.setAlpha(1.0)
           }
          player?.play()
        
    }
    
    override func didDeactivate() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)

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
            
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
                       self?.player?.play()
                   
                   }
                   
                   animate(withDuration: 0.3) {
                        self.lblSubtitles.setAlpha(1.0)
                    }
                   
                   
                    
                    let text = phrasesArray.first;
                    self.lblSubtitles.setText(text)
                   
                   if (phrasesArray.count>0){phrasesArray.removeFirst() }
                          else{
                       
                              let font = UIFont.systemFont(ofSize: 27)
                              let shadow = NSShadow()
                              shadow.shadowColor = UIColor.green
                              shadow.shadowBlurRadius = 5

                              let attributes: [NSAttributedString.Key: Any] = [
                                  .font: font,
                                  .foregroundColor: UIColor.white,
                                  .shadow: shadow
                                  
                              ]
                              let quote = "Objective: Beat the Hydra"
                              let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
                              lblSubtitles.setAttributedText(attributedQuote)
                              
                              btnBeat.setHidden(false)
                       
                   }
}

}
