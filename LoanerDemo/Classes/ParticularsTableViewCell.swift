//
//  ParticularsTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/17.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol TableViewCellTextFieldDelegate {
    func catchTextFieldvalue(value:String ,key:String)
    func signEditingTextField(textfield:UITextField)
}

class ParticularsTableViewCell: UITableViewCell ,UIActionSheetDelegate,UITextFieldDelegate,DatePickerViewDateDelegate{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgTextField: UITextField!
    
    var itemInfo:tableItemInfo!
    
    var superView:UIViewController!
    var textDelegate:TableViewCellTextFieldDelegate!
    
    
    init(title:String, forjson json:JSON){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "particularsCell")
        //self = NSBundle.mainBundle().loadNibNamed("ParticularsTableViewCell", owner: nil, options: nil).lasta
        //super.
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.itemInfo = tableItemInfo(title: title, forjson: json)
        self.initViewInfomation()
    }
    
    
    //MARK:--UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        self.textDelegate.signEditingTextField(textField)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch self.itemInfo.type {
        case "select":
            switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                var alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                var cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(cancelAction)
                for key in self.itemInfo.options {
                    var selectAction = UIAlertAction(title: "\(key)", style: UIAlertActionStyle.Default, handler: {(_) in
                        self.msgTextField.text = key as! String
                        self.textDelegate.catchTextFieldvalue(textField.text, key: self.itemInfo.title as String)
                    })
                    alertController.addAction(selectAction)
                }
                self.superView.presentViewController(alertController, animated: true, completion: nil)
            case .OrderedAscending:
                var selectSheet:UIActionSheet = UIActionSheet()
                selectSheet.delegate = self
                for key in self.itemInfo.options {
                    selectSheet.addButtonWithTitle(key as! String)
                }
                selectSheet.addButtonWithTitle("取消")
                selectSheet.cancelButtonIndex = selectSheet.numberOfButtons - 1
                selectSheet.showInView(self.superView.view)
            }
            return false
        default:
            return true
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textDelegate.catchTextFieldvalue(textField.text, key: self.itemInfo.title as String)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:--UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > self.itemInfo.options.count - 1{
            return
        }
        self.msgTextField.text = self.itemInfo.options[buttonIndex] as! String
        textDelegate.catchTextFieldvalue(msgTextField.text, key: self.itemInfo.title as String)
    }
    
    //MARK:--DatePickerViewDateDelegate
    func datePickerDidEnsure(date: String) {
        self.msgTextField.text = date
        self.msgTextField.resignFirstResponder()
        textDelegate.catchTextFieldvalue(date, key: self.itemInfo.title as String)
    }
    
    func datePickerDidCancel() {
        self.msgTextField.resignFirstResponder()
    }
    
    func initViewInfomation() {
        self.titleLabel.text = self.itemInfo.explain as String
        if self.itemInfo.type.isEqualToString("datepicker") {
            var datePicker:DatepickerView = DatepickerView(width: self.bounds.width)
            datePicker.dateDelegate = self
            self.msgTextField.inputView = datePicker
        }
        if self.itemInfo.value != "" {
            self.msgTextField.text = self.itemInfo.value as String
            self.msgTextField.enabled = false
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        println("2")
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
