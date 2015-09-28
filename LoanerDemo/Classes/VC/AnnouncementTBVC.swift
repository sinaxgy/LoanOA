//
//  AnnouncementTBVC.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/9.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class AnnouncementTBVC: UITableViewController {
    
    var numOfUnread:Int = 0 {
        didSet{
            if numOfUnread != 0 {
                self.navigationController?.tabBarItem.badgeValue = "\(self.numOfUnread)"
            }else {
                self.navigationController?.tabBarItem.badgeValue = nil
            }
        }
    }
    var unConnectedView:UIImageView!
    var announcements:NSMutableArray = []
    var financeArray:NSMutableArray = []
    let reuserCell = "anCell"
    var hideSection = 3   //隐藏section，2全隐藏，1隐藏section1，0隐藏section0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: reuserCell)
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: "ancSelected")
        
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 100))
        self.refreshControl?.addTarget(self, action: "getAnnouncement", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView?.addSubview(self.refreshControl!)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getAnnouncement()
    }
    
    func getAnnouncement() {
        self.showActivityIndicatorViewInNavigationItem()
        let url = AppDelegate.app().ipUrl + config + "app/news?id=\(AppDelegate.app().offline_id)&uid=\(AppDelegate.app().user_id)"
        NetworkRequest.AlamofireGetJSON(url, success: {
            (data) in
            if data == nil || JSON(data!).count == 0 {
                self.thereisNoAnnouncement()
                return
            }
            for (key,value) in JSON(data!) {
                switch key as String {
                case "news":
                    self.announcements = []
                    for (_,it) in value {
                        let item:AnnounceItem = AnnounceItem(json: it)
                        self.announcements.addObject(item)
                        if !item.isReaded {
                            self.numOfUnread++
                        }
                    }
                case "caiwu":
                    if value.type == .Array {
                        if value.count > 0 {
                            self.financeArray = value.object as! NSMutableArray
                        }
                    }
                default:break
                }
            }
            
            if self.unConnectedView != nil {
                self.unConnectedView.removeFromSuperview()
                self.unConnectedView = nil
            }
            self.tableView.reloadData()
            self.hiddenActivityIndicatorViewInNavigationItem()
            self.navigationItem.title = "公告"
            }, failed: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                if self.unConnectedView == nil {
                    self.unConnectedView = UIImageView(frame: UIScreen.mainScreen().bounds)
                    self.unConnectedView.image = UIImage(named: "noAnnounce")
                    self.view.addSubview(self.unConnectedView)
                    self.navigationItem.title = "公告（未连接）"
                }
            }, outTime: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                self.navigationItem.title = "公告（未连接）"
        })
    }
    
    func thereisNoAnnouncement() {
        let bk:UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        bk.image = UIImage(named: "noAnnounce")
        self.view.addSubview(bk)
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        _ = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    }
    
    func hiddenActivityIndicatorViewInNavigationItem() {
        self.navigationItem.titleView = nil
        self.navigationItem.prompt = nil
        self.refreshControl?.endRefreshing()
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
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && self.financeArray.count == 0 {
            return self.view.height - 149 - CGFloat(60 * self.announcements.count)
        }
        return 35
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
            return self.financeArray.count
        }
        return self.announcements.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let array = (indexPath.section == 1 ? self.announcements : self.financeArray)
        if let item = array[indexPath.row] as? AnnounceItem {
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuserCell, forIndexPath: indexPath) as? NewsTableViewCell {
                cell.setupNewsCell(item.title, date: item.date, isRead: item.isReaded)
                return cell
            }
        }else if let item = array[indexPath.row] as? NSDictionary {
            if let cell = tableView.dequeueReusableCellWithIdentifier(reuserCell, forIndexPath: indexPath) as? NewsTableViewCell {
                let title: String =  ((item.allKeys as NSArray).containsObject("pro_num") ? item.objectForKey("pro_num") as! String : "")
                let subtitle: String =  ((item.allKeys as NSArray).containsObject("pro_title") ? item.objectForKey("pro_title") as! String : "")
                cell.setupCell(title, date: subtitle, isRead: false)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.width, 30))
        headerView.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/205.0, alpha: 1)
        let text:String = (section == 0 ? "财务信息" : "部门公告")
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
        switch indexPath.section {
        case 1:
            if let item = self.announcements[indexPath.row] as? AnnounceItem {
                if !item.isReaded {
                    item.isReaded = true
                    self.numOfUnread--
                    self.tableView.reloadData()
                }
                NetworkRequest.AlamofireGetString(item.url, success: {
                    (data) in
                    let detailAnc:NewsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NewsViewController") as! NewsViewController
                    detailAnc.titles = item.title
                    detailAnc.title = "公告"
                    detailAnc.date = item.date
                    detailAnc.detail = data! as! String
                    let nav:UINavigationController = UINavigationController(rootViewController: detailAnc)
                    self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                    }, failed: {
                    }, outTime: {
                })
            }
        case 0:
            if let item = self.financeArray[indexPath.row] as? NSDictionary {
                let financeVC:SelfTableViewController = SelfTableViewController()
                financeVC.actionString = "payFinance:"
                financeVC.buttonTitle = "确认打款"
                financeVC.tableDataDic = item
                financeVC.navigationItem.title = "财务打款"
                financeVC.infoArray = ["pro_num","pro_title","date","type","money"]
                self.navigationController?.pushViewController(financeVC, animated: true)
            }
        default:break
        }
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
