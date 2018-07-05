//
//  EditCharaViewController.swift
//  PrincessGuide
//
//  Created by zzk on 2018/6/29.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit
import Eureka
import Gestalt
import SwiftyJSON
import CoreData

class EditCharaViewController: FormViewController {
    
    let card: Card?
    let context: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    enum Mode {
        case edit
        case create
    }
    
    let mode: Mode
    
    let chara: Chara?
    
    init(card: Card) {
        self.card = card
        mode = .create
        context = CoreDataStack.default.newChildContext(parent: CoreDataStack.default.viewContext)
        chara = Chara(context: context)
        chara?.id = Int32(card.base.unitId)
        parentContext = CoreDataStack.default.viewContext
        super.init(nibName: nil, bundle: nil)
    }
    
    init(chara: Chara) {
        mode = .edit
        context = CoreDataStack.default.newChildContext(parent: CoreDataStack.default.viewContext)
        parentContext = CoreDataStack.default.viewContext
        self.chara = context.object(with: chara.objectID) as? Chara
        card = Card.findByID(Int(chara.id))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let backgroundImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Edit Chara", comment: "")
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChara))
        
        tableView.backgroundView = backgroundImageView
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            let navigationBar = themeable.navigationController?.navigationBar
            navigationBar?.tintColor = theme.color.tint
            navigationBar?.barStyle = theme.barStyle
            themeable.backgroundImageView.image = theme.backgroundImage
            themeable.tableView.indicatorStyle = theme.indicatorStyle
            themeable.tableView.backgroundColor = theme.color.background
            themeable.view.tintColor = theme.color.tint
        }
        
        func cellUpdate<T: RowType, U>(cell: T.Cell, row: T) where T.Cell.Value == U {
            ThemeManager.default.apply(theme: Theme.self, to: cell) { (themeable, theme) in
                themeable.textLabel?.textColor = theme.color.title
                themeable.detailTextLabel?.textColor = theme.color.tint
            }
        }
        
        func cellSetup<T: RowType, U>(cell: T.Cell, row: T) where T.Cell.Value == U {
            cell.selectedBackgroundView = UIView()
            ThemeManager.default.apply(theme: Theme.self, to: cell) { (themeable, theme) in
                themeable.textLabel?.textColor = theme.color.title
                themeable.detailTextLabel?.textColor = theme.color.tint
                themeable.selectedBackgroundView?.backgroundColor = theme.color.tableViewCell.selectedBackground
                themeable.backgroundColor = theme.color.tableViewCell.background
            }
            if let segmentedControl = (cell as? SegmentedCell<U>)?.segmentedControl {
                segmentedControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
            }
        }
        
        func onCellSelection<T>(cell: PickerInlineCell<T>, row: PickerInlineRow<T>) {
            ThemeManager.default.apply(theme: Theme.self, to: cell) { (themeable, theme) in
                themeable.textLabel?.textColor = theme.color.title
                themeable.detailTextLabel?.textColor = theme.color.tint
            }
        }
        
        func onExpandInlineRow<T>(cell: PickerInlineCell<T>, row: PickerInlineRow<T>, pickerRow: PickerRow<T>) {
            pickerRow.cellSetup{ (cell, row) in
                cell.selectedBackgroundView = UIView()
                ThemeManager.default.apply(theme: Theme.self, to: row) { (themeable, theme) in
                    themeable.cell.selectedBackgroundView?.backgroundColor = theme.color.tableViewCell.selectedBackground
                    themeable.cell.backgroundColor = theme.color.tableViewCell.background
                }
            }
            pickerRow.cellUpdate { (cell, row) in
                cell.picker.showsSelectionIndicator = false
                ThemeManager.default.apply(theme: Theme.self, to: row) { (themeable, theme) in
                    themeable.cell.backgroundColor = theme.color.tableViewCell.background
                    themeable.onProvideStringAttributes = {
                        return [NSAttributedStringKey.foregroundColor: theme.color.body]
                    }
                }
            }
        }
        
        form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        
        form
            +++ Section()
            <<< ImageRow(tag: "image")
                .cellSetup { [weak self] (cell, row) in
                    if let card = self?.card {
                        cell.configure(for: card)
                    }
                }
                .cellUpdate(cellUpdate(cell:row:))
            
            +++ Section(NSLocalizedString("Unit", comment: ""))
            
            <<< PickerInlineRow<Int>("unit_level") { (row : PickerInlineRow<Int>) -> Void in
                row.title = NSLocalizedString("Level", comment: "")
                row.displayValueFor = { (rowValue: Int?) in
                    return rowValue.flatMap { String($0) }
                }
                row.options = []
                for i in 0..<ConsoleVariables.default.maxPlayerLevel {
                    row.options.append(i + 1)
                }
                if mode == .create {
                    row.value = ConsoleVariables.default.maxPlayerLevel
                } else {
                    row.value = (chara?.level).flatMap { Int($0) }
                }
                }.cellSetup(cellSetup(cell:row:))
                .cellUpdate(cellUpdate(cell:row:))
                .onCellSelection(onCellSelection(cell:row:))
                .onExpandInlineRow(onExpandInlineRow(cell:row:pickerRow:))
            <<< PickerInlineRow<Int>("unit_rank") { (row : PickerInlineRow<Int>) -> Void in
                row.title = NSLocalizedString("Rank", comment: "")
                row.displayValueFor = { (rowValue: Int?) in
                    return rowValue.flatMap { String($0) }
                }
                row.options = []
                for i in 0..<ConsoleVariables.default.maxEquipmentRank {
                    row.options.append(i + 1)
                }
                if mode == .create {
                    row.value = ConsoleVariables.default.maxEquipmentRank
                } else {
                    row.value = (chara?.rank).flatMap { Int($0) }
                }
                }.cellSetup(cellSetup(cell:row:))
                .cellUpdate(cellUpdate(cell:row:))
                .onCellSelection(onCellSelection(cell:row:))
                .onExpandInlineRow(onExpandInlineRow(cell:row:pickerRow:))
                .onChange { [weak self] (pickerRow) in
                    if let card = self?.card, let row = self?.form.rowBy(tag: "slots") as? SlotRow,
                        let value = pickerRow.value, card.promotions.indices ~= value - 1 {
                        row.cell.configure(for: card.promotions[value - 1], slots: [Bool](repeating: true, count: 6))
                    }
                }
            
            <<< PickerInlineRow<Int>("bond_rank") { (row : PickerInlineRow<Int>) -> Void in
                row.title = NSLocalizedString("Bond Rank", comment: "")
                row.displayValueFor = { (rowValue: Int?) in
                    return rowValue.flatMap { String($0) }
                }
                row.options = []
                for i in 0..<Constant.presetMaxBondRank {
                    row.options.append(i + 1)
                }
                if mode == .create {
                    row.value = Constant.presetMaxBondRank
                } else {
                    row.value = (chara?.bondRank).flatMap { Int($0) }
                }
                }.cellSetup(cellSetup(cell:row:))
                .cellUpdate(cellUpdate(cell:row:))
                .onCellSelection(onCellSelection(cell:row:))
                .onExpandInlineRow(onExpandInlineRow(cell:row:pickerRow:))
            <<< PickerInlineRow<Int>("unit_rarity") { (row : PickerInlineRow<Int>) -> Void in
                row.title = NSLocalizedString("Star Rank", comment: "")
                row.displayValueFor = { (rowValue: Int?) in
                    return rowValue.flatMap { String($0) }
                }
                row.options = []
                for i in 0..<Constant.presetMaxRarity {
                    row.options.append(i + 1)
                }
                if mode == .create {
                    row.value = Constant.presetMaxRarity
                } else {
                    row.value = (chara?.rarity).flatMap { Int($0) }
                }
                }.cellSetup(cellSetup(cell:row:))
                .cellUpdate(cellUpdate(cell:row:))
                .onCellSelection(onCellSelection(cell:row:))
                .onExpandInlineRow(onExpandInlineRow(cell:row:pickerRow:))
            
            +++ Section(NSLocalizedString("Skill", comment: ""))
            
            <<< PickerInlineRow<Int>("skill_level") { (row : PickerInlineRow<Int>) -> Void in
                row.title = NSLocalizedString("Level", comment: "")
                row.displayValueFor = { (rowValue: Int?) in
                    return rowValue.flatMap { String($0) }
                }
                row.options = []
                for i in 0..<ConsoleVariables.default.maxPlayerLevel {
                    row.options.append(i + 1)
                }
                if mode == .create {
                    row.value = ConsoleVariables.default.maxPlayerLevel
                } else {
                    row.value = (chara?.skillLevel).flatMap { Int($0) }
                }
                }.cellSetup(cellSetup(cell:row:))
                .cellUpdate(cellUpdate(cell:row:))
                .onCellSelection(onCellSelection(cell:row:))
                .onExpandInlineRow(onExpandInlineRow(cell:row:pickerRow:))
        
            +++ Section(NSLocalizedString("Equipment", comment: ""))
            
            <<< SlotRow("slots")
                .cellSetup{ [weak self] (cell, row) in
                    cell.selectedBackgroundView = UIView()
                    ThemeManager.default.apply(theme: Theme.self, to: cell) { (themeable, theme) in
                        themeable.textLabel?.textColor = theme.color.title
                        themeable.detailTextLabel?.textColor = theme.color.tint
                        themeable.selectedBackgroundView?.backgroundColor = theme.color.tableViewCell.selectedBackground
                        themeable.backgroundColor = theme.color.tableViewCell.background
                    }
                    if let card = self?.card, let row = self?.form.rowBy(tag: "unit_rank") as? RowOf<Int>,
                        let value = row.value, card.promotions.indices ~= value - 1 {
                        if self?.mode == .create {
                            cell.configure(for: card.promotions[value - 1], slots: [Bool](repeating: true, count: 6))
                        } else {
                            cell.configure(for: card.promotions[value - 1], slots: self?.chara?.slots ?? [Bool](repeating: true, count: 6))
                        }
                    }
                }
            
