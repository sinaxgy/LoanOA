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
}

let ipurl = "http://\(AppDelegate.app().IP)/"
let placeholderImageName = "defaultimage"

class MasterImageTableViewController: UITableViewController {

    var picURL:requestURL = requestURL(footer: "", URL: "");//, pro_id: "");
    var masterJson:JSON = JSON.null
    var masterSubURL:NSMutableArray = []
    var titleArray:NSMutableArray = []
    let kSingleCell = "singleCell";var editable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showActivityIndicatorViewInNavigationItem()
        self.tableView.registerNib(UINib(nibName: "SingleTableViewCell", bundle: nil), forCellReuseIdentifier: kSingleCell)
        NetworkRequest.AlamofireGetJSON(self.picURL.URL, success: {
            (data) in
            self.masterJson = JSON(data!)
            if self.masterJson != nil {
                self.tableView.reloadData()
            }
            self.hiddenActivityIndicatorViewInNavigationItem()
            }, failed: {
                self.hiddenActivityIndicatorViewInNavigationItem()
            }, outTime: {
                    self.hiddenActivityIndicatorViewInNavigationItem()
        })
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        let actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
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
        return 70
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SingleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kSingleCell, forIndexPath: indexPath) as! SingleTableViewCell
        cell.isMutable = false
        let js = self.masterJson[indexPath.row];
        if js.type == .Dictionary {
            let dic:NSDictionary = js.object as! NSDictionary
            for (key,value) in dic {
                cell.titleLabel?.text = key.description
                self.titleArray.addObject(key.description)
                for (k,v) in value as! NSDictionary {
                    if k.description == "image" {
                        let url = AppDelegate.app().ipUrl + (v as! String) + "?\(arc4random() % 100)"
                        cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                    }else if k.description == "url" {
                        var imgU:requestURL = requestURL(footer: "", URL: "")
                        imgU.footer = v as! String
                        self.masterSubURL.addObject(imgU.URL)
                    }else if k.description == "date" {
                        cell.subTextLabel?.text = v as? String
                    }
                }
            }
        }
        cell.titleLabel.font = UIFont.systemFontOfSize(textFontSize)
        cell.subTextLabel.font = UIFont.systemFontOfSize(detailFontSize)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subPicVC:SubPicTableViewController = SubPicTableViewController()
        subPicVC.title = self.titleArray[indexPath.row] as? String
        subPicVC.subURL = self.masterSubURL[indexPath.row] as! String
        subPicVC.editable = self.editable
        self.navigationController?.pushViewController(subPicVC, animated: true)
    }
}
