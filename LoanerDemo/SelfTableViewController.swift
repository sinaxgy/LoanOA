//
//  SelfTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class SelfTableViewController: UITableViewController ,personalMessageEditDelegete{
    
    var tableDataDic:NSDictionary!
    var actionString = "logout:"
    var buttonTitle = "退出登录"
    
    var infoArray:NSArray = ["user_name","user_sex","user_id","user_tel","user_email","offline_name"]
    //,"role_id","dep_id","offline_id"
    var height:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if actionString == "logout:" && buttonTitle == "退出登录" {
            tableDataDic = self.getPersonalInfo()
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "配置IP", style: UIBarButtonItemStyle.Plain, target: self, action:"settingIP:")
            if #available(iOS 8.2, *) {
                self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
                    NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue,
                    NSFontAttributeName:UIFont.systemFontOfSize(14, weight: 3)],
                    forState: UIControlState.Normal)
            } else {
                // Fallback on earlier versions
            }
            self.height = 6
            self.navigationController?.tabBarItem.selectedImage = UIImage(named: "perSelected")
        }else {
            self.height = 5
        }
    }
    
    func settingIP(sender:UIBarButtonItem) {
        let pvView:PopupAnimationView = PopupAnimationView.defaultPopupView()
        pvView.setTextField(AppDelegate.app().IP)
        pvView.popupDelegete = self
        pvView.parentVC = self
        self.lew_presentPopupView(pvView, animation: LewPopupViewAnimationDrop(), dismissed: nil)
    }
    
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
        KeyChain.updateIPItem(AppDelegate.app().user_id, IP: idunique)
    }
    
    func payFinance(sender:UIButton) {
        sender.selected = !sender.selected
        sender.enabled = sender.selected
        let dic = self.getPersonalInfo()
        let hud:MBProgressHUD = MBProgressHUD(view: self.view)
        hud.show(true);self.view.addSubview(hud)
        hud.labelText = "确认中..."
        if (dic.allKeys as NSArray).containsObject("role_id") {
            let role_id:String = (dic.objectForKey("role_id") as? String)!
            let aid:String = self.tableDataDic.objectForKey("aid") as! String
            let url = AppDelegate.app().ipUrl + config + "app/pay"
            NetworkRequest.AlamofirePostParameters(url, parameters:
                ["user_id":"\(AppDelegate.app().user_id)",
                    "role_id":"\(role_id)","aid":"\(aid)"],
                success: {
                        (data) -> Void in
                        if data as! String == "success" {
                            hud.labelText = "确认成功"
                            hud.mode = MBProgressHUDMode.CustomView
                            hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                            hud.hide(true, afterDelay: 1)
                            let gcdDelay:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
                            dispatch_after(gcdDelay, dispatch_get_main_queue(), { () -> Void in
                                self.navigationController?.popToRootViewControllerAnimated(false)
                            })
                        }
            }, failed: { () -> Void in
                hud.hide(true, afterDelay: 1)
            }, outTime: { () -> Void in
                hud.hide(true, afterDelay: 1)
            })
        }
    }
    
    func logout(sender:UIBarButtonItem) {
        UserHelper.setValueOfPWIsSaved(false)
        self.navigationController?.presentViewController(
            LoginsViewController(), animated: true, completion: nil)
    }
    
    func getPersonalInfo() -> NSDictionary {
        if !UserHelper.readValueOfPWIsSaved() {
            let filepath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("selfInfo.plist")
            return NSDictionary(contentsOfFile: filepath)!
        }else {
            return UserHelper.readCurrentUserInfo(AppDelegate.app().user_id)
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
        if self.tableDataDic == nil || section == 2 {
            return 0
        }
        if section == 1 {
            return 1
        }
        return (self.infoArray.count)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 1 {
            let heigh = self.view.height - 226 - CGFloat(self.height * 44)
            return heigh
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
            let btn:UIButton = UIButton(frame: CGRectMake(0, 0, self.view.width, 40))
            btn.titleLabel?.textAlignment = NSTextAlignment.Center
            btn.setTitle(self.buttonTitle, forState: UIControlState.Normal)
            btn.titleLabel?.font = UIFont.systemFontOfSize(textFontSize)
            btn.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Selected)
            btn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Selected)
            btn.addTarget(self, action: Selector("\(actionString)"), forControlEvents: UIControlEvents.TouchUpInside)
            cell.contentView.addSubview(btn)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func setPersonalCell(indexPath:NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "selfCell")
        cell.textLabel?.font = UIFont.systemFontOfSize(textFontSize)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(detailFontSize)
        let key: NSString = self.infoArray[indexPath.row] as! NSString
        switch key {
        case "dep_id":
            cell.textLabel?.text = "部门编号"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "user_sex":
            cell.textLabel?.text = "性别"
            let value:String = self.tableDataDic.objectForKey(key as NSString) as! String
            if value == "1" {
                cell.detailTextLabel?.text = "男"
            }else if value == "0" {
                cell.detailTextLabel?.text = "女"
            }
        case "user_tel":
            cell.textLabel?.text = "电话"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "user_name":
            cell.textLabel?.text = "姓名"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "user_id":
            cell.textLabel?.text = "编号"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "user_email":
            cell.textLabel?.text = "邮箱"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "role_id":
            cell.textLabel?.text = "角色编号"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "offline_id":
            cell.textLabel?.text = "线下机构编号"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "offline_name":
            cell.textLabel?.text = "线下机构名称"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "pro_num":
            cell.textLabel?.text = "项目编号"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "pro_title":
            cell.textLabel?.text = "项目标题"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "date":
            cell.textLabel?.text = "还款日期"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "type":
            cell.textLabel?.text = "还款类型"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        case "money":
            cell.textLabel?.text = "还款金额"
            cell.detailTextLabel?.text = self.tableDataDic.objectForKey(key as NSString)  as? String
        default:
            break
        }
        return cell
    }

}
