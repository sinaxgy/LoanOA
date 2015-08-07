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
    func signEditingTextField(textfield:UITextField,cell:DetailTableViewCell)
}


class DetailTableViewCell: UITableViewCell ,UIActionSheetDelegate,UITextFieldDelegate,DatePickerViewDateDelegate{
    
    let disenableTableArray = ["pro_num","pro_title","service_type","loan_period","offline_id","repay_method"]
    var itemInfo:tableItemInfo!
    let labelSize:CGSize = (isIphone ? CGSizeMake(160,40) : CGSizeMake(320,80))
    var editable:Bool! {
        didSet{
            self.initTextField()
        }
    }
    var titleLabel:UILabel!
    var textfield:UITextField!
    var superView:UIViewController!
    var textDelegate:AddTableViewCellTextFieldDelegate!
    
    init(title:String, forjson json:JSON){
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "detailCell")
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.itemInfo = tableItemInfo(title: title, forjson: json)
        self.initView()
    }
    
    func initView() {
        titleLabel = UILabel(frame: CGRectMake(10, self.bounds.height / 2 - 20, labelSize.width, labelSize.height))
        titleLabel.font = UIFont.systemFontOfSize(textFontSize)
        titleLabel.text = "\(self.itemInfo.explain):"
        self.addSubview(titleLabel)
        
        if self.itemInfo.options.count > 0{
            for key in self.itemInfo.options {
                if key as! String == "must" {
                    titleLabel.textColor = UIColor.redColor()
                }
            }
        }
    }
    
    //MARK: -- 文本框设置
    func initTextField(){
        let rect = UIScreen.mainScreen().bounds
        textfield = UITextField(frame: CGRectMake(labelSize.width + 10, self.bounds.height / 2 - textFontSize, rect.width - labelSize.width - 15, labelSize.height - 10))
        textfield.layer.cornerRadius = 6
        textfield.autocorrectionType = UITextAutocorrectionType.No
        textfield.clearButtonMode = UITextFieldViewMode.WhileEditing
        textfield.delegate = self
        textfield.borderStyle = UITextBorderStyle.None
        textfield.layer.borderColor = UIColor.clearColor().CGColor
        textfield.borderStyle = UITextBorderStyle.RoundedRect
        textfield.font = UIFont.systemFontOfSize(detailFontSize)
        textfield.textAlignment = NSTextAlignment.Left
        textfield.keyboardType = UIKeyboardType.Default
        self.textfield.enabled = self.editable
        if self.textfield.enabled {
            textfield.placeholder = "请输入\(self.itemInfo.explain)"
        }
        for table in disenableTableArray {
            if table as String == self.itemInfo.title {
                self.textfield.enabled = false
                self.textfield.textColor = UIColor.grayColor()
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
        self.textDelegate.signEditingTextField(textField,cell:self)
    }
    
    //MARK:-- UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch self.itemInfo.type {
        case "select":
            var selectSheet:UIActionSheet = UIActionSheet()
            selectSheet.delegate = self
            for key in self.itemInfo.options {
                selectSheet.addButtonWithTitle(key as! String)
            }
            selectSheet.addButtonWithTitle("取消")
            selectSheet.cancelButtonIndex = selectSheet.numberOfButtons - 1
            selectSheet.showInView(self.superView.view)
            return false
        default:
            return true
        }
    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.text == "" && textField.leftView != nil {
            textField.layer.borderColor = UIColor.redColor().CGColor
            textField.layer.borderWidth = 3
            return true
        }
        if self.itemInfo.type == "text" && self.itemInfo.options.count > 0 {
            for key in self.itemInfo.options {
                if key as! String != "must" {
                    let msg = LoanerHelper.vaildInputWith(key as! String, targetString: textField.text)
                    if msg != nil {
                        var vaildHud:MBProgressHUD = MBProgressHUD(view: self.superView.view)
                        self.superView.view.addSubview(vaildHud)
                        vaildHud.show(true)
                        vaildHud.mode = MBProgressHUDMode.Text
                        vaildHud.detailsLabelText = msg
                        vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
                        vaildHud.hide(true, afterDelay: 1)
                        textField.layer.borderColor = UIColor.redColor().CGColor
                        textfield.textAlignment = NSTextAlignment.Center
                        textField.layer.borderWidth = 3
                        return true
                    }
                }
            }
        }
        textfield.layer.borderColor = UIColor.clearColor().CGColor
        textfield.textAlignment = NSTextAlignment.Left
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
