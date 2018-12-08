//
//  VCStart.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-01.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit
import FirebaseAuth



class VCStart: UIViewController {
    
    @IBOutlet weak var usertextField: UITextField!
    
    @IBOutlet weak var passtextField: UITextField!
    
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func signinButtonTapped(_ sender: UIButton) {
        
        if let email = usertextField.text, let password = passtextField.text {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            // if user with email and password is found
            
            if let u = user {
                
            // go to menu
                
                self.performSegue(withIdentifier: "gotoMenu", sender: self)
            }
            
            // else, show error message
                
            else {
                self.performSegue(withIdentifier: "ErrorPopup", sender: self)
            }
        }
        }
        
    }
    
    // exit keyboard if anywhere outside textbox is touched
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        usertextField.resignFirstResponder()
        passtextField.resignFirstResponder()
    }
    
}
