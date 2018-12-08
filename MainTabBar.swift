//
//  MainTabBar.swift
//  CanMove
//
//  Created by Jane Seo on 2018-12-02.
//  Copyright © 2018 Jane Seo. All rights reserved.
//

import Foundation
import UIKit

class MainTabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)], for: .normal)
    }
}
