//
//  MasterImageTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/26.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

struct requestURL {
    var footer:String {
        didSet{
            self.URL = ipurl + config + self.footer
        }
    }
    var URL:String
    var pro_id:String
}

let ipurl = "http://\(AppDelegate.app().IP)/"
let placeholderImageName = "history"

class MasterImageTableViewController: UITableViewController {

    var picURL:requestURL = requestURL(footer: "", URL: "", pro_id: "");
    var masterJson:JSON = JSON.nullJSON
    var masterSubURL:NSMutableArray = []
    var titleArray:NSMutableArray = []
    let kSingleCell = "singleCell"
    var pro_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showActivityIndicatorViewInNavigationItem()
        self.tableView.registerNib(UINib(nibName: "SingleTableViewCell", bundle: nil), forCellReuseIdentifier: kSingleCell)
        var progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.show(true)
        NetworkRequest.AlamofireGetJSON(self.picURL.URL, success: {
            (data) in
            progressHud.hide(true)
            self.masterJson = JSON(data!)
            if self.masterJson != nil {
                self.tableView.reloadData()
            }
            self.hiddenActivityIndicatorViewInNavigationItem()
            }, failed: {
                self.hiddenActivityIndicatorViewInNavigationItem()
                progressHud.labelText = "连接异常"
                progressHud.hide(true, afterDelay: 1)}, outTime: {
                    self.hiddenActivityIndicatorViewInNavigationItem()
                    progressHud.labelText = "请求超时"
                    progressHud.hide(true, afterDelay: 1)})
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
        return self.masterJson.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SingleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kSingleCell, forIndexPath: indexPath) as! SingleTableViewCell
        let js = self.masterJson[indexPath.row];
        if js.type == .Dictionary {
            let dic:NSDictionary = js.object as! NSDictionary
            for (key,value) in dic {
                cell.titleLabel?.text = key.description
                self.titleArray.addObject(key.description)
                for (k,v) in value as! NSDictionary {
                    if k.description == "image" {
                        let url = AppDelegate.app().ipUrl + (v as! String)
                        cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                    }else if k.description == "url" {
                        var imgU:requestURL = requestURL(footer: "", URL: "", pro_id: "")
                        imgU.footer = v as! String
                        self.masterSubURL.addObject(imgU.URL)
                    }else if k.description == "date" {
                        cell.subTextLabel?.text = v as? String
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var subPicVC:SubPicTableViewController = SubPicTableViewController()
        subPicVC.title = self.titleArray[indexPath.row] as? String
        subPicVC.subURL = self.masterSubURL[indexPath.row] as! String
        subPicVC.pro_id = self.pro_id
        self.navigationController?.pushViewController(subPicVC, animated: true)
    }
}
