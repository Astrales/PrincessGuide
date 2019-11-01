//
//  MultipleAction.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/26.
//  Copyright © 2018 zzk. All rights reserved.
//

import Foundation

class MultipleAction: ActionParameter {
    
    override var actionValues: [ActionValue] {
        return [
            ActionValue(initial: String(actionValue2), perLevel: String(actionValue3), key: nil, startIndex: 2)
        ]
    }
    
    override func localizedDetail(of level: Int, property: Property = .zero, style: CDSettingsViewController.Setting.ExpressionStyle = CDSettingsViewController.Setting.default.expressionStyle) -> String {
        switch actionValue1 {
        case 0:
            let format = NSLocalizedString("Modifier: multiple [%@ * HP / max HP] to value %d of effect %d.", comment: "")
            return String(format: format, buildExpression(of: level, roundingRule: nil, style: style, property: property, hasBracesIfNeeded: true), actionDetail2, actionDetail1 % 10)
        case 1:
            let format = NSLocalizedString("Modifier: multiple [%@ * lost HP / max HP] to value %d of effect %d.", comment: "")
            return String(format: format, buildExpression(of: level, roundingRule: nil, style: style, property: property, hasBracesIfNeeded: true), actionDetail2, actionDetail1 % 10)
        case 2:
            let format = NSLocalizedString("Modifier: multiple [%@ * count of defeated enemies] to value %d of effect %d.", comment: "")
            return String(format: format, buildExpression(of: level, roundingRule: nil, style: style, property: property, hasBracesIfNeeded: true), actionDetail2, actionDetail1 % 10)
        case 200..<300:
            let format = NSLocalizedString("Modifier: multiple [%@ * stacks of mark(ID: %d)] to value %d of effect %d.", comment: "")
            return String(format: format, buildExpression(of: level, roundingRule: nil, style: style, property: property, hasBracesIfNeeded: true), Int(actionValue1) % 200, actionDetail2, actionDetail1 % 10)
        default:
            return super.localizedDetail(of: level, property: property, style: style)
        }
    }
    
}
