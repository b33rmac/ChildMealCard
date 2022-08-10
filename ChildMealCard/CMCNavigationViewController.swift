//
//  CMCNavigationViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/12.
//

import UIKit

class CMCNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

}
