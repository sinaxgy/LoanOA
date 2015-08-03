//
//  DetailTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol AddTableViewCellTextFieldDelegate {
    func catchTextFieldvalue(value:String ,key:String)
    func signEditingTextField(textfield:UITextField)
}


class DetailTableViewCell: UITableViewCell ,UIActionSheetDelegate,UITextFieldDelegate,DatePickerViewDateDelegate{
    
    let disenableTableArray = ["pro_num","pro_title","service_type","loan_period","offline_id"]
    var itemInfo:tableItemInfo!
    var editable:Bool? {
        didSet{
            self.initTextField()
        }
    }
    var textfield:UITextField!
    var superView:UIViewController!
    var textDelegate:AddTableViewCellTextFieldDelegate!
    
    init(title:String, forjson json:JSON){
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "detailCell")
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.itemInfo = tableItemInfo(title: title, forjson: json)
        self.initView()
    }
    
    init(title:String, twojson:JSON){
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "detailCell")
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.itemInfo = tableItemInfo(value: title, twojson: twojson)
        self.itemInfo.type = "text"
        self.initView()
    }
    
    init(value:String,key:String) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "detailCell")
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.itemInfo = tableItemInfo(value: value, key: key)
        self.initView()
    }
    
    func initView() {
        var titleLabel:UILabel = UILabel(frame: CGRectMake(10, self.bounds.height / 2 - 20, 150, 40))
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.text = self.itemInfo.explain as String
        
        self.addSubview(titleLabel)
        
        //self.initTextField()
    }
    
    //MARK: -- 文本框设置
    func initTextField(){
        let rect = UIScreen.mainScreen().bounds
        textfield = UITextField(frame: CGRectMake(160, self.bounds.height / 2 - 15, rect.width - 160, 30))
        textfield.layer.cornerRadius = 6
        textfield.borderStyle = UITextBorderStyle.RoundedRect
        textfield.autocorrectionType = UITextAutocorrectionType.No
        textfield.clearButtonMode = UITextFieldViewMode.WhileEditing
        textfield.delegate = self
        textfield.borderStyle = UITextBorderStyle.RoundedRect
        textfield.font = UIFont.systemFontOfSize(13)
        textfield.textAlignment = NSTextAlignment.Right
        textfield.keyboardType = UIKeyboardType.Default
        self.textfield.enabled = self.editable!
        for table in disenableTableArray {
            if table as String == self.itemInfo.title {
                self.textfield.enabled = false
                break
            }
        }
        
        if self.itemInfo.type.isEqualToString("datepicker") {
            var datePicker:DatepickerView = DatepickerView(width: self.bounds.width)
            datePicker.dateDelegate = self
            self.textfield.inputView = datePicker
        }
        if self.itemInfo.value != "" {
            self.textfield.text = self.itemInfo.value as String
        }
        self.addSubview(textfield)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.textDelegate.signEditingTextField(textField)
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        self.textDelegate.signEditingTextField(textField)
//    }
    
    //MARK:-- UITextFieldDelegate
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
                        self.textfield.text = key as! String
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex > self.itemInfo.options.count - 1{
            return
        }
        self.textfield.text = self.itemInfo.options[buttonIndex] as! String
        textDelegate.catchTextFieldvalue(textfield.text, key: self.itemInfo.title as String)
    }
    
    func picker(sender:UIDatePicker) {
        var selectedDate:NSDate = sender.date
        var formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var dateString:String = formatter.stringFromDate(selectedDate)
        self.textfield.text = dateString
        textDelegate.catchTextFieldvalue(textfield.text, key: self.itemInfo.title as String)
        //sender.removeFromSuperview()
    }
    
    //MARK:--FeedbackDatePickerViewDateDelegate
    func datePickerDidEnsure(date: String) {
        self.textfield.text = date
        self.textfield.resignFirstResponder()
        textDelegate.catchTextFieldvalue(date, key: self.itemInfo.title as String)
    }
    
    func datePickerDidCancel() {
        self.textfield.resignFirstResponder()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
