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
            println(self.URL)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkRequest.AlamofireGetJSON(self.picURL.URL, closure: {
            (data) in
            println(">>>>>>>>>>>>>")
            println(data)
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "masterCell")
        cell.imageView?.image = UIImage(named: "history")
        let js = self.masterJson[indexPath.row];
        if js.type == .Dictionary {
            let dic:NSDictionary = js.object as! NSDictionary
            for (key,value) in dic {
                cell.textLabel?.text = key.description
                for (k,value) in value as! NSDictionary {
                    if k.description == "iamge" {
                    }
                }
            }
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