//            +++ Section()
//            <<< ButtonRow("save") { (row) in
//                row.title = NSLocalizedString("Save", comment: "")
//                }
//                .cellSetup { (cell, row) in
//                    cell.selectedBackgroundView = UIView()
//                    ThemeManager.default.apply(theme: Theme.self, to: cell) { (themeable, theme) in
//                        themeable.textLabel?.textColor = theme.color.title
//                        themeable.detailTextLabel?.textColor = theme.color.tint
//                        themeable.selectedBackgroundView?.backgroundColor = theme.color.tableViewCell.selectedBackground
//                        themeable.backgroundColor = theme.color.tableViewCell.background
//                    }
//                }
//                .onCellSelection { [weak self] (cell, row) in
//                    self?.saveChara()
//                }
        
    }
    
    @objc func saveChara() {
        let values = form.values()
        let json = JSON(values)
        
        chara?.modifiedAt = Date()
        chara?.level = json["unit_level"].int16Value
        chara?.bondRank = json["bond_rank"].int16Value
        chara?.rank = json["unit_rank"].int16Value
        chara?.rarity = json["unit_rarity"].int16Value
        chara?.skillLevel = min(json["unit_level"].int16Value, json["skill_level"].int16Value)
        chara?.slot1 = json["slots"].arrayValue[0].boolValue
        chara?.slot2 = json["slots"].arrayValue[1].boolValue
        chara?.slot3 = json["slots"].arrayValue[2].boolValue
        chara?.slot4 = json["slots"].arrayValue[3].boolValue
        chara?.slot5 = json["slots"].arrayValue[4].boolValue
        chara?.slot6 = json["slots"].arrayValue[5].boolValue
        
        do {
            try context.save()
            try parentContext.save()
        } catch(let error) {
            print(error)
        }
        
        if let vc = navigationController?.viewControllers[1] {
            navigationController?.popToViewController(vc, animated: true)
        }
    }
    
}
