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
    
    let infoArray:NSArray = ["user_name","user_sex","user_id","user_tel","user_email","offline_name"]
    //,"role_id","dep_id","offline_id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.readSelfINfo()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "配置IP", style: UIBarButtonItemStyle.Plain, target: self, action:"settingIP:")
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName:UIFont.systemFontOfSize(14, weight: 3)],
            forState: UIControlState.Normal)
        
        var str:NSMutableAttributedString = NSMutableAttributedString(string: "配置IP")
        str.addAttributes([NSForegroundColorAttributeName:UIColor.whiteColor(),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: 2)], range: NSMakeRange(0, str.length))
        
        
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: "perSelected")
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
        KeyChain.updateIPItem(AppDelegate.app().user_id, IP: idunique)
    }
    
    func logout(sender:UIBarButtonItem) {
        UserHelper.setValueOfPWIsSaved(false)
        //let loginView = UIStoryboard(name: "Main", bundle: nil)
        self.navigationController?.presentViewController(
            LoginsViewController(), animated: true, completion: nil)
    }
    
    func readSelfINfo() {
        if !UserHelper.readValueOfPWIsSaved() {
            let filepath = NSTemporaryDirectory().stringByAppendingPathComponent("selfInfo.plist")
            selfInfoDic = NSDictionary(contentsOfFile: filepath)!
        }else {
            selfInfoDic = UserHelper.readCurrentUserInfo(AppDelegate.app().user_id)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selfInfoDic == nil || section == 2{
            return 0
        }
        if section >= 1 {
            return 1
        }
        return (self.infoArray.count)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 1 {
            return self.view.height - 490
        }
        return 35
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 30))
        headerView.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/205.0, alpha: 1)
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return setPersonalCell(indexPath)
        case 1:
            let cell:UITableViewCell = UITableViewCell(frame: CGRectMake(0, 0, self.view.width, 40))
            var btn:UIButton = UIButton(frame: CGRectMake(0, 0, self.view.width, 40))
            btn.titleLabel?.textAlignment = NSTextAlignment.Center
            btn.setTitle("退出登录", forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Selected)
            btn.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.contentView.addSubview(btn)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func setPersonalCell(indexPath:NSIndexPath) -> UITableViewCell {
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
