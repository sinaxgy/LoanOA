//
//  MasterImageTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/26.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

class MasterImageTableViewController: UITableViewController {

    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkRequest.AlamofireGetJSON("", closure: {
            (data) in
            println(data)
        })
    }
    
    
    func reload(sender:AnyObject) {
        if self.request == nil {
            let ip = "http://\(AppDelegate.app().IP)/"
            self.request = Alamofire.request(.GET, ip + config + readHisURL + "\(AppDelegate.app().getuser_idFromPlist())")
        }
        
        self.request?.responseJSON(){ (_, _, json, error) in
            if self.request == nil {
                return
            }
            if error != nil {
                switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
                case .OrderedSame, .OrderedDescending:
                    var alert:UIAlertController = UIAlertController(title: "错误", message: "装载失败", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                case .OrderedAscending:
                    
                    let alert:UIAlertView = UIAlertView(title: "错误", message: "加载数据失败", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                }
                self.request = nil
                return
            }
            println(json)
            self.tableView.reloadData()
            self.request = nil
        }
        
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if self.request != nil {
                self.request?.cancel()
                self.request = nil
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
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
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

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
