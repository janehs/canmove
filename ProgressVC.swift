//
//  ProgressVC.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-10.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseAuth

class ProgressVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var progressTable: UITableView!
    
    var ref: DatabaseReference!
    var handle: DatabaseHandle?
    var ranges_g = [String]()
    var chronology_g = [String]()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ranges_g.removeAll()
        self.chronology_g.removeAll()
        completeFirst{ () -> () in
            
            self.progressTable.reloadData()
            print("completed, reloading data")
            
        }
    }
    
/*
     The function below retrieves all measurements of current user and sorts the measurements in reverse chronological order
*/
    
    func completeFirst(completion: @escaping () -> ()){
        
        ref = Database.database().reference()
        
        print("self.measure: \(self.ranges_g)")
        print("self.time: \(self.chronology_g)")
    
        if let curruser = Auth.auth().currentUser {
            let uid = curruser.uid
            let history = ref.child("measurements/\(uid)")
            var chronology = [String]()
            var ranges = [String]()
            history.observeSingleEvent(of :.value, with: {(snapshot) in
                if snapshot.value != nil{
                    let dict = snapshot.value as! NSDictionary
                    var keys = Array(dict.allKeys)
                    for index in 1...keys.count{
                        keys[index-1] = String(describing: keys[index-1])
                    }
                    chronology = keys as! [String]
                    chronology = chronology.sorted()
                    chronology = chronology.reversed()
                    self.chronology_g += chronology
                    print("within function, c_g:\(self.chronology_g)")
                    for index in 1...keys.count{
                        let date = chronology[index-1]
                        if let range = dict["\(date)"]{
                            let string = String(describing: range)
                            var just_numbers = ""
                            for char in string {
                                if (char == "0") || (char == "1") || (char == "2") || (char == "3") || (char == "4") || (char == "5") || (char == "6") || (char == "7") || (char == "8") || (char == "9"){
                                    just_numbers += String(char)
                                }
                            }
                            ranges.append(just_numbers)
                        }
                    }
                    self.ranges_g += ranges
                    print("within function, r_g:\(self.ranges_g)")
                    completion()
                } else {
                    completion()
                }
                
            })
        }
    }
            
/*
     The two functions below retrieves information from chronology_g and ranges_g arrays
     and displays them cell by cell within the progress table.
*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.ranges_g.count)
        return self.ranges_g.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timestamp = self.chronology_g[indexPath.row]
        let range = self.ranges_g[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell", for: indexPath) as! ProgressCell
        cell.setCell(date: timestamp, range: range)
        
        return cell
    }
    
}

    




