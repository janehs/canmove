//
//  VCPlaceSensors.swift
//  CanMove
//
//  Created by Daphne Sze on 2018-11-29.
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

class VCPlaceSensors: UIViewController {
    var device1: MBLMetaWear?
    var device2: MBLMetaWear?
    var transVect: double4?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("\(device1, device2, transVect)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is VCMeasuring
        {
            let vc = segue.destination as? VCMeasuring
            vc!.device1 = self.device1!
            vc!.device2 = self.device2!
            vc!.transVect = self.transVect!
        }
    }
    
}
