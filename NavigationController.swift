//
//  NavigationController.swift
//  CanMove
//
//  Created by Jane Seo on 2018-11-01.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import UIKit


class NavigationController: UINavigationController, UINavigationControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
}
}
