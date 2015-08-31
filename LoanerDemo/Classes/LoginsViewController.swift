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
let uploadUrl = "app/upload"

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
        let url = "http://\(AppDelegate.app().IP)/" + config + loginURL
        
        NetworkRequest.AlamofirePostParametersResponseJSON(url, parameters: ["user_id":"\(user_id)","user_password":"\(password)"], success: {(json) in
            if (json.count < 7) {
                self.request = nil
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "用户名密码错误", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            if json.type == .Dictionary {
                self.selfData.setDictionary(json.object as! [NSObject : AnyObject])
            }else {println("返回数据有误")}   //预加载返回用户数据，以备保存
            var isSaveSuccess = false
            if self.savePasswordBtn.selected {
                UserHelper.setValueOfPWIsSaved(self.savePasswordBtn.selected)
                UserHelper.setRecentID(self.user_idText.text)
                isSaveSuccess = UserHelper.setCurrentUserInfo(self.selfData, user_id: self.user_idText.text)
                
                if !KeyChain.addKeyChainItem(self.user_idText.text, user_password: self.passwordText.text, IP: AppDelegate.app().IP) {
                    KeyChain.updateKeyChainItem(self.user_idText.text, user_password: self.passwordText.text)
                    KeyChain.updateIPItem(self.user_idText.text, IP: AppDelegate.app().IP)
                    let ip = KeyChain.getIPItem(self.user_idText.text)
                    let pas = KeyChain.getKeyChainItem(self.user_idText.text)
                }
                
            }else {
                for key in self.selfData.allKeys {
                    if key as! String == "offline_id" {
                        AppDelegate.app().offline_id = self.selfData.objectForKey(key as! NSString)!.description
                        AppDelegate.app().user_id = self.user_idText.text
                        break
                    }
                }
                let filepath = NSTemporaryDirectory().stringByAppendingPathComponent("selfInfo.plist")
                isSaveSuccess = self.selfData.writeToFile(filepath, atomically: true)
            }
            
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
            
            }, failed: {
                progressHud.hide(true)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "连接异常，请检查IP配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }, outTime: {
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
            var hud = MBProgressHUD(view: self.view)
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
