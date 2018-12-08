//
//  ViewController.swift
//  CanMove
//
//  Created by Jane Seo on 2018-10-31.
//  Copyright © 2018 Jane Seo. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import StaticDataTableViewController
import MetaWear
import MessageUI
import Bolts
import MBProgressHUD
import iOSDFULibrary
import simd
import Accelerate
import GLKit

class VCMeasuring: UIViewController {
    
    var ref: DatabaseReference!
    var angles = [Double]()
    
    
    
    
/* --------------------------Daphne's sensor variables------------------------------------*/
    
    //Streaming variables
    var device1: MBLMetaWear?
    var device2: MBLMetaWear?
    var sensorFusionData1 = Data()
    var streamingEvents1: Set<NSObject> = [] // Can't use proper type due to compiler seg fault
    var sensorFusionData2 = Data()
    var streamingEvents2: Set<NSObject> = [] // Can't use proper type due to compiler seg fault
    var task1: BFTask<AnyObject>?
    var task2: BFTask<AnyObject>?
 
    // Math variables
    var transVect: double4?
    var rawVect1: double4 = [0.000,0.000,0.000,0.000]
    var rawVect2: double4 = [0.000,0.000,0.000,0.000]
    var VectData1: [double4] = []
    var VectData2: [double4] = []

