//
//  HomeCardTableViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/4/27.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class HomeCardTableViewController: SearchableCardTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        
        if Defaults.downloadAtStart {
            check()
        }
    }
    
}
