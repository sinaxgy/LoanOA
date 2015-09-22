//
//  FeedbackTableVC.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/22.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

struct FeedbackMsg {
    var explain:String
    var value:String
}

class FeedbackTableVC: UITableViewController ,UIAlertViewDelegate,PopoverMenuViewDelegate,UITextFieldDelegate,UITextViewDelegate{
    
    var json:JSON = JSON.nullJSON
    var menuView : PopoverMenuView!
    var suggestSum:FeedbackMsg = FeedbackMsg(explain: "建议金额", value: "")
    var moreMsg:FeedbackMsg = FeedbackMsg(explain: "备注信息", value: "")
    var editable:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewData()
        
        if self.json.count > 0{
            self.editable = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "操作", style: UIBarButtonItemStyle.Plain, target: self, action: "handleFeedback:")
        }else {
            self.editable = true
            var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
            self.view.addGestureRecognizer(tapGesture)
        }
    }
    
    func loadViewData() {
        if self.json.type == .Dictionary {
            let titlesArray:NSArray = (self.json.object as! NSDictionary).allKeys
            for title in titlesArray {
                let subJson = self.json[title as! String]
                
                func getCtrText(js:JSON) -> (String,String) {
                    let array:NSArray = (js.object as! NSDictionary).allKeys.map({"\($0)"})
                    var explain:String = ""
                    var value:String = ""
                    for key in  array {
                        switch ("\(key)") {
                        case "explain":
                            explain = js.dictionary![key as! String]!.description
                        case "value":
                            value = subJson.dictionary![key as! String]!.description
                        default:
                            break
                        }
                    }
                    return (explain,value)
                }
                
                if title as! String == "dis_price" {
                    self.suggestSum.explain = getCtrText(subJson).0
                    self.suggestSum.value = getCtrText(subJson).1
                }else if title as! String == "remark" {
                    self.moreMsg.explain = getCtrText(subJson).0
                    self.moreMsg.value = getCtrText(subJson).1
                }
            }
        }
    }
    
    func keyboardHide() {
        UITextField.appearance().resignFirstResponder()
        UITextView.appearance().resignFirstResponder()
    }
    
    
    func handleFeedback(sender:UIBarButtonItem) {
        if (self.menuView != nil) {
            self.menuView.dismissMenuPopover()
        }
        var menuItem = ["同意","不同意","关闭项目"]
        if self.title == "业务部反馈" {
            menuItem = ["同意","不同意"]
        }
        self.menuView = PopoverMenuView(frame: CGRectMake(originalX, 70, popverMenuX, CGFloat(menuItem.count) * 44.0), menuItems: menuItem)
        self.menuView.tag = menuItem.count
        self.menuView.menuPopoverDelegate = self
        self.menuView.showInView(self.view)
    }
    
    //MARK: --PopoverMenuViewDelegate
    func menuPopover(menuView: PopoverMenuView!, didSelectMenuItemAtIndex selectedIndex: Int) {
        let user_id:NSString = AppDelegate.app().user_id
        
        var submitDic:NSMutableDictionary = NSMutableDictionary()
        submitDic.setValue(user_id, forKey: "user_id")
        submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id")
        var footerURL:String = ""
        self.menuView.dismissMenuPopover()
        switch selectedIndex {
        case 0:
            footerURL = "agree"
        case 1:
            if menuView.tag == 2 {
                let alert = UIAlertView(title: "警告", message: "不同意业务部建议即将关闭项目！确定关闭？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
                alert.show()
                return
            }
            let feedbackVC:FeedbackTableVC = FeedbackTableVC()
            self.navigationController?.pushViewController(feedbackVC, animated: true)
            return
        case 2:
            let alert = UIAlertView(title: "警告", message: "不同意业务部建议即将关闭项目！\n确定关闭？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alert.show()
            return
        default:
            break
        }
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.labelText = "正在提交"
        progressHud.show(true)
        
        let url = AppDelegate.app().ipUrl + config + "app/" + footerURL
        NetworkRequest.AlamofirePostParametersResponseJSON(url, parameters: ["data":"\(JSON(submitDic))"], success: { (data) -> Void in
            if data == "success" {
                progressHud.labelText = "提交成功"
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.hide(true, afterDelay: 2)
                sleep(2)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }else{
                progressHud.labelText = "提交失败"
                progressHud.hide(true, afterDelay: 1)
            }
        }, failed: { () -> Void in
            
            progressHud.labelText = "提交失败"
            progressHud.hide(true, afterDelay: 1)
        }) { () -> Void in
            
            progressHud.labelText = "提交失败"
            progressHud.hide(true, afterDelay: 1)
        }
        
    }
    
    //MARK:--UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let user_id:NSString = AppDelegate.app().user_id
            var submitDic:NSMutableDictionary = NSMutableDictionary()
            submitDic.setValue(user_id, forKey: "user_id")
            submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id")
            self.menuView.dismissMenuPopover()
            let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.labelText = "正在提交"
            progressHud.show(true)
            
            let url = AppDelegate.app().ipUrl + config + "app/close"
            NetworkRequest.AlamofirePostParametersResponseJSON(url,
                parameters: ["data":"\(JSON(submitDic))"],
                success: { (data) -> Void in
                    if data == "success" {
                        progressHud.labelText = "提交成功"
                        progressHud.mode = MBProgressHUDMode.CustomView
                        progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                        progressHud.hide(true, afterDelay: 2)
                        sleep(2)
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    }else{
                        progressHud.labelText = "提交失败"
                        progressHud.hide(true, afterDelay: 1)
                    }
            }, failed: { () -> Void in
                
            }, outTime: { () -> Void in
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if self.json.count > 0 {
            return 3
        }
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 2 {
            if self.json.count > 0 {
                return 0
            }
        }
        if section == 3 {
            return 0
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return self.view.height / 3
        }
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && self.json.count > 0 {
            return self.view.height * 2 / 3 - 90 - cellHeight - 34
        }
        if section == 3 {
            return self.view.height * 2 / 3 - 120 - cellHeight * 2 - 34
        }
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 30))
        headerView.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/205.0, alpha: 1)
        return headerView
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return self.setupSumCell()
        case 1:
            return self.setupMessageCell()
        case 2:
            return self.setupSubmitCell()
        default:
            return UITableViewCell()
        }
    }
    
    func setupSubmitCell() -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "submitCell")
        var btn:UIButton = UIButton(frame: CGRectMake(0, 0, self.view.width, cellHeight))
        btn.titleLabel?.textAlignment = NSTextAlignment.Center
        btn.setTitle("提交", forState: UIControlState.Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(textFontSize)
        btn.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
        btn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Selected)
        btn.addTarget(self, action: Selector("submitAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        cell.contentView.addSubview(btn)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func setupMessageCell() -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "msgCell")
        var label:UILabel = UILabel(frame: CGRectMake(15, 10, 110, 30))
        label.centerY = cellHeight / 2
        label.text = self.moreMsg.explain + "："
        label.font = UIFont.systemFontOfSize(textFontSize)
        cell.addSubview(label)
        var textView:UITextView = UITextView(frame: CGRectMake(140, 10, self.view.width - 110, self.view.height / 3 - 20))
        textView.text = self.moreMsg.value
        textView.font = UIFont.systemFontOfSize(detailFontSize)
        textView.editable = self.editable
        
        textView.delegate = self
        cell.addSubview(textView)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func setupSumCell() -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "sumCell")
        var label:UILabel = UILabel(frame: CGRectMake(15, 0, 110, 30))
        label.text = self.suggestSum.explain + "："
        label.centerY = cellHeight / 2
        label.font = UIFont.systemFontOfSize(textFontSize)
        cell.addSubview(label)
        var textField:UITextField = UITextField(frame: CGRectMake(140, 0, self.view.width - 120, cellHeight - 20))
        textField.centerY = cellHeight / 2
        textField.text = self.suggestSum.value
        textField.placeholder = "请输入\(self.suggestSum.explain)"
        textField.font = UIFont.systemFontOfSize(detailFontSize)
        textField.enabled = self.editable
        textField.delegate = self
        cell.addSubview(textField)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    func submitAction(sender: AnyObject) {
        self.keyboardHide()
        if self.suggestSum.value == "" {
            let alert:UIAlertView = UIAlertView(title: "错误", message: "请输入建议金额", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.labelText = "正在提交"
        progressHud.show(true)
        
        let user_id:NSString = AppDelegate.app().user_id
        let pro_id = AppDelegate.app().pro_id
        var submitDic:NSMutableDictionary = NSMutableDictionary()
        submitDic.setValue(user_id, forKey: "user_id")
        submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id")
        submitDic.setValue(self.suggestSum.value, forKey: "suggest_money")
        submitDic.setValue(self.moreMsg.value, forKey: "remark")
        
        let url = AppDelegate.app().ipUrl + config + "app/disagree"
        NetworkRequest.AlamofirePostParametersResponseJSON(url, parameters: ["data":"\(JSON(submitDic))"], success: { (data) -> Void in
            if data == "success" {
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.labelText = "提交成功"
                progressHud.hide(true, afterDelay: 2)
                let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                dispatch_after(gcdTimer, dispatch_get_main_queue(), {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                })
            }else {
                progressHud.labelText = "提交失败"
                progressHud.hide(true, afterDelay: 1)
            }
        }, failed: { () -> Void in
            
        }) { () -> Void in
            
        }
    }
    
    //MARK:--UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        self.suggestSum.value = textField.text
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.moreMsg.value = textView.text
    }
}
