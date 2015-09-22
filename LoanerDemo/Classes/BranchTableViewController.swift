//
//  BranchTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

struct operationType {
    var type:String
    var proNum:String
}

class BranchTableViewController: UITableViewController ,UIActionSheetDelegate,UIAlertViewDelegate,PopoverMenuViewDelegate{
    
    var isAdd:Bool = true
    var isShowNoti = false
    var typeOp = operationType(type: "", proNum: "")
    var dbjson:JSON = JSON.nullJSON
    var detailKeyArray:NSArray = []
    var url = "";var menuItems:NSArray = []
    var branchItems:NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.typeOp.proNum
        self.showActivityIndicatorViewInNavigationItem()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Bordered, target: self, action: "cancel:")
        
        self.tableView.registerNib(UINib(nibName: "BranchTableViewCell", bundle: nil), forCellReuseIdentifier: "branchCell")
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        var actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.titleView = actView
        actView.startAnimating()
        self.navigationItem.prompt = "数据加载中..."
    }
    
    func hiddenActivityIndicatorViewInNavigationItem() {
        self.navigationItem.titleView = nil
        self.navigationItem.prompt = nil
    }
    
    func loadJSONOfView() {
        self.branchItems = []
        NetworkRequest.AlamofireGetJSON(self.url, success: { (data) in
            if data == nil {
                self.hiddenActivityIndicatorViewInNavigationItem()
                self.title = "后台无数据"
                return
            }
            let js:JSON = JSON(data!)
            var jsonArray:NSMutableArray = NSMutableArray()
            var msgArray:NSMutableArray = []
            var jsArray:NSMutableArray = []
            var items:NSMutableArray = []
            for (key,value) in js {
                switch (key,value) {
                case ("closeAction","true"):        items.addObject(key)
                case ("specialAction","true"):      items.addObject(key)
                case ("submitEnable","true"):       items.addObject(key)
                case ("db_table",_):                self.dbjson = value
                case ("dataRemark",_):
                    if value != "" && !self.isShowNoti {
                        self.isShowNoti = true
                        var hud = MBProgressHUD(view: self.navigationController?.view)
                        self.navigationController?.view.addSubview(hud)
                        hud.mode = MBProgressHUDMode.Text;
                        hud.show(true)
                        hud.detailsLabelFont = UIFont.systemFontOfSize(15)
                        hud.detailsLabelText = "\(value)"
                        hud.hide(true, afterDelay: 3)
                    }
                case ("view",_):
                    if value.count == 0 {
                        self.hiddenActivityIndicatorViewInNavigationItem()
                        let alert:UIAlertView = UIAlertView(title: "错误", message: "无速评表数据", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        return
                    }
                    for (vKey,vValue) in value {    //vValue为标签数组的标签元素
                        //遍历各标签
                        for (kk,vv) in vValue {     //vv，标签元素对应的value值
                            //标签层属性
                            var branchItem:BranchItem = BranchItem()
                            branchItem.fileName = kk
                            for (k,v) in vv {       //遍历标签层属性
                                switch k {
                                case "tag_name":
                                    branchItem.tag_name = v.description
                                case "isComplete":
                                    branchItem.isComplete = v.description
                                case "data":
                                    branchItem.data = v
                                case "editable":
                                    branchItem.editable = v.description
                                case "arraysort":
                                    if v.type == .Array {
                                        branchItem.arraysort = (v.object as? NSArray)!
                                    }else {
                                        let alert:UIAlertView = UIAlertView(title: "错误", message: "数据有误", delegate: nil, cancelButtonTitle: "确定")
                                        alert.show()
                                    }
                                default:break
                                }
                            }
                            self.branchItems.addObject(branchItem)
                        }
                    }
                default:break
                }
            }
            if items.count > 0 {
                self.createMenuWithArray(items)
            }
            self.tableView.reloadData()
            self.hiddenActivityIndicatorViewInNavigationItem()
            }, failed: {
                self.title = self.typeOp.proNum
                self.hiddenActivityIndicatorViewInNavigationItem()}, outTime: {
                    self.hiddenActivityIndicatorViewInNavigationItem()
                    self.connectFailed()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.branchItems.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellImageWidth:CGFloat = (isIphone ? 18 : 27)
        //tableView.dequeueReusableCellWithIdentifier("branchCell", forIndexPath: indexPath) as! BranchTableViewCell
        if let branch = self.branchItems[indexPath.row] as? BranchItem {
            let cell = BranchTableViewCell(width: cellImageWidth, reuseIdentifier: "branchCell")
            if branch.isComplete == "false" {
                cell.titleLabel.textColor = UIColor(hex: mainColor)
            }
            cell.title = branch.tag_name
            cell.titleImage = UIImage(named: branch.fileName)
            cell.titleLabel?.font = UIFont.systemFontOfSize(textFontSize)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: nil, action: nil)
        if self.branchItems.count < indexPath.row {return}
        if let branch = self.branchItems[indexPath.row] as? BranchItem {
            switch branch.data.count {
            case 0:
                if branch.tag_name == "图片上传" {
                    var imageVC:MasterImageTableViewController = MasterImageTableViewController()
                    imageVC.picURL.footer = branch.data.description
                    imageVC.title = "图片上传"
                    if branch.editable == "true" {
                        imageVC.editable = true
                    }else if branch.editable == "false" {
                        imageVC.editable = false
                    }
                    self.navigationController?.pushViewController(imageVC, animated: true)
                    return
                }else {
                    var requestVC:RequestTableViewController = RequestTableViewController()
                    requestVC.tag_Message.suffixURL = branch.data.description
                    if branch.editable == "true" {
                        requestVC.tag_Message.editable = true
                    }else if branch.editable == "false" {
                        requestVC.tag_Message.editable = false
                    }
                    self.navigationController?.pushViewController(requestVC, animated: true)
                }
            case 2:
                let circleVC:CircleViewController = CircleViewController()//FeedbackTableVC = FeedbackTableVC()
                
                circleVC.json = branch.data
                circleVC.title = branch.tag_name
                self.navigationController?.pushViewController(circleVC, animated: true)
            case 13,14:
                var detailView:DetailTableViewController = DetailTableViewController()
                detailView.json = branch.data;detailView.isAdd = self.isAdd
                detailView.defaultText.fileName = branch.fileName
                detailView.detailKeyArray = branch.arraysort
                detailView.typeTitle.proNum = branch.tag_name
                detailView.typeTitle.type = self.typeOp.type
                detailView.dbjson = self.dbjson
                self.navigationController?.pushViewController(detailView, animated: true)
            default:
                let alert:UIAlertView = UIAlertView(title: "错误", message: "后台传输数据有误", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        }
    }
    
    //MARK: barButtonAction
    func submitAction() {
        var alert:UIAlertView = UIAlertView(title: "提交资料", message: "确定提交项目资料？此项目将进入下一流程！", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.tag = 12
        alert.show()
    }
    
    func closeAction() {
        var alert:UIAlertView = UIAlertView(title: "关闭项目", message: "确定关闭此项目？此操作不可逆！", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.tag = 10
        alert.show()
    }
    
    func specialAction() {
        var alert:UIAlertView = UIAlertView(title: "申请特批", message: "确定为此项目申请特批？请输入缘由", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.tag = 11
        alert.show()
    }
    
    func cancel(sender:UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: --UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let user_id:NSString = AppDelegate.app().user_id
            var submitDic:NSMutableDictionary = NSMutableDictionary()
            submitDic.setValue(user_id, forKey: "user_id")
            submitDic.setValue(AppDelegate.app().pro_id, forKey: "pro_id");var footer = ""
            switch alertView.tag {
            case 10:
                footer = "close"
            case 11:
                footer = "disagree"
                submitDic.setValue(alertView.textFieldAtIndex(0)?.text, forKey: "remark")
            case 12:
                footer = "agree"
            default:break
            }
            let url = AppDelegate.app().ipUrl + config + "app/" + footer
            
            let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.show(true)
            
            NetworkRequest.AlamofirePostParameters(url, parameters: ["data":"\(JSON(submitDic))"], success: {(data) in
                if data as! String == "success" {
                    progressHud.mode = MBProgressHUDMode.CustomView
                    progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                    progressHud.hide(true, afterDelay: 2)
                    var gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
                    dispatch_after(gcdT, dispatch_get_main_queue(), {
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    })
                }else {
                    progressHud.labelText = "后台数据异常"
                    progressHud.hide(true, afterDelay: 1)
                }
                }, failed: {
                    progressHud.labelText = "请求失败"
                    progressHud.hide(true, afterDelay: 1)
                }, outTime: {
                    progressHud.labelText = "请求超时"
                    progressHud.hide(true, afterDelay: 1)
            })
        }
    }
    
    func createMenuWithArray(array:NSArray) {
        if array.count == 0 {
            return
        }
        if array.count == 1 {
            if array.firstObject as! String == "submitEnable" {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "submit"), style: UIBarButtonItemStyle.Bordered, target: self, action: "submitAction")
                
                return
            }
        }else {
            var items:NSMutableArray = []
            for key in array {
                if key as! String == "submitEnable" {
                    items.addObject("提交资料")
                }
                if key as! String == "specialAction" {
                    items.addObject("申请特批")
                }
                if key as! String == "closeAction" {
                    items.addObject("关闭项目")
                }
            }
            self.menuItems = items
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"), style: UIBarButtonItemStyle.Bordered, target: self, action: "showMenu:")
        }
    }
    
    //MARK:--PopoverMenuViewDelegate
    func menuPopover(menuView: PopoverMenuView!, didSelectMenuItemAtIndex selectedIndex: Int) {
        if let item:String = self.menuItems[selectedIndex] as? String {
            switch item {
            case "提交资料":
                self.submitAction()
            case "申请特批":
                self.specialAction()
            case "关闭项目":
                self.closeAction()
            default:break
            }
        }
    }
    
    func showMenu(sender:UIBarButtonItem) {
        let hight = self.menuItems.count * 44
        var menu:PopoverMenuView = PopoverMenuView(frame: CGRectMake(originalX, 70, popverMenuX, CGFloat(hight)), menuItems: self.menuItems as [AnyObject])
        menu.menuPopoverDelegate = self
        menu.showInView(self.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadJSONOfView()
    }
    
    func connectFailed() {
        var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(vaildHud)
        vaildHud.show(true)
        vaildHud.mode = MBProgressHUDMode.Text
        vaildHud.detailsLabelText = "请求超时"
        vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
        vaildHud.hide(true, afterDelay: 1)
    }
}
