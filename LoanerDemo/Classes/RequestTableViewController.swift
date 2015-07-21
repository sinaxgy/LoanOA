//
//  RequestTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/17.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

struct tag_Infomation {
    var suffixURL:String
    var editable:Bool
    var tableJson:JSON
    var dbjson:JSON                 //数据表字段json
    var arraysort:NSArray
}

class RequestTableViewController: UITableViewController ,AddTableViewCellTextFieldDelegate{
    
    @IBOutlet var particularsCell: ParticularsTableViewCell!
    var tag_name:String = ""
    var pro_id:String = ""
    
    var tag_Message:tag_Infomation = tag_Infomation(suffixURL: "", editable: false, tableJson: JSON.nullJSON, dbjson: JSON.nullJSON, arraysort: [])
    
    var postDic:NSMutableDictionary = NSMutableDictionary()
    var resigntf:UITextField!
    
    var textDelegate:AddTableViewCellTextFieldDelegate!
    
    var request:Alamofire.Request? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
        
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 100))
        self.refreshControl?.addTarget(self, action: "reload:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.tableHeaderView?.addSubview(self.refreshControl!)
        self.reload(self.refreshControl!)
        
        self.showActivityIndicatorViewInNavigationItem()
    }
    
    func keyboardHide() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
            self.resigntf = nil
        }
    }
    
    func reload(sender:AnyObject) {
        if self.request == nil {
            let ip = "http://\(AppDelegate.app().IP)/"
            self.request = Alamofire.request(.GET, ip + config + readHisURL + self.tag_Message.suffixURL)
        }
        if (self.refreshControl!.refreshing) {
            self.refreshControl?.attributedTitle = NSAttributedString(string: "加载中...")
        }
        self.request?.responseJSON() {
            (_,_,data,error) in
            if error != nil {
                let alert:UIAlertView = UIAlertView(title: "错误", message: "加载数据失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                self.hideActivityIndicatorViewInNavigationItem()
                return
            }
            println(data)
            let mainJSON = JSON(data!)
            if mainJSON == nil {
                return
            }
            let mainKeys = mainJSON.dictionary!.keys.array
            for key in mainKeys {
                if let keyarray = mainJSON.dictionary?["arraysort"] {
                    if keyarray.type == .Array {
                        self.tag_Message.arraysort = (keyarray.object as? NSArray)!
                    }else {
                        let alert:UIAlertView = UIAlertView(title: "错误", message: "数据有误", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                    }
                }
                
                if let db_table = mainJSON.dictionary?["db_table"] {
                    self.tag_Message.dbjson = db_table
                }
                if let tag_name = mainJSON.dictionary?["tag_name"] {
                    self.tag_name = tag_name.description
                }
                if let data = mainJSON.dictionary?["data"] {
                    self.tag_Message.tableJson = data
                }
            }
            self.tableView.reloadData()
            self.title = self.tag_name
            self.hideActivityIndicatorViewInNavigationItem()
            self.checkValueEmptyForIsEdit()
        }
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        var actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.titleView = actView
        actView.startAnimating()
        self.navigationItem.prompt = "数据加载中..."
    }
    
    func hideActivityIndicatorViewInNavigationItem() {
        self.navigationItem.titleView = nil
        self.navigationItem.prompt = nil
        self.refreshControl?.endRefreshing()
        self.request = nil
    }
    
    func postJson(sender:UIBarButtonItem) {
        //println(self.postDic.allKeys)
        if self.postDic.count == 0 {
            return
        }
        var progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.labelText = "正在提交表单"
        progressHud.show(true)
        
        var request: Alamofire.Request?
        let user_id: NSString = AppDelegate.app().getuser_idFromPlist()
        self.postDic.setObject(AppDelegate.app().getoffline_id(), forKey: "offline_id")
        
        let pjs = JSON(self.postDic)
        //println(self.postDic)
        let ip = "http://\(AppDelegate.app().IP)/"
        request = Alamofire.request(.POST, ip + config + "app/save-info",
            parameters: ["pro_id":"\(self.pro_id)",
                "data":"\(pjs)",
                "db_table":"\(self.tag_Message.dbjson)",
                "user_id":"\(user_id)"])
        
        request?.responseString(){ (_, _, data, error) in
            if request == nil {
                return
            }
            if error != nil {
                progressHud.labelText = "连接异常"
                progressHud.hide(true, afterDelay: 1)
                return
            }
            println(data)
            if data == "success" {
                progressHud.labelText = "提交成功"
                progressHud.mode = MBProgressHUDMode.CustomView
                progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                progressHud.hide(true, afterDelay: 2)
                var gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
                dispatch_after(gcdT, dispatch_get_main_queue(), {
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                })
            }else{
                progressHud.labelText = "提交失败"
                progressHud.hide(true, afterDelay: 1)
            }
            request = nil
        }
        
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                request?.cancel()
                request = nil
                progressHud.labelText = "请求超时"
                progressHud.hide(true, afterDelay: 1)
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        })
    }
    
    func textFieldEditenable(sender:UIBarButtonItem) {
        if self.navigationItem.rightBarButtonItem != nil {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "postJson:")
        }
        self.tableView.editing = true
        self.tableView.reloadData()
    }
    
    func checkValueEmptyForIsEdit() {
        if !self.tag_Message.editable {
            return
        }
        //假如有编辑修改权限，遍历所有数据，若存在value值，则默认非编辑状态
        if self.tag_Message.tableJson.type == .Dictionary {
            var isEditable = true
            let dic:NSDictionary = (self.tag_Message.tableJson.dictionary?[self.tag_Message.arraysort.firstObject as! String]?.object as? NSDictionary)!
            for key in self.tag_Message.arraysort {
                let dic:NSDictionary = (self.tag_Message.tableJson.dictionary?[key as! String]?.object as? NSDictionary)!
                for (k,v) in dic {
                    if k as! String == "value" {
                        if v as? String == "" {
                            isEditable = true
                        }else {
                            isEditable = false
                        }
                        break
                    }
                }
                if isEditable {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "postJson:")
                }else {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: "textFieldEditenable:")
                    break
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCellFromAddJSON(row: Int,forjson jsons:JSON) -> UITableViewCell{
        let key:String = self.tag_Message.arraysort[row] as! String
        if let js = jsons.dictionary?[key as String] {
            var cell = DetailTableViewCell(title: key, forjson: js)
            cell.superView = self
            cell.textDelegate = self
            cell.editable = self.tableView.editing
            if self.postDic.count > 0 {             //填写表单时的数据填充
                for rekey in self.postDic.allKeys {
                    if rekey as! String == jsons.dictionaryValue.keys.array[row] as String {
                        cell.textfield.text = self.postDic.objectForKey(rekey as! String) as! String
                        break
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - TableViewCellTextFieldDelegate
    func catchTextFieldvalue(value: String, key: String) {
        self.postDic.setObject(value, forKey: key)
    }
    
    func signEditingTextField(textfield: UITextField) {
        if (self.resigntf != nil) {
            if self.resigntf == textfield {
                return
            }
        }
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
            self.resigntf = nil
        }
        self.resigntf = textfield
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
        return self.tag_Message.tableJson.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.setCellFromAddJSON(indexPath.row, forjson: self.tag_Message.tableJson)
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
