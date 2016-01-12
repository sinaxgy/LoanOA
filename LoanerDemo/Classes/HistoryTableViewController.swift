//
//  HistoryTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Foundation
//UIDevice userInterfaceIdiom]
let isIphone = (UIDevice.currentDevice().userInterfaceIdiom  == UIUserInterfaceIdiom.Phone ? true:false)
let detailFontSize:CGFloat = (isIphone ? 12 : 18)
let textFontSize:CGFloat = (isIphone ? 15 : 20)
//let textFontHeight:CGFloat = (isIphone ? )
let cellHeight:CGFloat = (isIphone ? 55 : 70)
//let cellHeight:CGFloat = 55
let mainColor = 0x4282e3//0x4282e3//0x25b6ed
let navColor = 0x1960e3
let originalX:CGFloat = UIScreen.mainScreen().bounds.width - 110.0
let popverMenuX:CGFloat = 100.0

class HistoryTableViewController: UITableViewController ,PopoverMenuViewDelegate{
    
    var unConnectedView:UIImageView!
    
    var activityView:UIActivityIndicatorView!
    var typeMenu:PopoverMenuView!
    var newProTypeDic:NSDictionary = NSDictionary()
    var useableArray:NSArray = []
    var unuseableArray:NSArray = []
    
    var headers: [String: String] = [:]
    var body: String?;var hideSection = 3   //隐藏section，2全隐藏，1隐藏section1，0隐藏section0
    var elapsedTime: NSTimeInterval?
    
    @IBAction func tableAddAction(sender: AnyObject) {
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.show(true)
        
        let url = AppDelegate.app().ipUrl + config + "app/service"
        NetworkRequest.AlamofireGetJSON(url, success: { (data) in
            if data != nil {
                let typejs = JSON(data!)
                if typejs.type == .Dictionary {
                    self.newProTypeDic = typejs.object as! NSDictionary
                    if self.newProTypeDic.count < 2 {
                        progressHud.labelText = "数据异常"
                        progressHud.hide(true, afterDelay: 1)
                        return
                    }
                    progressHud.hide(true)
                    let keys = self.newProTypeDic.allKeys
                    let typeArray:NSMutableArray = NSMutableArray()         //菜单选项数组
                    for key in keys {
                        typeArray.addObject(self.newProTypeDic.objectForKey(key)!)
                    }
                    if (self.typeMenu != nil) {
                        self.typeMenu.dismissMenuPopover()
                    }
                    let hight = self.newProTypeDic.count * 44
                    self.typeMenu = PopoverMenuView(frame: CGRectMake(originalX, 70, popverMenuX, CGFloat(hight)), menuItems: typeArray as [AnyObject])
                    self.typeMenu.menuPopoverDelegate = self
                    self.typeMenu.showInView(self.view)
                }
            }
            }, failed: {
                progressHud.labelText = "连接异常"
                progressHud.hide(true, afterDelay: 1)}, outTime: {
                    progressHud.labelText = "请求超时"
                    progressHud.hide(true, afterDelay: 1)})
    }
    
