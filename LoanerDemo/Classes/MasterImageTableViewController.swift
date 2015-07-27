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

class MasterImageTableViewController: UITableViewController {

    var picURL:requestURL = requestURL(footer: "", URL: "", pro_id: "");
    var masterJson:JSON = JSON.nullJSON
    var masterSubURL:NSMutableArray = []
    let kSingleCell = "singleCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "SingleTableViewCell", bundle: nil), forCellReuseIdentifier: kSingleCell)
        NetworkRequest.AlamofireGetJSON(self.picURL.URL, closure: {
            (data) in
            self.masterJson = JSON(data)
            self.tableView.reloadData()
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
                for (k,v) in value as! NSDictionary {
                    if k.description == "image" {
                        let url = AppDelegate.app().ipUrl + (v as! String)
                        cell.imageV?.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "history"))
                    }else if k.description == "url" {
                        var imgU:requestURL = requestURL(footer: "", URL: "", pro_id: "")
                        imgU.footer = v as! String
                        self.masterSubURL.addObject(imgU.URL)
                    }
                    cell.subTextLabel?.text = "2015/07/27"
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var subPicVC:SubPicTableViewController = SubPicTableViewController()
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        subPicVC.title = cell?.textLabel?.text
        subPicVC.subURL = self.masterSubURL[indexPath.row] as! String
        self.navigationController?.pushViewController(subPicVC, animated: true)
    }
}
