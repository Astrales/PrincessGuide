//
//  CDPromotionTableViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/6.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class CDPromotionTableViewController: CDTableViewController {

    override func prepareRows(for card: Card) {
    
        rows = [Row]()
        
        if card.uniqueEquipIDs.count > 0 {
            rows += [Row.uniqueEquipments(card.uniqueEquipIDs)]
        }

        rows += card.promotions.map { Row.promotion($0) }.reversed()
    }
    
}
