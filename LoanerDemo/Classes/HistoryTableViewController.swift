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
let detailFontSize:CGFloat = (isIphone ? 12 : 24)
let textFontSize:CGFloat = (isIphone ? 15 : 34)
let cellHeight:CGFloat = (isIphone ? 55 : 100)
//let cellHeight:CGFloat = 55
let mainColor = 0x4282e3//0x4282e3//0x25b6ed
let navColor = 0x1960e3
let originalX:CGFloat = UIScreen.mainScreen().bounds.width - 110.0
let popverMenuX:CGFloat = 100.0

class HistoryTableViewController: UITableViewController ,PopoverMenuViewDelegate{
    
    var unConnectedView:UIImageView!
    
    var activityView:UIActivityIndicatorView!
    var typeMenu:PopoverMenuView!
    var typeDic:NSDictionary = NSDictionary()
    var json:JSON = JSON.nullJSON
    var sortJsonArray:NSArray = []
    
    var headers: [String: String] = [:]
    var body: String?
    var elapsedTime: NSTimeInterval?
    
    @IBAction func tableAddAction(sender: AnyObject) {
        var progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.show(true)
        
        let url = AppDelegate.app().ipUrl + config + "app/service"
        NetworkRequest.AlamofireGetJSON(url, success: { (data) in
            if data != nil {
                let typejs = JSON(data!)
                if typejs.type == .Dictionary {
                    self.typeDic = typejs.object as! NSDictionary
                    if self.typeDic.count < 2 {
                        progressHud.labelText = "数据异常"
                        progressHud.hide(true, afterDelay: 1)
                        return
                    }
                    progressHud.hide(true)
                    let keys = self.typeDic.allKeys
                    var typeArray:NSMutableArray = NSMutableArray()         //菜单选项数组
                    for key in keys {
                        typeArray.addObject(self.typeDic.objectForKey(key)!)
                    }
                    if (self.typeMenu != nil) {
                        self.typeMenu.dismissMenuPopover()
                    }
                    let hight = self.typeDic.count * 44
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
        let ip = "http://\(AppDelegate.app().IP)/"
        let keys = self.typeDic.allKeys
        let type:String = keys[selectedIndex] as! String
        var addView:BranchTableViewController = BranchTableViewController()
        addView.url = AppDelegate.app().ipUrl + config + typeURL + type
        addView.typeOp.type = type
        addView.typeOp.typeName = self.typeDic.objectForKey(type) as! String
        let nav:UINavigationController = UINavigationController(rootViewController: addView)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.tabBarItem.badgeValue = "12"
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 100))
        self.refreshControl?.addTarget(self, action: "reload:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView?.addSubview(self.refreshControl!)
        
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
            self.refreshControl?.attributedTitle = NSAttributedString(string: "加载中...")
        }
        
        let user_id:String = AppDelegate.app().user_id
        let url = "http://\(AppDelegate.app().IP)/" + config + readHisURL + "\(user_id)"
        NetworkRequest.AlamofireGetJSON(url, success: { (data) in
            self.hiddenActivityIndicatorViewInNavigationItem()
            if data == nil {println("empty");return}
            self.json = JSON(data!)
            if self.json != nil {
                if self.json.count != 0 {           //项目编号排序
                    var keys:NSArray = (self.json.object as! NSDictionary).allKeys
                    self.sortJsonArray = keys.sortedArrayUsingComparator({
                        (s1,s2) -> NSComparisonResult in
                        if (s1 as! String) > (s2 as! String) {
                            return NSComparisonResult.OrderedAscending
                        }
                        return NSComparisonResult.OrderedDescending
                    })
                }
                if self.unConnectedView != nil {
                    self.unConnectedView.removeFromSuperview()
                    self.unConnectedView = nil
                }
                self.tableView.reloadData()
                self.navigationItem.title = "所有项目"
            }
            }, failed: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                if self.unConnectedView == nil {
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
        var vaildHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(vaildHud)
        vaildHud.show(true)
        vaildHud.mode = MBProgressHUDMode.Text
        vaildHud.detailsLabelText = "请求超时"
        vaildHud.detailsLabelFont = UIFont.systemFontOfSize(17)
        vaildHud.hide(true, afterDelay: 1)
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        var actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.json == nil {
            return 0
        }
        return self.json.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "historyCell")
        if self.json == nil {
            return cell
        }
        if self.json.type == .Dictionary {
            var keys:NSArray = (self.json.object as! NSDictionary).allKeys
            let key: AnyObject = self.sortJsonArray[indexPath.row]
            let js = self.json[key as! String]
            if js.type == .Dictionary {
                if js.count == 1 {
                    let text: AnyObject? = (js.object as! NSDictionary).allKeys.first
                    cell.textLabel?.text = text?.description
                    cell.textLabel?.font = UIFont.systemFontOfSize(textFontSize)
                    let detail = js[text as! String]
                    cell.detailTextLabel?.text = detail.description
                    cell.detailTextLabel?.font = UIFont.systemFontOfSize(detailFontSize)
                    cell.detailTextLabel?.textColor = UIColor.grayColor()
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var browseView:BranchTableViewController = BranchTableViewController()
        if self.json.type == .Dictionary {
            let key: AnyObject = self.sortJsonArray[indexPath.row]
            let js = self.json[key as! String]
            if js.type == .Dictionary {
                if js.count == 1 {
                    let text: AnyObject? = (js.object as! NSDictionary).allKeys.first
                    browseView.typeOp.typeName = text!.description
                }
            }
            //browseView.pro_id = key as! String
            AppDelegate.app().pro_id = key as! String
            browseView.isAdd = false
            browseView.url = AppDelegate.app().ipUrl + config + readTableURL + "\(key)" + "&remark=" + AppDelegate.app().user_id
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
}
