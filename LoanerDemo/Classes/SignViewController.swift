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
    var verify:String = "";var isDateType = false;var validText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    
    func initView() {
        self.view.backgroundColor = UIColor.whiteColor()
        textField = UITextField(frame: CGRectMake(5, 69, self.view.bounds.width - 10, 35))
        textField.layer.borderWidth = 2;textField.layer.cornerRadius = 6
        textField.clearButtonMode = UITextFieldViewMode.Always
        textField.delegate = self;textField.placeholder = "请输入\(self.title!)"
        textField.keyboardType = LoanerHelper.keyboardTypeWithType(verify)!
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.layer.borderColor = UIColor(hex: 0x25b6ed)?.CGColor
        self.view.addSubview(textField)
        textField.becomeFirstResponder()
        textField.addTarget(self, action: "textFieldDidChanged:", forControlEvents: UIControlEvents.EditingChanged)
        if isDateType {
            var datePicker:DatepickerView = DatepickerView(width: self.view.bounds.width)
            datePicker.dateDelegate = self
            textField.inputView = datePicker
        }
        if text != "" {textField.text = text}
        
        tableView = UITableView(frame: CGRectMake(0, 105, self.view.bounds.width , self.view.bounds.height - 110), style: UITableViewStyle.Grouped)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: textCell)
        self.view.addSubview(tableView)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationController?.popViewControllerAnimated(true)
        self.delegate.signTextDidBeDone(self.defaultTexts.objectAtIndex(indexPath.row).description, texts: nil)
    }
    
    //MARK:--UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !self.defaultTexts.containsObject(textField.text) {
            self.defaultTexts.addObject(textField.text)
        }
        self.delegate.signTextDidBeDone(textField.text, texts: defaultTexts)
        self.navigationController?.popViewControllerAnimated(true)
        return true
    }
    
    func textFieldDidChanged(textField:UITextField) {
        let msg = LoanerHelper.vaildInputWith(verify, targetString: textField.text)
        if msg != nil {
            var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
            self.view.addSubview(vaildHud)
            vaildHud.show(true)
            vaildHud.mode = MBProgressHUDMode.Text
            vaildHud.detailsLabelText = msg
            vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
            vaildHud.hide(true, afterDelay: 1)
            self.textField.text = self.validText
        }else {validText = textField.text}

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
