//
//  RunController.swift
//  FitnessApp WatchKit Extension
//
//  Created by Elahe on 11/06/2020.
//  Copyright © 2020 Yousef Zahra. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation
import HealthKit
import CoreLocation
import os.log

class RunController: WKInterfaceController, CLLocationManagerDelegate {

    //coorsinates
    var locManger = CLLocationManager()
    var startingPoint : CLLocation!
    var endingPoint : CLLocation!
    var distanceBetween : CLLocationDistance!
    //

    @IBOutlet weak var min: WKInterfaceImage!
    
    @IBOutlet weak var sec: WKInterfaceImage!
    
    @IBOutlet weak var TimerLable: WKInterfaceLabel!

    @IBOutlet weak var Tmin: WKInterfaceLabel!
    @IBOutlet weak var Tsec: WKInterfaceLabel!
    @IBOutlet weak var pointers: WKInterfaceLabel!
    
    @IBOutlet weak var Info: WKInterfaceLabel!
    
    
    var minute = 0
    var second = 2
    
    var timer = Timer()
    
    func runTimer() {
         timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(RunController.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer(){
//           min.setImageNamed("min")
//           min.startAnimatingWithImages(in: NSMakeRange(0, 5), duration:60, repeatCount: 4)
//        sec.setImageNamed("sec")
//           sec.startAnimatingWithImages(in: NSMakeRange(0, 59), duration:1, repeatCount: 59*4)
        
        if ((second == 0) && (minute == 0)) {
            Tsec.setHidden(true)
            Tmin.setHidden(true)
            pointers.setHidden(true)
            Info.setHidden(false)

            endingPoint = locManger.location
            //endingPoint = CLLocation(latitude: 00.05, longitude: 00.0)
            
            if (startingPoint != nil) {
                if (endingPoint != nil) {
                os_log("Starting point: %@, Ending point: %@", startingPoint, endingPoint)
                distanceBetween = startingPoint.distance(from: endingPoint).rounded()
                
                Info.setText(String(distanceBetween)+" Meters")
                    
                }
                else{
                    print("failed. ending ponit is nil")
                }

            }
            else{
                print("failed. starting point is nil")
            }


        }
        else{
            Info.setHidden(false)

        if(second <= 0){
            minute = minute-1
            Tmin.setText(String(minute))
            second = 60

        }
        else{
            second -= 1
            Tsec.setText(String(second))
        }
    }
    }
    
    
   // let healthStore = HKHealthStore()

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        locManger.delegate = self
       locManger.requestWhenInUseAuthorization()
    
//        self.stepCounter()
        // Configure interface objects here.
        //set starting location
        startingPoint = locManger.location

        //startingPoint = CLLocation(latitude: 00.0, longitude: 00.0)
 
        //
        
        //timer
        runTimer()
//timer visuals

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        

        
    }
    
//    func autorize(){
//
//            let read = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
//            let share = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
//
//        healthStore.requestAuthorization(toShare: share, read:read ){ (check,error) in
//            if(check){
//                print("granted")
//            }
//        }
//
//            }
//
//    func stepCounter(){
//        guard  let sampleType = HKObjectType.quantityType(forIdentifier: .stepCount)else{
//            return
//        }
//
//        let startDate = Calendar.current.date(byAdding: .month,value: -1, to: Date())
//
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
//
//        let sortDesciptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//
//        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDesciptor]){(sample, result, error) in
//            guard error == nil else{
//                return
//        }
//
//            let data = result![0] as! HKQuantitySample
//            let unit = HKUnit(from: "count/min")
//            let l = data.quantity.doubleValue(for: unit)
//            print(l)
//
//        }
//        healthStore.execute(query)
//
//
//    }

}
