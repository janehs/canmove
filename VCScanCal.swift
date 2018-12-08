////
////  VCScanCal.swift
////  CanMove
////
////  Created by Daphne Sze on 2018-11-24.
////  Copyright © 2018 Jane Seo. All rights reserved.
////
//
//import Foundation
//import UIKit
//import MetaWear
//
//
//class ScanCal: UIViewController {
//    var devices:[MBLMetaWear]?
//    var device1: MBLMetaWear?
//    var device2: MBLMetaWear?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        MBLMetaWearManager.shared().clearDiscoveredDevices()
//        devices = []
//        setScanning(true)
//    }
//
//    // detect State of "This" device
//    func nameForState(_ This:MBLMetaWear) -> String {
//        switch This.state {
//        case .connected:
//            return This.programedByOtherApp ? "Connected (LIMITED)" : "Connected"
//        case .connecting:
//            return "Connecting"
//        case .disconnected:
//            return "Disconnected"
//        case .disconnecting:
//            return "Disconnecting"
//        case .discovery:
//            return "Discovery"
//        }
//    }
//
//    func setScanning(_ on: Bool) {
//        if on {
//            MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true, handler: { array in
//                self.devices = array
//            })
//            var SCount:Int = self.devices?.count ?? 0
//            while (SCount < 2){
//                print(SCount)
//                if SCount == 0{
//                    print("no devices")
//                }else if SCount == 1{
//                    device1 = devices![0]
//                    print(device1!.identifier)
//                    let State1 = nameForState(device1!)
//                    print(State1)
//                }else{
//                    device1 = devices![0]
//                    device2 = devices![1]
//                    print(device1!.identifier)
//                    print(device2!.identifier)
//                    let State1 = nameForState(device1!)
//                    print(State1)
//                    let State2 = nameForState(device2!)
//                    print(State2)
//                }
//                SCount = self.devices?.count ?? 0
//            }
//            MBLMetaWearManager.shared().stopScan()
//        } else {
//            MBLMetaWearManager.shared().stopScan()
//            print("Stop Scan")
//        }
//    }
//
//    // CONNECTING
//
//    // Errors when connecting not hud
//
//    func showAlertTitle(_ title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    func setConnecting(_ on: Bool) {
//        if on {
//            print("connecting device 1")
//            device1!.connect(withTimeoutAsync: 15).continueOnDispatch { t in
//                if (t.error?._domain == kMBLErrorDomain) && (t.error?._code == kMBLErrorOutdatedFirmware) {
//                    print("firmware error")
//                    return nil
//                }
//                if t.error != nil {
//                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
//                } else {
//                    let State1 = self.nameForState(self.device1!)
//                    print("ID: \(self.device1!.identifier.uuidString) MAC: \(self.device1!.mac ?? "N/A") Status: \(State1)")
//                }
//                return nil
//            }
//            print("connecting device 2")
//            device2!.connect(withTimeoutAsync: 15).continueOnDispatch { t in
//                if (t.error?._domain == kMBLErrorDomain) && (t.error?._code == kMBLErrorOutdatedFirmware) {
//                    print("firmware error")
//                    return nil
//                }
//                if t.error != nil {
//                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
//                } else {
//                    let State2 = self.nameForState(self.device2!)
//                    print("ID: \(self.device2!.identifier.uuidString) MAC: \(self.device2!.mac ?? "N/A") Status: \(State2)")
//                }
//                return nil
//            }
//        } else {
//            device1!.disconnectAsync().continueOnDispatch { t in
//                if t.error != nil {
//                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
//                }
//                else {
//                    print("disconnected device 1")
//                    let State1 = self.nameForState(self.device1!)
//                    print(self.device1!.identifier, State1)
//                }
//                return nil
//            }
//            self.device2!.disconnectAsync().continueOnDispatch { t in
//                if t.error != nil {
//                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
//                }
//                else {
//                    print("disconnected device 2")
//                    let State2 = self.nameForState(self.device2!)
//                    print(self.device2!.identifier, State2)
//                }
//                return nil
//            }
//        }
//    }
//
//}
