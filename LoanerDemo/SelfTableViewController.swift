//
//  SelfTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

class SelfTableViewController: UITableViewController ,personalMessageEditDelegete{
    
    var selfInfoDic:NSDictionary!
    var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("selfInfo.plist")
    
    let infoArray:NSArray = ["user_name","user_sex","user_id","user_tel","user_email","offline_name"]
    //,"role_id","dep_id","offline_id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readSelfINfo()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "注销", style: UIBarButtonItemStyle.Plain, target: self, action:"logout:")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "配置IP", style: UIBarButtonItemStyle.Plain, target: self, action:"settingIP:")
    }
    
    func settingIP(sender:UIBarButtonItem) {
        let pvView:PopupAnimationView = PopupAnimationView.defaultPopupView()
        pvView.setTextField(AppDelegate.app().IP)
        pvView.popupDelegete = self
        pvView.parentVC = self
        self.lew_presentPopupView(pvView, animation: LewPopupViewAnimationDrop.new(), dismissed: nil)
    }
    
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
        let id = AppDelegate.app().getuser_idFromPlist()
        KeyChain.updateIPItem(id, IP: idunique)
        let ip = KeyChain.getIPItem(id)
    }
    
    func logout(sender:UIBarButtonItem) {
        if NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            if NSFileManager.defaultManager().removeItemAtPath(filepath, error: nil) {
                let alert:UIAlertView = UIAlertView(title: "成功", message: "注销成功", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
            let loginView = UIStoryboard(name: "Main", bundle: nil)
            self.navigationController?.presentViewController(
                (loginView.instantiateViewControllerWithIdentifier("LoginsViewController") as? UIViewController)!, animated: true, completion: nil)
        }else {
            let alert:UIAlertView = UIAlertView(title: "提示", message: "临时登录用户，无需注销", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func readSelfINfo() {
        if !NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            self.filepath = NSTemporaryDirectory().stringByAppendingPathComponent("selfInfo.plist")
            if !NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            let alert:UIAlertView = UIAlertView(title: "无法查看", message: "请登录后查看个人信息", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
            }

        }
        selfInfoDic = NSDictionary(contentsOfFile: filepath)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selfInfoDic == nil {
            return 0
        }
        return (self.infoArray.count)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "selfCell")
        var key: NSString = self.infoArray[indexPath.row] as! NSString
        switch key {
        case "dep_id":
            cell.textLabel?.text = "部门编号"
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "user_sex":
            cell.textLabel?.text = "性别"
            let value:String = self.selfInfoDic.objectForKey(key as NSString) as! String
            if value == "1" {
                cell.detailTextLabel?.text = "男"
            }else if value == "0" {
                cell.detailTextLabel?.text = "女"
            }
        case "user_tel":
            cell.textLabel?.text = "电话"
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "user_name":
            cell.textLabel?.text = "姓名"
            //println(self.selfInfoDic.objectForKey(key as NSString))
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "user_id":
            cell.textLabel?.text = "编号"
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "user_email":
            cell.textLabel?.text = "邮箱"
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "role_id":
            cell.textLabel?.text = "角色编号"
            //println(value)
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "offline_id":
            cell.textLabel?.text = "线下机构编号"
            //println(self.selfInfoDic.objectForKey(key as NSString))
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        case "offline_name":
            cell.textLabel?.text = "线下机构名称"
            cell.detailTextLabel?.text = self.selfInfoDic.objectForKey(key as NSString)  as? String
        default:
            break
        }
        return cell
    }

}
