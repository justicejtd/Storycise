//
//  IntroductionController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Yousef Zahra on 11/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class IntroductionController: WKInterfaceController {
    
    
    var player:AVQueuePlayer?
    var imageSet: [UIImage] = []
    var phrasesArray: [String] = []
    
    @IBOutlet weak var txtSubtitles: WKInterfaceLabel!
    @IBOutlet weak var imageViewer: WKInterfaceGroup!
    
    override func awake(withContext context: Any?) {
           super.awake(withContext: context)


        //------------------Load the images------------------------
        let image2 = UIImage(imageLiteralResourceName: "2.TwelveLabors.jpg")
        let image3 = UIImage(imageLiteralResourceName: "3.HisSecondLabor.jpg")
        let image4 = UIImage(imageLiteralResourceName: "4.KillingTheHydra.jpg")
        let image5 = UIImage(imageLiteralResourceName: "5.LakeLerna.jpg")
        let image6 = UIImage(imageLiteralResourceName: "6.HydraGrowling.jpg")
        
       imageSet = [image2, image3, image4, image5, image6]
       
        //---------------Load the text-----------------------------
        
phrasesArray = ["Hercules was given 12 labors..", "His second labor was..", "Killing the Hydra.." , "Approaching lake Lerna..", "Hercules heard the Hydra.." ]
        //--------------------Theme music code-----------------------

   MusicHelper.sharedHelper.playBackgroundMusic(Name: "Soundtrack", Path: "/Audio/Themes")

        
        //--------------------Voice lines player code-----------------------
        // Get the files paths first (Function takes in a path and returns a list of files within it)
        let soundsArray = GetFilesFromFolder(path: "/Audio/Narrator")
        // Arrange them so they play in order
        let sortedArray = soundsArray.sorted { $0.lastPathComponent < $1.lastPathComponent }

        // Create array for to hold the sound
        var audioItems: [AVPlayerItem] = []
        for audioName in sortedArray {
            var audioString = audioName.lastPathComponent
            audioString = audioString.replacingOccurrences(of: ".mp3", with: "")
            // Find the files that hacve the same name underneath the same path
 let path = Bundle.main.path(forResource: audioString, ofType: "mp3", inDirectory: "/Audio/Narrator")!
            let url = URL(fileURLWithPath: path)
            let item = AVPlayerItem(url: url)
            audioItems.append(item)
        }
        print(audioItems.count)
        //Add it to the player
        player = AVQueuePlayer.init(items: audioItems)
        
        
        // Checks if the player has buffered the data and is ready to play
        NotificationCenter.default.addObserver(self,
               selector: #selector(playerItemDidReadyToPlay(notification:)),
               name: .AVPlayerItemNewAccessLogEntry,
               object: player?.currentItem)
        
        // check if the playeritem finished playing (to add delay/change pics)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)

 
        player?.play()

    }
    
    override func didDeactivate() {
        player?.pause()

           NotificationCenter.default.removeObserver(self, name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
           NotificationCenter.default.removeObserver(self, name: .AVPlayerItemNewAccessLogEntry, object: nil)

       }
    
    override func didAppear() {
        super.didAppear()
        let image1 = UIImage(imageLiteralResourceName: "1.HerculesSin.jpg")
        self.imageViewer.setBackgroundImage(image1)
        animate(withDuration: 0.3) {
             self.imageViewer.setAlpha(1.0)
            self.txtSubtitles.setAlpha(1.0)
         }
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
    


    // Send notification that the player is buffered and ready 
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
        self.imageViewer.setAlpha(0.0)
        self.txtSubtitles.setAlpha(0.0)
        
        animate(withDuration: 0.3) {
            self.imageViewer.setAlpha(1.0)
            self.txtSubtitles.setAlpha(1.0)
        }
        
        let backgroundImage = imageSet.first
        let text = phrasesArray.first;
        self.imageViewer.setBackgroundImage(backgroundImage)
        self.txtSubtitles.setText(text)
        if (imageSet.count > 0){
        imageSet.removeFirst()
        }
        
        if (phrasesArray.count>0){phrasesArray.removeFirst() }
        
        else{
            self.player?.pause()
            pushController(withName: "HerculesPreRun", context: nil)
        }

    }
}
