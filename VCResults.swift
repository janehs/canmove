//
//  Results.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-01.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase

class VCResults: UIViewController {

    @IBOutlet weak var angleLbl: UILabel!
    
    
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        // get path to database
        
        ref = Database.database().reference()
        
        if let curruser = Auth.auth().currentUser {
            
            // retrieve current userID
            
            let uid = curruser.uid
            
            // retrieve last login timestamp
            
            self.ref.child("users/\(uid)/lastLogin").observeSingleEvent(of: .value, with: { (snapshot) in
                let lastlogin = snapshot.value as! String
                print("snapshot taken, last login is \(lastlogin)")
                
                // retrieve measurement/points received during last login
            
                self.ref.child("measurements/\(uid)/\(lastlogin)/measurement").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value{
                        let range = String(describing: value)
                        print("snapshot2 taken, last measurement is \(range)")
                       
                        // display on screen measurement/points received
                    
                        self.angleLbl.text = range
                    }
                    })
                
            })
            
        }
        else {
            print("VCResults: Authentication Failure")
        }
        
        
        
    }

    
}
