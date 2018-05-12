//
//  EDSkillTableViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/11.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

class EDSkillTableViewController: EDTableViewController {

    override func prepareRows() {
        
        rows.removeAll()
        
        enemy.patterns?.forEach {
            rows.append(Row(type: EDPatternTableViewCell.self, data: .pattern($0, enemy)))
        }
        
        if let unionBurst = enemy.unionBurst {
            rows.append(Row(type: EDSkillTableViewCell.self, data: .skill(unionBurst, .unionBurst, enemy.base.unionBurstLevel, nil)))
        }
        
        rows.append(contentsOf:
            enemy.mainSkills
                .enumerated()
                .map {
                    Row(type: EDSkillTableViewCell.self, data: .skill($0.element, .main, enemy.mainSkillLevel(for: $0.element.base.skillId), $0.offset + 1))
            }
        )
        
        rows.append(contentsOf:
            enemy.exSkills
                .enumerated()
                .map {
                    Row(type: EDSkillTableViewCell.self, data: .skill($0.element, .ex, enemy.exSkillLevel(for: $0.element.base.skillId), $0.offset + 1))
            }
        )
    }

}