 /* ---------------------------------------------------------------------------------------*/
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        
        
        
 /* ----------------------Daphne's sensor things (until line 254)---------------------------*/
        SetupStream{ () -> () in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.StartStream()
                })
                        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        device1!.disconnectAsync().continueOnDispatch { t in
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            }
            else {
                print("disconnected device 1")
            }

            return nil
        }

        device2!.disconnectAsync().continueOnDispatch { t in
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            }
            else {
                print("disconnected device 2")
            }

            return nil
        }
        
    }
    
    func showAlertTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    var isObserving1 = false {
        didSet {
            if isObserving1 {
                if !oldValue {
                    self.device1!.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device1!.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }
    var isObserving2 = false {
        didSet {
            if isObserving2 {
                if !oldValue {
                    self.device2!.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device2!.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }
    
    func SetupStream(completion: @escaping () -> ()) {
        // Perform all device specific setup
        print("Setting Device1: ID: \(self.device1!.identifier.uuidString) MAC: \(self.device1!.mac ?? "N/A")")
        print("Setting Device2: ID: \(self.device2!.identifier.uuidString) MAC: \(self.device2!.mac ?? "N/A")")
        
        for device in [self.device1!, device2!]{
            //set to NDoF
            device.sensorFusion!.mode = MBLSensorFusionMode(rawValue: UInt8(1))!
        }
        sensorFusionData1 = Data()
        // Use this array to keep track of all streaming events empty
        streamingEvents1 = []
        sensorFusionData2 = Data()
        // Use this array to keep track of all streaming events empty
        streamingEvents2 = []
        //wipe variables
        rawVect1 = [0.000,0.000,0.000,0.000]
        rawVect2 = [0.000,0.000,0.000,0.000]
        VectData1 = []
        VectData2 = []
        // Listen for state changes
        isObserving1 = true
        isObserving2 = true
        
        print("set up complete")
        completion()
    }
    
    func StartStream(){
        print("Starting Stream")
        streamingEvents1.insert(device1!.sensorFusion!.quaternion)
        print ("insert event 1")
        task1 = device1!.sensorFusion!.quaternion.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.rawVect1 = simd_double4(obj.x, obj.y, obj.z,obj.w)
                self.sensorFusionData1.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
            }
        }
        streamingEvents2.insert(device2!.sensorFusion!.quaternion)
        print ("insert event 2")
        task2 = device2!.sensorFusion!.quaternion.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.rawVect2 = simd_double4(obj.x, obj.y, obj.z,obj.w)
                self.sensorFusionData2.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                if self.rawVect1 != [0,0,0,0] && self.rawVect2 != [0,0,0,0]{
                    print("append vect1:\(self.rawVect1) vect2:\(self.rawVect2)")
                    self.VectData1.append(self.rawVect1)
                    self.VectData2.append(self.rawVect2)
                }
            }
        }
        
        task1?.failure { error in
            // Currently can't recover nicely from this error
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default) { alert in
                self.device1!.resetDevice()
            })
            self.present(alertController, animated: true, completion: nil)
        }
        task2?.failure { error in
            // Currently can't recover nicely from this error
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default) { alert in
                self.device2!.resetDevice()
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func StopStream(completion: @escaping () -> ()){
        isObserving1 = false
        isObserving2 = false
        print(" VectData1: \(self.VectData1.count),VectData2: \(self.VectData2.count) ")
        let group = DispatchGroup()
        for obj in streamingEvents1 {
            if let event = obj as? MBLEvent<AnyObject> {
                group.enter()
                event.stopNotificationsAsync().continueOnDispatch{ t in
                    group.leave()
            }
        }
        }
        for obj in streamingEvents2 {
            if let event = obj as? MBLEvent<AnyObject> {
                group.enter()
                event.stopNotificationsAsync().continueOnDispatch{ t in
                    group.leave()
                }
            }
        }
            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        streamingEvents1.removeAll()
        streamingEvents2.removeAll()
        print("stopped stream")
    }
    
    
    @IBAction func finishMeasure(_ sender: Any) {
        self.StopStream{ () -> () in
            print("stopped Stream")
            for i in 0..<self.VectData1.count{
            let trans = self.transVect!
                let quat1 = self.VectData1[i]
            var quat2 = self.VectData2[i]
            
            quat2 = quat2 + trans
            
            var mag1 = (quat1.w*quat1.w).addingProduct(quat1.x,quat1.x).addingProduct(quat1.y,quat1.y).addingProduct(quat1.z,quat1.z)
            mag1 = sqrt(mag1)
            var mag2 = (quat2.w*quat2.w).addingProduct(quat2.x , quat2.x).addingProduct(quat2.y ,quat2.y).addingProduct(quat2.z,quat2.z)
            mag2 = sqrt(mag2)
            let dotprod = (quat1.w*quat2.w).addingProduct(quat1.x,quat2.x).addingProduct(quat1.y,quat2.y).addingProduct(quat1.z,quat2.z)
            var angleVal = dotprod/(mag1*mag2)
            angleVal = acos(angleVal)*180*2 / Double.pi
            print("angle \(angleVal),  mag1 \(mag1) mag2 \(mag2) dotprod \(dotprod)")
            self.angles.append(angleVal)
        }
/* ---------------------------------------------------------------------------------------*/
        
        // calculate max and min angles and subtract to get range
            
        if let maxangle = self.angles.max(), let minangle = self.angles.min() {
            let range = round(maxangle - minangle)
            print("max: \(maxangle) min: \(minangle) range: \(range)")
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yy HH:mm"
            formatter.timeZone = TimeZone(abbreviation: "EST")
            let timestamp = formatter.string(from: Date())
            
            if let curruser = Auth.auth().currentUser {
                let uid = curruser.uid
                
                self.ref.child("leaderboard/\(uid)/total").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // retreive current total points
                    
                    var total = snapshot.value as! Double
                    print(total)
                    
                    // new total is current total + range
                    
                    total += range
                    
                    // update total
                    
                    self.ref.child("leaderboard").child(uid).updateChildValues(["total": total])
                    
                })
                
                // write to database measurement at timestamp
                
                self.ref.child("measurements/\(uid)/\(timestamp)/").setValue(["measurement": range])
                
                
                // update last login time
                
                self.ref.child("users").child(uid).updateChildValues(["lastLogin": timestamp])
            }
            
        }
        
        // once completed writing to database, segue to result
        
        self.performSegue(withIdentifier: "showResult", sender: self)
        
        }
    }
    
    
}
