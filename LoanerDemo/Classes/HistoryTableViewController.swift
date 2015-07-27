//
//  HistoryTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class HistoryTableViewController: UITableViewController ,PopoverMenuViewDelegate{
    
    var activityView:UIActivityIndicatorView!
    var typeMenu:PopoverMenuView!
    var typeDic:NSDictionary = NSDictionary()
    var json:JSON = JSON.nullJSON
    var sortJsonArray:NSArray = []
    
    var headers: [String: String] = [:]
    var body: String?
    var elapsedTime: NSTimeInterval?
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
            
            self.headers.removeAll()
            self.body = nil
            self.elapsedTime = nil
        }
    }
    @IBAction func tableAddAction(sender: AnyObject) {
        let ip = "http://\(AppDelegate.app().IP)/"
        var requestType = Alamofire.request(.GET, ip + config + "app/service")
        requestType.responseJSON() {
            (_,_,data,error) in
            if error != nil {
                let alert:UIAlertView = UIAlertView(title: "错误", message: "获取业务类型失败,无返回类型", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
            if data != nil {
                let typejs = JSON(data!)
                if typejs.type == .Dictionary {
                    self.typeDic = typejs.object as! NSDictionary
                    if self.typeDic.count < 2 {
                        let alert:UIAlertView = UIAlertView(title: "错误", message: "获取业务类型失败,无返回类型有误", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        return
                    }
                    let keys = self.typeDic.allKeys
                    var typeArray:NSMutableArray = NSMutableArray()         //菜单选项数组
                    for key in keys {
                        typeArray.addObject(self.typeDic.objectForKey(key)!)
                    }
                    if (self.typeMenu != nil) {
                        self.typeMenu.dismissMenuPopover()
                    }
                    let hight = self.typeDic.count * 44
                    self.typeMenu = PopoverMenuView(frame: CGRectMake(self.view.bounds.width - 150, 70, 140.0, CGFloat(hight)), menuItems: typeArray as [AnyObject])
                    self.typeMenu.menuPopoverDelegate = self
                    self.typeMenu.showInView(self.view)
                }
            }
        }
    }
    
    func menuPopover(menuView: PopoverMenuView!, didSelectMenuItemAtIndex selectedIndex: Int) {
        let ip = "http://\(AppDelegate.app().IP)/"
        let keys = self.typeDic.allKeys
        let type:String = keys[selectedIndex] as! String
        //println(type)
        var addView:BranchTableViewController = BranchTableViewController()
        addView.request = Alamofire.request(.GET, ip + config + typeURL + type)
        addView.typeOp.type = type
        addView.typeOp.typeName = self.typeDic.objectForKey(type) as! String
        addView.pro_id = "速评表"
        let nav:UINavigationController = UINavigationController(rootViewController: addView)
        self.navigationController?.presentViewController(nav, animated: true, completion: nil)
            //pushViewController(addView, animated: true)
    }

    override func viewDidLoad() {
        self.tabBarItem.badgeValue = "12"
        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 100))
        self.refreshControl?.addTarget(self, action: "reload:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView?.addSubview(self.refreshControl!)
        self.reload(self.refreshControl!)
        
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.activityView.frame = self.navigationController!.view.bounds
        self.activityView.backgroundColor = UIColor.clearColor()
        self.activityView.hidesWhenStopped = true
        self.view.addSubview(self.activityView)
        self.activityView.startAnimating()
        self.showActivityIndicatorViewInNavigationItem()
        
    }
    
    func reload(sender:AnyObject) {
        if self.request == nil {
            let asa:String = AppDelegate.app().getuser_idFromPlist() as String
            let ip = "http://\(AppDelegate.app().IP)/" + config + readHisURL + "\(asa)"
            self.request = Alamofire.request(.GET, ip)
        }
        if (self.refreshControl!.refreshing) {
            self.refreshControl?.attributedTitle = NSAttributedString(string: "加载中...")
        }
        
        self.request?.responseJSON(){ (_, _, json, error) in
            if self.request == nil {
                return
            }
            if error != nil {
                println(error)
                switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
                case .OrderedSame, .OrderedDescending:
                    var alert:UIAlertController = UIAlertController(title: "错误", message: "装载失败", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                case .OrderedAscending:
                    
                    let alert:UIAlertView = UIAlertView(title: "错误", message: "加载数据失败", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                }
                self.navigationItem.titleView = nil
                self.navigationItem.prompt = nil
                self.refreshControl?.endRefreshing()
                self.activityView.stopAnimating()
                self.request = nil
                return
            }
            //println(json)
            self.json = JSON(json!)
            if self.json.count != 0 {           //项目编号排序
                var keys:NSArray = (self.json.object as! NSDictionary).allKeys
                self.sortJsonArray = keys.sortedArrayUsingComparator({
                    (s1,s2) -> NSComparisonResult in
                    if (s1 as! String) > (s2 as! String) {
                        return NSComparisonResult.OrderedAscending
                    }
                    return NSComparisonResult.OrderedDescending
                })
                //println(self.sortJsonArray)
            }
            
            self.tableView.reloadData()
            self.navigationItem.titleView = nil
            self.navigationItem.prompt = nil
            self.refreshControl?.endRefreshing()
            self.activityView.stopAnimating()
            self.request = nil
        }
        
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if self.request != nil {
                self.request?.cancel()
                self.request = nil
                self.navigationItem.titleView = nil
                self.navigationItem.prompt = nil
                self.refreshControl?.endRefreshing()
                self.activityView.stopAnimating()
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        })
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        var actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.titleView = actView
        actView.startAnimating()
        self.navigationItem.prompt = "数据加载中..."
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
        return 55
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.json.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCellWithIdentifier("historyCell") as! UITableViewCell
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "historyCell")
        if self.json.type == .Dictionary {
            var keys:NSArray = (self.json.object as! NSDictionary).allKeys
            //let keys = array.sort
            //println(keys)
            let key: AnyObject = self.sortJsonArray[indexPath.row]
            let js = self.json[key as! String]
            if js.type == .Dictionary {
                if js.count == 1 {
                    let text: AnyObject? = (js.object as! NSDictionary).allKeys.first
                    cell.textLabel?.text = text?.description
                    let detail = js[text as! String]
                    cell.detailTextLabel?.text = detail.description
                    cell.detailTextLabel?.font = UIFont.systemFontOfSize(12)
                    cell.detailTextLabel?.textColor = UIColor.grayColor()
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
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
            browseView.pro_id = key as! String
            browseView.isAdd = false
            let ip = "http://\(AppDelegate.app().IP)/"
            browseView.request = Alamofire.request(.GET, ip  + config + readTableURL + "\(key)" + "&remark=" + "\(AppDelegate.app().getuser_idFromPlist())")
            let nav:UINavigationController = UINavigationController(rootViewController: browseView)
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        }
    }
}
