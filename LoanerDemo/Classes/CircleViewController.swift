//
//  CircleViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/6.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController ,PopoverMenuViewDelegate,UIAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate{

    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var msgTextView: UITextView!
    
    var json:JSON = JSON.null
    var menuView : PopoverMenuView!
    
    var label:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewData()
        self.msgTextView.layer.borderColor = UIColor(red: 230.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1).CGColor
        self.msgTextView.layer.borderWidth = 3
        self.msgTextView.layer.cornerRadius = 6
        self.sumLabel.font = UIFont.systemFontOfSize(textFontSize)
        self.msgLabel.font = UIFont.systemFontOfSize(textFontSize)
        self.sumTextField.font = UIFont.systemFontOfSize(detailFontSize)
        self.msgTextView.font = UIFont.systemFontOfSize(detailFontSize)
        
        if self.json.count > 0{
            self.sumTextField.enabled = false
            self.msgTextView.editable = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "操作", style: UIBarButtonItemStyle.Plain, target: self, action: "handleFeedback:")
        }else {
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
            self.view.addGestureRecognizer(tapGesture)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: UIBarButtonItemStyle.Plain, target: self, action: "submitAction:")
            self.msgTextView.delegate = self
            
            let toolBar:UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.width, 35))
            let btn:UIButton = UIButton(type: UIButtonType.Custom)
            btn.frame = CGRectMake(0, 5, 35, 35)
            btn.addTarget(self, action: "hideKeyboard", forControlEvents: UIControlEvents.TouchUpInside)
            btn.setImage(UIImage(named: "hideKeyboard"), forState: UIControlState.Normal)
            toolBar.setItems([UIBarButtonItem(customView: btn)], animated: false)
            self.msgTextView.inputAccessoryView = toolBar
            self.sumTextField.inputAccessoryView = toolBar
            self.sumTextField.delegate = self
            
            label = UILabel(frame: CGRectMake(self.msgTextView.bounds.origin.x + 5, self.msgTextView.bounds.origin.y + 5, self.msgTextView.width - 10, 20))
            label.backgroundColor = UIColor.clearColor()
            label.text = "请输入反馈意见";label.textColor = UIColor.lightGrayColor()
            label.font = UIFont.systemFontOfSize(detailFontSize)
            self.msgTextView.addSubview(label)
        }
    }
    
    func submitAction(sender: AnyObject) {
        self.keyboardHide()
        if self.sumTextField.text == "" {
            let alert:UIAlertView = UIAlertView(title: "错误", message: "请输入建议金额", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
        progressHud.labelText = "正在提交"
        progressHud.show(true)
        
        let user_id:NSString = AppDelegate.app().user_id
        
        let submitDic:NSMutableDictionary = NSMutableDictionary()
        submitDic.setValue(user_id, forKey: "user_id")
        submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id")
        submitDic.setValue(self.sumTextField.text, forKey: "suggest_money")
        submitDic.setValue(self.msgTextView.text, forKey: "remark")
        
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
                    self.sumLabel.text = getCtrText(subJson).0
                    self.sumTextField.text = getCtrText(subJson).1
                }else if title as! String == "remark" {
                    self.msgLabel.text = getCtrText(subJson).0
                    self.msgTextView.text = getCtrText(subJson).1
                }
            }
        }
    }
    
    func keyboardHide() {
        self.sumTextField.resignFirstResponder()
        self.msgTextView.resignFirstResponder()
    }
    
    //MARK: --PopoverMenuViewDelegate
    func menuPopover(menuView: PopoverMenuView!, didSelectMenuItemAtIndex selectedIndex: Int) {
        let user_id:NSString = AppDelegate.app().user_id
        
        let submitDic:NSMutableDictionary = NSMutableDictionary()
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
            let feedbackVC:CircleViewController = CircleViewController()
            feedbackVC.navigationItem.title = "反馈回执"
            self.navigationController?.pushViewController(feedbackVC, animated: true)
            return
        case 2:
            let alert = UIAlertView(title: "警告", message: "不同意业务部建议即将关闭项目！确定关闭？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alert.show()
            return
        default:
            break
        }
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
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
            let submitDic:NSMutableDictionary = NSMutableDictionary()
            submitDic.setValue(user_id, forKey: "user_id")
            submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id")
            self.menuView.dismissMenuPopover()
            let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
            self.view.addSubview(progressHud)
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
    
    //MARK:--UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if !self.label.hidden {
            self.label.hidden = true
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            if self.label.hidden {
                self.label.hidden = false
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    convenience init() {
        let nibNameOrNil = "CircleViewController"
        if NSBundle.mainBundle().pathForResource(nibNameOrNil, ofType: "xib") == nil {
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