    //MARK:--PopoverMenuViewDelegate
    func menuPopover(menuView: PopoverMenuView!, didSelectMenuItemAtIndex selectedIndex: Int) {
        let keys = self.newProTypeDic.allKeys
        let type:String = keys[selectedIndex] as! String
        let addView:BranchTableViewController = BranchTableViewController()
        addView.url = AppDelegate.app().ipUrl + config + typeURL + type
        addView.typeOp.type = type
        addView.typeOp.proNum = self.newProTypeDic.objectForKey(type) as! String
        let nav:UINavigationController = UINavigationController(rootViewController: addView)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.tabBarItem.badgeValue = "12"
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 100))
        self.refreshControl?.addTarget(self, action: "reload:", forControlEvents: UIControlEvents.ValueChanged)
        //self.tableView.tableHeaderView?.addSubview(self.refreshControl!)
        self.tableView.tableFooterView?.addSubview(self.refreshControl!)
        
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.activityView.frame = self.navigationController!.view.bounds
        self.activityView.backgroundColor = UIColor.clearColor()
        self.activityView.hidesWhenStopped = true
        self.view.addSubview(self.activityView)
        self.activityView.startAnimating()
        self.showActivityIndicatorViewInNavigationItem()
        
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: "spbSelected")
    }
    
    func reload(sender:AnyObject) {
        if (self.refreshControl!.refreshing) {
            self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新")
        }
        
        let user_id:String = AppDelegate.app().user_id
        let url = "http://\(AppDelegate.app().IP)/" + config + readHisURL + "\(user_id)"
        NetworkRequest.AlamofireGetJSON(url, success: { (data) in
            self.hiddenActivityIndicatorViewInNavigationItem()
            if data == nil {return}
            if JSON(data!).count == 0 {
                self.unConnectedView = UIImageView(frame: UIScreen.mainScreen().bounds)
                self.unConnectedView.image = UIImage(named: "noAnnounce")
                self.view.addSubview(self.unConnectedView)
                return
            }
            for (key,value) in JSON(data!) {
                if (key as String == "unuseable") && (value.type == .Array) {
                    self.unuseableArray = value.object as! NSArray
                }
                if (key as String == "useable") && (value.type == .Array) {
                    self.useableArray = value.object as! NSArray
                }
            }
            if self.unConnectedView != nil {
                self.unConnectedView.removeFromSuperview()
                self.unConnectedView = nil
            }
            self.tableView.reloadData()
            self.navigationItem.title = "所有项目"
            }, failed: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                if self.unConnectedView == nil && self.unuseableArray.count + self.useableArray.count == 0 {
                    self.unConnectedView = UIImageView(frame: UIScreen.mainScreen().bounds)
                    self.unConnectedView.image = UIImage(named: "noAnnounce")
                    self.view.addSubview(self.unConnectedView)
                }
                self.navigationItem.title = "所有项目（未连接）"
            }, outTime: {self.hiddenActivityIndicatorViewInNavigationItem()
                self.navigationItem.title = "所有项目（未连接）"
                self.connectFailed()
        })
    }
    
    func connectFailed() {
        let vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(vaildHud)
        vaildHud.show(true)
        vaildHud.mode = MBProgressHUDMode.Text
        vaildHud.detailsLabelText = "请求超时"
        vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
        vaildHud.hide(true, afterDelay: 1)
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        let actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.titleView = actView
        actView.startAnimating()
        self.navigationItem.prompt = "数据加载中..."
    }
    
    func hiddenActivityIndicatorViewInNavigationItem() {
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "mainTitle"))
        self.navigationItem.title = "所有项目"
        self.navigationItem.titleView = nil
        self.navigationItem.prompt = nil
        self.refreshControl?.endRefreshing()
        self.activityView.stopAnimating()
    }
    
    func setTabBarBadge(value:String) {
        if let tab:UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("tab") as? UITabBarController {
            tab.tabBar.selectedItem?.badgeValue = value
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
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.hideSection == 2 {
            return 0
        }
        if section == self.hideSection {
            return 0
        }
        if section == 0 {
            return self.useableArray.count
        }
        return self.unuseableArray.count
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //        if self.hideSection == indexPath.section {
        //            return UITableViewCell()
        //        } uinib
        var cell = tableView.dequeueReusableCellWithIdentifier("historyCell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "historyCell")
        }
        let array = (indexPath.section == 0 ? self.useableArray : self.unuseableArray)
        if let element = array[indexPath.row] as? NSArray {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell!.textLabel?.text = element[1] as? String
            cell!.textLabel?.font = UIFont.systemFontOfSize(textFontSize)
            cell!.detailTextLabel?.text = element[2] as? String
            cell!.detailTextLabel?.font = UIFont.systemFontOfSize(detailFontSize)
            cell!.detailTextLabel?.textColor = UIColor.grayColor()
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 30))
        headerView.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/205.0, alpha: 1)
        let text:String = (section == 0 ? "待处理项目" : "处理中项目")
        let label:UILabel = UILabel(frame: CGRectMake(25, 5, self.view.width, 25))
        label.text = text;label.textColor = UIColor.grayColor()
        label.font = UIFont.systemFontOfSize(detailFontSize)
        headerView.addSubview(label)
        
        let triangleView:UIImageView = UIImageView(frame: CGRectMake(5, 10, 15, 15))
        var triangleName = (self.hideSection == section ? "triangle" : "triangleDown")
        if self.hideSection == 2 {triangleName = "triangle"}
        triangleView.image = UIImage(named: triangleName)
        triangleView.contentMode = UIViewContentMode.ScaleAspectFit
        headerView.addSubview(triangleView)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "clickedSelectSection:")
        headerView.addGestureRecognizer(tap)
        headerView.tag = section
        return headerView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let array = (indexPath.section == 0 ? self.useableArray : self.unuseableArray)
        if let element = array[indexPath.row] as? NSArray {
            //0-1-2:项目ID、项目编号、项目状态
            let browseView:BranchTableViewController = BranchTableViewController()
            browseView.typeOp.proNum = (element[1] as? String)!
            AppDelegate.app().pro_id = element[0] as! String
            browseView.isAdd = false
            browseView.url = AppDelegate.app().ipUrl + config + readTableURL + "\(AppDelegate.app().pro_id)" + "&remark=" + AppDelegate.app().user_id
            let nav:UINavigationController = UINavigationController(rootViewController: browseView)
            nav.navigationBar.backItem?.title = "返回"
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        self.reload(self.refreshControl!)
        //self.tableView.touchesShouldCancelInContentView(self.tableView)
    }
    
    func clickedSelectSection(sender:UITapGestureRecognizer) {
        let view:UIView = sender.view!
        switch self.hideSection {
        case 0:
            if view.tag == 0 {
                self.hideSection = 3
            }else {
                self.hideSection = 2
            }
        case 1:
            if view.tag == 1 {
                self.hideSection = 3
            }else {
                self.hideSection = 2
            }
        case 2:
            if view.tag == 0 {
                self.hideSection = 1
            }else {
                self.hideSection = 0
            }
        case 3:
            self.hideSection = view.tag
        default:
            break
            
        }
        self.tableView.beginUpdates()
        self.tableView.reloadSections(NSIndexSet(index:view.tag), withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.endUpdates()
    }
}
