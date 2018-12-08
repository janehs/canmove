//
//  VCScanning.swift
//  CanMove
//
//  Created by Daphne Sze on 2018-11-24.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import Foundation
import UIKit
import MetaWear

class VCScan: UIViewController {
    var devices:[MBLMetaWear]?
    var device1: MBLMetaWear?
    var device2: MBLMetaWear?
    
    @IBOutlet weak var ReadyLabel: UILabel!
    @IBOutlet weak var StartMeasuring: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        MBLMetaWearManager.shared().clearDiscoveredDevices()
        devices = []
        startScanning(true)
        StartMeasuring.isEnabled = false
        ReadyLabel.text = "Please Wait"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        startScanning(false)
    }
    
    func showAlertTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // detect State of "This" device
    func nameForState(_ This:MBLMetaWear) -> String {
        switch This.state {
        case .connected:
            return This.programedByOtherApp ? "Connected (LIMITED)" : "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .discovery:
            return "Discovery"
        }
    }
    
    func startScanning(_ on: Bool) {
        
        if on {
            var SCount:Int = self.devices?.count ?? 0
            MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true, handler: { array in
                self.devices = array
                SCount = self.devices?.count ?? 0
                if SCount == 0{
                    print("no devices")
                }else if SCount == 1{
                    self.device1 = self.devices![0]
                    print(self.device1!.identifier)
                    let State1 = self.nameForState(self.device1!)
                    print(State1)
                }else {
                    self.device1 = self.devices![0]
                    self.device2 = self.devices![1]
                    print(self.device1!.identifier)
                    var State1 = self.nameForState(self.device1!)
                    print(State1)
                    print(self.device2!.identifier)
                    var State2 = self.nameForState(self.device2!)
                    print(State2)
                    MBLMetaWearManager.shared().stopScan()
                    self.device1!.resetDevice()
                    self.device2!.resetDevice()
                    self.setConnecting{ () -> () in
                        State1 = self.nameForState(self.device1!)
                        State2 = self.nameForState(self.device2!)
                        if (State1 != "Connected")||(State2 != "Connected"){
                            print("trying again")
                            self.Disconnect{ () -> () in
                                self.device1!.resetDevice()
                                self.device2!.resetDevice()
                                self.setConnecting{ () -> () in
                                    self.StartMeasuring.isEnabled = true
                                    self.ReadyLabel.text = "Ready!"
                                }
                            }
                        }else{
                            self.StartMeasuring.isEnabled = true
                            self.ReadyLabel.text = "Ready!"
                        }
                    }
                }
            })
        }else {
            MBLMetaWearManager.shared().stopScan()
            print("Stop Scan")
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
    
    
    func setConnecting(completion: @escaping () -> ()) {
        let group = DispatchGroup()
        print("connecting device 1")
        group.enter()
        device1!.connect(withTimeoutAsync: 15).continueOnDispatch { t in
            if (t.error?._domain == kMBLErrorDomain) && (t.error?._code == kMBLErrorOutdatedFirmware) {
                print("firmware error")
            }
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            } else {
                let State1 = self.nameForState(self.device1!)
                print("ID: \(self.device1!.identifier.uuidString) MAC: \(self.device1!.mac ?? "N/A") Status: \(State1)")
            }
            group.leave()
            return nil
        }
        print("connecting device 2")
        group.enter()
        device2!.connect(withTimeoutAsync: 15).continueOnDispatch { t in
            if (t.error?._domain == kMBLErrorDomain) && (t.error?._code == kMBLErrorOutdatedFirmware) {
                print("firmware error")
            }
            if t.error != nil {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
            } else {
                let State2 = self.nameForState(self.device2!)
                print("ID: \(self.device2!.identifier.uuidString) MAC: \(self.device2!.mac ?? "N/A") Status: \(State2)")
            }
            group.leave()
            return nil
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VCCalibrate
        {
            let vc = segue.destination as? VCCalibrate
            vc!.device1 = self.device1
            vc!.device2 = self.device2
        }
    }
    
}

