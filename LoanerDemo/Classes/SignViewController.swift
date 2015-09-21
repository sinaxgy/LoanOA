//
//  SignViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/2.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol SignTextDelegate {
    func signTextDidBeDone(text:String,texts:NSArray?)
}

class SignViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,defaultTextDelegate,UITextFieldDelegate,DatePickerViewDateDelegate{
    
    var textField:UITextField!
    var tableView:UITableView!
    var defaultTexts:NSMutableArray = [];var text:String = ""
    let textCell = "textCell";var delegate:SignTextDelegate!
    var verify:String = "";var isDateType = false;var validText = ""    //输入校验预存储，以备恢复
    var comparedInfo:NSDictionary = [:]
    var keyboardHeight:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let info:NSDictionary = notification.userInfo!
        let size:CGSize = info.objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue().size
        self.keyboardHeight = size.height
    }
    
    func initView() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "submit"), style: UIBarButtonItemStyle.Bordered, target: self, action: "complete:")
        self.view.backgroundColor = UIColor.whiteColor()
        textField = UITextField(frame: CGRectMake(0, 64, self.view.bounds.width , 35))
        textField.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/205.0, alpha: 1)
        textField.clearButtonMode = UITextFieldViewMode.Always
        textField.delegate = self;textField.placeholder = "请输入\(self.title!)"
        let leftView:UIView = UIView(frame: CGRectMake(0, 0, 30, 30))
        let imgV:UIImageView = UIImageView(image: UIImage(named: "textFieldInput"))
        imgV.frame = CGRectMake(0, 0, 20, 20);imgV.center = leftView.center
        leftView.addSubview(imgV)
        textField.leftView = leftView
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.keyboardType = LoanerHelper.keyboardTypeWithType(verify)!
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.layer.borderColor = UIColor(hex: mainColor)?.CGColor
        self.view.addSubview(textField)
        textField.becomeFirstResponder()
        textField.addTarget(self, action: "textFieldDidChanged:", forControlEvents: UIControlEvents.EditingChanged)
        if isDateType {
            var datePicker:DatepickerView = DatepickerView(width: self.view.bounds.width)
            datePicker.dateDelegate = self
            textField.inputView = datePicker
        }else {
            var toolBar:UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 35))
            var btn:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            btn.frame = CGRectMake(0, 5, 35, 35)
            btn.addTarget(self, action: "hideKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
            btn.setImage(UIImage(named: "hideKeyboard"), forState: UIControlState.Normal)
            toolBar.setItems([UIBarButtonItem(customView: btn)], animated: false)
            textField.inputAccessoryView = toolBar
        }
        if text != "" {textField.text = text}
        
        tableView = UITableView(frame: CGRectMake(0, 105, self.view.bounds.width , self.view.bounds.height - 110), style: UITableViewStyle.Grouped)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: textCell)
        self.view.addSubview(tableView)
    }
    
    func hideKeyboard() {
        textField.resignFirstResponder()
    }
    
    //MARK:--UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.defaultTexts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(textCell, forIndexPath: indexPath) as! TextTableViewCell
        cell.delegate = self
        cell.titleText = (self.defaultTexts[indexPath.row] as? String)!
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
//
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 30))
//        headerView.backgroundColor = UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/205.0, alpha: 1)
//        return headerView
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.popViewControllerAnimated(true)
        self.delegate.signTextDidBeDone(self.defaultTexts.objectAtIndex(indexPath.row).description, texts: nil)
    }
    
    //MARK:--UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let msg = LoanerHelper.vaildInputWith(verify, targetString: textField.text)
        if msg != nil {
            var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
            self.view.addSubview(vaildHud)
            vaildHud.show(true)
            vaildHud.mode = MBProgressHUDMode.Text
            vaildHud.detailsLabelText = msg
            vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
            vaildHud.yOffset = Float(self.keyboardHeight / 2 - self.view.center.y)
            vaildHud.hide(true, afterDelay: 1)
            return false
        }
        if !self.defaultTexts.containsObject(textField.text) {
            self.defaultTexts.addObject(textField.text)
        }
        self.delegate.signTextDidBeDone(textField.text, texts: defaultTexts)
        self.navigationController?.popViewControllerAnimated(true)
        return true
    }
    
    func textFieldDidChanged(textField:UITextField) {
        if verify == "num" {
            let msg = LoanerHelper.vaildInputWith(verify, targetString: textField.text)
            if msg != nil {
                var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
                self.view.addSubview(vaildHud)
                vaildHud.show(true)
                vaildHud.mode = MBProgressHUDMode.Text
                vaildHud.detailsLabelText = msg
                vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
                vaildHud.yOffset = Float(self.keyboardHeight / 2 - self.view.center.y)
                textField.keyboardAppearance.rawValue
                vaildHud.hide(true, afterDelay: 1)
                self.textField.text = self.validText
            }else {validText = textField.text}
        }
    }
    
    //MARK:--defaultTextDelegate
    func defaultTextShouldBeDelete(text: String) {
        self.defaultTexts.removeObject(text)
        tableView.reloadData()
    }
    
    //MARK:--DatePickerViewDateDelegate
    func datePickerDidEnsure(date: String) {
        self.delegate.signTextDidBeDone(date, texts: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func datePickerDidCancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func complete(sender:AnyObject){
        let msg = LoanerHelper.vaildInputWith(verify, targetString: textField.text)
        if msg != nil {
            var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
            self.view.addSubview(vaildHud)
            vaildHud.show(true)
            vaildHud.mode = MBProgressHUDMode.Text
            vaildHud.detailsLabelText = msg
            vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
            vaildHud.yOffset = Float(self.keyboardHeight / 2 - self.view.center.y)
            vaildHud.hide(true, afterDelay: 1)
            return
        }
        if !self.defaultTexts.containsObject(textField.text) {
            self.defaultTexts.addObject(textField.text)
        }
        self.delegate.signTextDidBeDone(textField.text, texts: defaultTexts)
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
