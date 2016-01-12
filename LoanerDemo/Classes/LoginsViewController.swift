//
//  LoginsViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/18.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

//let ip = "http://112.126.64.235:8843/"
//let ip = "http://123.57.219.112/loanOA/"  http://10.104.4.153/web/index.php/app/proinfo?pro_id=
//let ip = "http://10.104.4.153/"
let config = "loanOA/web/index.php/"
let loginURL = "app/login"
let readHisURL = "app/getprojects?user_id="
let typeURL = "app/index?type="
let readTableURL = "app/proinfo?pro_id="
let uploadUrl = "app/upload"
class LoginsViewController: UIViewController ,UITextFieldDelegate,personalMessageEditDelegete{
    
    var user_idText: UITextField!
    var passwordText: UITextField!
    var savePasswordBtn: UIButton!
    var loginBtn: UIButton!
    var settingBtn: UIButton!
    
    var personalInfomation:NSMutableDictionary = NSMutableDictionary()
    func initView() {
        let width:CGFloat = (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone ? self.view.width - 40 : self.view.width - 200)
        user_idText = UITextField(frame: CGRectMake(0, 95, width - 10, 30))
        user_idText.centerX = self.view.centerX
        user_idText.delegate = self
        user_idText.autocapitalizationType = UITextAutocapitalizationType.None
        user_idText.autocorrectionType = UITextAutocorrectionType.No
        user_idText.placeholder = "用户名"
        user_idText.textColor = UIColor.whiteColor()
        user_idText.font = UIFont.systemFontOfSize(textFontSize)
        user_idText.setValue(UIColor(red: 226.0/255.0, green: 225.0/255.0, blue: 195.0/255.0, alpha: 1)
            , forKeyPath: "_placeholderLabel.textColor")
        self.view.addSubview(user_idText)
        
        let line:UIImageView = UIImageView(frame: CGRectMake(0, 125, width, 1))
        line.image = UIImage(named: "line")
        line.centerX = self.view.centerX
        self.view.addSubview(line)
        
        passwordText = UITextField(frame: CGRectMake(0, 135, width - 10, 30))
        passwordText.delegate = self;passwordText.textColor = UIColor.whiteColor()
        passwordText.autocorrectionType = UITextAutocorrectionType.No
        passwordText.placeholder = "密码"
        passwordText.centerX = self.view.centerX
        passwordText.secureTextEntry = true
        passwordText.font = UIFont.systemFontOfSize(textFontSize)
        passwordText.setValue(UIColor(red: 226.0/255.0, green: 225.0/255.0, blue: 195.0/255.0, alpha: 1)
            , forKeyPath: "_placeholderLabel.textColor")
        self.view.addSubview(passwordText)
        
        let line1:UIImageView = UIImageView(frame: CGRectMake(0, 165, width, 1))
        line1.image = UIImage(named: "line")
        line1.centerX = self.view.centerX
        self.view.addSubview(line1)
        
        savePasswordBtn = UIButton(type: UIButtonType.Custom)
        savePasswordBtn.frame = CGRectMake(self.view.centerX - width / 2, 180, 15, 15)
        savePasswordBtn.setBackgroundImage(UIImage(named: "pwunselected"), forState: UIControlState.Normal)
        savePasswordBtn.setBackgroundImage(UIImage(named: "pwselected"), forState: UIControlState.Selected)
        savePasswordBtn.addTarget(self, action: "savePasswordAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(savePasswordBtn)
        
        UITextField.appearance().tintColor = UIColor.whiteColor()
        
        let remenberBtn:UIButton = UIButton(type: UIButtonType.Custom)
         remenberBtn.frame = CGRectMake(self.view.centerX - width / 2 + 20, 178, 80, 20)
        let text:NSMutableAttributedString = NSMutableAttributedString(string: "记住密码")
        if #available(iOS 8.2, *) {
            text.addAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),
                NSFontAttributeName:UIFont.systemFontOfSize(textFontSize, weight: 2)], range: NSMakeRange(0, text.length))
        } else {
            // Fallback on earlier versions
        }
        remenberBtn.setAttributedTitle(text, forState: UIControlState.Normal)
        remenberBtn.addTarget(self, action: "clicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(remenberBtn)
        
        settingBtn = UIButton(type: UIButtonType.Custom)
        settingBtn.frame = CGRectMake(self.view.centerX + width / 2 - 55, 178, 65, 20)
        let str:NSMutableAttributedString = NSMutableAttributedString(string: "配置IP")
        if #available(iOS 8.2, *) {
            str.addAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,
                NSFontAttributeName:UIFont.systemFontOfSize(textFontSize, weight: 2)], range: NSMakeRange(0, str.length))
        } else {
            // Fallback on earlier versions
        }
        settingBtn.setAttributedTitle(str, forState: UIControlState.Normal)
        settingBtn.addTarget(self, action: "settingAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(settingBtn)
        
        
        loginBtn = UIButton(type: UIButtonType.Custom)
        loginBtn.frame = CGRectMake(0, 220, width, 40)
        loginBtn.backgroundColor = UIColor.whiteColor()
        loginBtn.centerX = self.view.centerX
        loginBtn.setTitle("登录", forState: UIControlState.Normal)
        loginBtn.setTitleColor(UIColor(red: 64.0/255.0, green: 130.0/255.0, blue: 228.0/255.0, alpha: 1), forState: UIControlState.Normal)
        loginBtn.addTarget(self, action: "loginToServiceAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginBtn)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let bk:UIImageView = UIImageView(frame: self.view.frame)
        bk.image = UIImage(named: "background")
        self.view.addSubview(bk)
        self.initView()
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    func settingAction(sender: UIButton) {
        let pvView:PopupAnimationView = PopupAnimationView.defaultPopupView()
        pvView.setTextField(AppDelegate.app().IP)
        pvView.popupDelegete = self
        pvView.parentVC = self
        self.lew_presentPopupView(pvView, animation: LewPopupViewAnimationDrop(), dismissed: nil)
    }
    
    func savePasswordAction(sender: UIButton) {
        savePasswordBtn.selected = !savePasswordBtn.selected
    }
    
    func clicked(sender:UIButton) {
        self.savePasswordAction(self.savePasswordBtn)
    }
    
    func loginToServiceAction(sender: UIButton) {
        if self.user_idText.text == "" || self.passwordText.text == "" {
            let alert:UIAlertView = UIAlertView(title: "错误", message: "用户名和密码不能为空", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        UITextField.appearance().resignFirstResponder()
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
        progressHud.labelText = "正在登录"
        progressHud.show(true)
        
        let user_id: NSString! = self.user_idText.text
        let password: NSString! = self.passwordText.text
        let url = "http://\(AppDelegate.app().IP)/" + config + loginURL
        
        NetworkRequest.AlamofirePostParametersResponseJSON(url, parameters: ["user_id":"\(user_id)","user_password":"\(password)"], success: {(json) in
            if (json.count < 7) {
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "用户名密码错误", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            if json.type == .Dictionary {
                self.personalInfomation.setDictionary(json.object as! [NSObject : AnyObject])
            }else {print("返回数据有误")}   //预加载返回用户数据，以备保存
            var isSaveSuccess = false
            if self.savePasswordBtn.selected {
                UserHelper.setValueOfPWIsSaved(true)
                UserHelper.setRecentID(self.user_idText.text!)
                isSaveSuccess = UserHelper.setCurrentUserInfo(self.personalInfomation, user_id: self.user_idText.text!)
                
                if !KeyChain.addKeyChainItem(self.user_idText.text!, user_password: self.passwordText.text!, IP: AppDelegate.app().IP) {
                    KeyChain.updateKeyChainItem(self.user_idText.text!, user_password: self.passwordText.text!)
                    KeyChain.updateIPItem(self.user_idText.text!, IP: AppDelegate.app().IP)
                    //let ip = KeyChain.getIPItem(self.user_idText.text!)
                    //let pas = KeyChain.getKeyChainItem(self.user_idText.text!)
                }
                
            }else {
                for key in self.personalInfomation.allKeys {
                    if key as! String == "offline_id" {
                        AppDelegate.app().offline_id = self.personalInfomation.objectForKey(key as! NSString)!.description
                        AppDelegate.app().user_id = self.user_idText.text!
                        break
                    }
                }
                let filepath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("selfInfo.plist")
                isSaveSuccess = self.personalInfomation.writeToFile(filepath, atomically: true)
            }
            
            if isSaveSuccess {
                progressHud.labelText = "登录成功"
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.hide(true, afterDelay: 1)
                AppDelegate.app().user_id = user_id as String
                AppDelegate.app().offline_id = self.personalInfomation.objectForKey("offline_id") as! String
                let gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC))
                dispatch_after(gcdT, dispatch_get_main_queue(), {
                    let loginStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    AppDelegate.app().window?.rootViewController = loginStory.instantiateInitialViewController()
                })
            }
            
            }, failed: {
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "连接异常，请检查IP配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }, outTime: {
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()})
    }
    
    //MARK: --UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: --personalMessageEditDelegete
    func textfieldMessageID(idunique: String!) {
        if !LoanerHelper.isvaildIP(idunique) {
            let hud = MBProgressHUD(view: self.view)
            self.view.addSubview(hud)
            hud.show(true)
            hud.mode = MBProgressHUDMode.Text
            hud.detailsLabelText = "请务必输入正确格式的IP地址\n端口号使用:连接"
            hud.detailsLabelFont = UIFont.systemFontOfSize(17)
            hud.hide(true, afterDelay: 2)
            return
        }
        AppDelegate.app().IP = idunique
        AppDelegate.app().ipUrl = "http://\(idunique)/"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func keyboardHide() {
        self.user_idText.resignFirstResponder()
        self.passwordText.resignFirstResponder()
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
