//
//  VCRegister.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-08.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth


class VCRegister: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var surgeryDate: UIDatePicker!
    
    @IBOutlet weak var userText: UITextField!
    
    @IBOutlet weak var userPass: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var gender: UISegmentedControl!
    
    var ref: DatabaseReference!
    
    var MorF = "M"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        scrollView.keyboardDismissMode = .onDrag
        
        let font = UIFont.systemFont(ofSize: 30)
    gender.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
    }
    
    @IBAction func genderTapped(_ sender: Any) {
        
        if MorF == "M" {
            MorF = "F"
        }
        else {
            MorF = "M"
        }
        
    }
    
    
    @IBAction func regButtonTapped(_ sender: Any) {
        
        let namestring = nameTextField.text
        let agestring = ageTextField.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let datestring = dateFormatter.string(from: surgeryDate.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        let timestamp = formatter.string(from: Date())
        
        let combinedinfo = datestring + agestring!
        
        
        if let email = userText.text, let password = userPass.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let u = user {
                    if let curruser = Auth.auth().currentUser {
                        let uid = curruser.uid
                        self.ref.child("users").child(uid).setValue(["name": namestring, "key": combinedinfo, "lastLogin": timestamp])
                        self.ref.child("leaderboard").child(uid).setValue(["total": 0])
                    }
                    
                    self.performSegue(withIdentifier: "gotoMenu", sender: self)
                    return
                }
                    
                else {
                    
                    print("Failed authentication: \(error).")
                    self.performSegue(withIdentifier: "registeringError", sender: self)
                    
                    return
                    
                }
                
                
            }
            
            
        }
        
    }
    
}







