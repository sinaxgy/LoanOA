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
    let reuserCell = "anCell"
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
        let url = AppDelegate.app().ipUrl + config + "app/news?id=\(AppDelegate.app().offline_id)"
        NetworkRequest.AlamofireGetJSON(url, success: {
            (data) in
            let json:JSON = JSON(data!)
            if json.count == 0 {self.thereisNoAnnouncement()}
            self.announcements = []
            for (f,it) in json {
                let item:AnnounceItem = AnnounceItem(json: it)
                self.announcements.addObject(item)
                if !item.isReaded {
                    self.numOfUnread++
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
                self.unConnectedView = UIImageView(frame: UIScreen.mainScreen().bounds)
                self.unConnectedView.image = UIImage(named: "noAnnounce")
                self.view.addSubview(self.unConnectedView)
                self.navigationItem.title = "公告（未连接）"
            }, outTime: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                self.navigationItem.title = "公告（未连接）"
        })
    }
    
    func thereisNoAnnouncement() {
        var bk:UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        bk.image = UIImage(named: "noAnnounce")
        self.view.addSubview(bk)
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        var actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //self.navigationItem.titleView = actView
        //actView.startAnimating()
        //self.navigationItem.prompt = "数据加载中..."
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
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.announcements.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let item = self.announcements[indexPath.row] as? AnnounceItem {
            if var cell = tableView.dequeueReusableCellWithIdentifier(reuserCell, forIndexPath: indexPath) as? NewsTableViewCell {
                cell.setupCell(item.title, date: item.date, isRead: item.isReaded)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = self.announcements[indexPath.row] as? AnnounceItem {
            if !item.isReaded {
                item.isReaded = true
                self.numOfUnread--
                self.tableView.reloadData()
            }
            NetworkRequest.AlamofireGetString(item.url, success: {
                (data) in
                var detailAnc:NewsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NewsViewController") as! NewsViewController
                detailAnc.titles = item.title
                detailAnc.title = "公告"
                detailAnc.date = item.date
                detailAnc.detail = data! as! String
                let nav:UINavigationController = UINavigationController(rootViewController: detailAnc)
                self.navigationController?.presentViewController(nav, animated: true, completion: nil)
                }, failed: {
                    println("error")
                }, outTime: {
                    println("outtime")
            })
        }
    }
}
