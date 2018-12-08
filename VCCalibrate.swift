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

class VCCalibrate: UIViewController {
    
    var ref: DatabaseReference!
    var angles = [Double]()
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
    var rawVect1: double4 = [0.000,0.000,0.000,0.000]
    var rawVect2: double4 = [0.000,0.000,0.000,0.000]
    var transVect: double4 = [0.000,0.000,0.000,0.000]
    var VectData1: [double4] = []
    var VectData2: [double4] = []
    
    @IBOutlet weak var CalibrateButton: UIButton!
    
    override func viewDidLoad() {
        //jane things
        super.viewDidLoad()
        ref = Database.database().reference()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated:true);
        CalibrateButton.setTitle("Click if Placed", for: .normal)
        
    }
    @IBAction func CalibrateButton(_ sender: UIButton) {
        CalibrateButton.setTitle("Please Wait", for: .normal)
        // Sensor things
        SetupStream{ () -> () in
            print("setup 1")
            self.Calibrate{ () -> () in
                print("calibrated to \(self.transVect)")
                self.performSegue(withIdentifier: "DoneCal", sender: self)
            }
        }
    }
    
    func Disconnect(completion: @escaping () -> ()){
        let group = DispatchGroup()
        group.enter()
        device1!.disconnectAsync().continueOnDispatch { t in
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            }
            else {
                print("disconnected device 1")
            }
            group.leave()
            return nil
        }
        group.enter()
        device2!.disconnectAsync().continueOnDispatch { t in
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            }
            else {
                print("disconnected device 2")
            }
            group.leave()
            return nil
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
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
                print("dev1: \(self.rawVect1) ")
            }
        }
        streamingEvents2.insert(device2!.sensorFusion!.quaternion)
        print ("insert event 2")
        task2 = device2!.sensorFusion!.quaternion.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.rawVect2 = simd_double4(obj.x, obj.y, obj.z,obj.w)
                print("dev2: \(self.rawVect2) ")
                self.sensorFusionData2.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                if self.rawVect1 != [0,0,0,0] && self.rawVect2 != [0,0,0,0]{
                    print("append")
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
    
    func Calibrate(completion: @escaping () -> ()) {
        print("cal start")
        StartStream()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.transVect = self.rawVect1 - self.rawVect2
            self.StopStream{ () -> () in
                print("Cal complete")
                completion()
            }
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VCMeasuring
        {
            let vc = segue.destination as? VCMeasuring
            vc!.device1 = self.device1
            vc!.device2 = self.device2
            vc!.transVect = self.transVect
        }
    }
    
    
}

