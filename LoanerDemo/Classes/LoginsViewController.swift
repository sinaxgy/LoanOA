//
//  LoginsViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/18.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

//let ip = "http://112.126.64.235:8843/"
//let ip = "http://123.57.219.112/loanOA/"  http://10.104.4.153/web/index.php/app/proinfo?pro_id=
//let ip = "http://10.104.4.153/"
let config = "web/index.php/"
let loginURL = "app/login"
let readHisURL = "app/getprojects?user_id="
let typeURL = "app/index?type="
let readTableURL = "app/proinfo?pro_id="

class LoginsViewController: UIViewController ,UITextFieldDelegate,personalMessageEditDelegete{
    
    @IBOutlet weak var user_idText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var savePasswordBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    var selfData:NSMutableDictionary = NSMutableDictionary()
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    func initView() {
        user_idText.delegate = self
        user_idText.autocapitalizationType = UITextAutocapitalizationType.None
        user_idText.autocorrectionType = UITextAutocorrectionType.No
        
        passwordText.delegate = self
        passwordText.autocorrectionType = UITextAutocorrectionType.No
        
        savePasswordBtn.setBackgroundImage(UIImage(named: "savepwn"), forState: UIControlState.Normal)
        savePasswordBtn.setBackgroundImage(UIImage(named: "savepws"), forState: UIControlState.Selected)
        
        loginBtn.layer.cornerRadius = 6
                
        settingBtn.layer.cornerRadius = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func settingAction(sender: UIButton) {
        let pvView:PopupAnimationView = PopupAnimationView.defaultPopupView()
        let ip = AppDelegate.app().IP
        pvView.setTextField(AppDelegate.app().IP)
        pvView.popupDelegete = self
        pvView.parentVC = self
        self.lew_presentPopupView(pvView, animation: LewPopupViewAnimationDrop.new(), dismissed: nil)
    }
    
    @IBAction func savePasswordAction(sender: UIButton) {
        savePasswordBtn.selected = !savePasswordBtn.selected
    }
    
    @IBAction func loginToServiceAction(sender: UIButton) {
        if self.user_idText.text == "" || self.passwordText.text == "" {
            let alert:UIAlertView = UIAlertView(title: "错误", message: "用户名和密码不能为空", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        
        var progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
        progressHud.labelText = "正在登录"
        progressHud.show(true)
        
        let user_id: NSString! = self.user_idText.text
        let password: NSString! = self.passwordText.text
        let ip = "http://\(AppDelegate.app().IP)/"
        self.request = Alamofire.request(.POST, ip + config + loginURL ,
            parameters: ["user_id":"\(user_id)","user_password":"\(password)"],
            encoding: .URL)
        
        self.request?.responseJSON(){ (_, _, json, error) in
            if self.request == nil {
                return
            }
            if error != nil {
                self.request = nil
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "连接异常，请检查IP配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            println(json)
            if (json?.count < 7) {
                self.request = nil
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "用户名密码错误", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            let jsdic:NSDictionary = JSON(json!).object as! NSDictionary
            let keys:NSArray = jsdic.allKeys
            for key in keys {
                let value: AnyObject? = jsdic.objectForKey(key as! NSString)
                self.selfData.setObject(value!, forKey: (key as? NSString)!)
            }
            var filepath = NSTemporaryDirectory().stringByAppendingPathComponent("selfInfo.plist")
            
            if self.savePasswordBtn.selected {
                filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("selfInfo.plist")
                if !KeyChain.addKeyChainItem(self.user_idText.text, user_password: self.passwordText.text, IP: AppDelegate.app().IP) {
                    KeyChain.updateKeyChainItem(self.user_idText.text, user_password: self.passwordText.text)
                    KeyChain.updateIPItem(self.user_idText.text, IP: AppDelegate.app().IP)
                    let ip = KeyChain.getIPItem(self.user_idText.text)
                    let pas = KeyChain.getKeyChainItem(self.user_idText.text)
                }
                
            }else {
                for key in keys {
                    if key as! String == "offline_id" {
                        AppDelegate.app().offline_id = jsdic.objectForKey(key as! NSString)!.description
                        AppDelegate.app().user_id = self.user_idText.text
                        break
                    }
                }
            }
            let isSaveSuccess = self.selfData.writeToFile(filepath, atomically: true)
            assert(isSaveSuccess, "写入失败")
            
            self.request = nil
            
            if isSaveSuccess {
                progressHud.labelText = "登录成功"
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.hide(true, afterDelay: 1)
                var gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC))
                dispatch_after(gcdT, dispatch_get_main_queue(), {
                    var loginStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    AppDelegate.app().window?.rootViewController = loginStory.instantiateInitialViewController() as? UIViewController
                })
            }
        }
        //超时处理
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if self.request != nil {
                self.request?.cancel()
                self.request = nil
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        })
    }
    
    //MARK: --UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: --personalMessageEditDelegete
    func textfieldMessageID(idunique: String!) {
        AppDelegate.app().IP = idunique
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
