//
//  CircleViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/6.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

class CircleViewController: UIViewController ,PopoverMenuViewDelegate{

    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    var json:JSON = JSON.nullJSON
    var menuView : PopoverMenuView!
    var pro_id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewData()
        self.msgTextView.layer.borderColor = UIColor(red: 230.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1).CGColor
        self.msgTextView.layer.borderWidth = 3
        self.msgTextView.layer.cornerRadius = 6
        
        if self.json.count > 0{
            self.sumTextField.enabled = false
            self.msgTextView.editable = false
            self.submitBtn.hidden = true
            self.submitBtn = UIButton()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "操作", style: UIBarButtonItemStyle.Plain, target: self, action: "handleFeedback:")
        }else {
            var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
            self.view.addGestureRecognizer(tapGesture)
            self.submitBtn.layer.cornerRadius = 8
        }
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        if self.sumTextField.text == "" {
            let alert:UIAlertView = UIAlertView(title: "错误", message: "请输入建议金额", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        
        //let hud:MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.navigationController!.view, animated: true)
        
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.labelText = "正在提交"
        progressHud.show(true)
        
        let user_id:NSString = AppDelegate.app().getuser_idFromPlist()
        
        var submitDic:NSMutableDictionary = NSMutableDictionary()
        submitDic.setValue(user_id, forKey: "user_id")
        submitDic.setValue(self.pro_id, forKey: "pro_id")
        submitDic.setValue(self.sumTextField.text, forKey: "suggest_money")
        submitDic.setValue(self.msgTextView.text, forKey: "remark")
        var request: Alamofire.Request?
        let ip = "http://\(AppDelegate.app().IP)/"
        request = Alamofire.request(.POST, ip + config + "app/" + "disagree",
            parameters: ["data":"\(JSON(submitDic))"])
        
        request?.responseString() { (_, _, data, error) in
            if data == "success" {
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.labelText = "提交成功"
                progressHud.hide(true, afterDelay: 2)
                let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
                dispatch_after(gcdTimer, dispatch_get_main_queue(), {
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                })
            }else {
                progressHud.labelText = "提交失败"
                progressHud.hide(true, afterDelay: 1)
            }
        }
    }
    
    func handleFeedback(sender:UIBarButtonItem) {
        if (self.menuView != nil) {
            self.menuView.dismissMenuPopover()
        }
        let menuItem = ["同意","不同意","关闭项目"]
        self.menuView = PopoverMenuView(frame: CGRectMake(self.view.bounds.width - 150, 70, 140.0, 3*44.0), menuItems: menuItem)
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
        let user_id:NSString = AppDelegate.app().getuser_idFromPlist()
        
        var submitDic:NSMutableDictionary = NSMutableDictionary()
        submitDic.setValue(user_id, forKey: "user_id")
        submitDic.setValue(self.pro_id, forKey: "pro_id")
        
        var footerURL:String = ""
        
        self.menuView.dismissMenuPopover()
        switch selectedIndex {
        case 0:
            footerURL = "agree"
        case 1:
            let feedbackVC:CircleViewController = CircleViewController()
            feedbackVC.pro_id = self.pro_id
            self.navigationController?.pushViewController(feedbackVC, animated: true)
            return
        case 2:
            footerURL = "close"
        default:
            break
        }
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.labelText = "正在提交"
        progressHud.show(true)
        
        var request: Alamofire.Request?
        let js:JSON = JSON(submitDic)
        let ip = "http://\(AppDelegate.app().IP)/"
        request = Alamofire.request(.POST, ip + config + "app/" + footerURL,
            parameters: ["data":"\(js)"])
        request?.responseString() { (_, _, data, error) in
            println(data)
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
        }
    }
    
    convenience init() {
        var nibNameOrNil = "CircleViewController"
        if NSBundle.mainBundle().pathForResource(nibNameOrNil, ofType: "xib") == nil {
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
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
