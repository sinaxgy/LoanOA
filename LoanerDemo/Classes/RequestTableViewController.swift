//
//  RequestTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/17.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

struct tag_Infomation {
    var suffixURL:String
    var editable:Bool
    var tableJson:JSON
    var dbjson:JSON                 //数据表字段json
    var arraysort:NSArray
}

class RequestTableViewController: UITableViewController ,AddTableViewCellTextFieldDelegate,UIAlertViewDelegate{
    
    @IBOutlet var particularsCell: ParticularsTableViewCell!
    var tag_name:String = ""
    var emptyAbleArray:NSMutableArray = []
    var pro_id:String = ""
    var editable:Bool = false;var isNew:Bool = false
    
    var tag_Message:tag_Infomation = tag_Infomation(suffixURL: "", editable: false, tableJson: JSON.nullJSON, dbjson: JSON.nullJSON, arraysort: [])
    
    var postDic:NSMutableDictionary = NSMutableDictionary()
    var resigntf:UITextField!
    
    var textDelegate:AddTableViewCellTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
    
        self.reload()
        
        self.showActivityIndicatorViewInNavigationItem()
    }
    
    func keyboardHide() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
            self.resigntf = nil
        }
    }
    
    func reload() {
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
        self.navigationController?.view.addSubview(progressHud)
        progressHud.show(true)
        
        let url = AppDelegate.app().ipUrl + config + self.tag_Message.suffixURL
        NetworkRequest.AlamofireGetJSON(url, success: {(data) in
            println(data)
            let mainJSON = JSON(data!)
            if mainJSON.count == 0 {
                progressHud.labelText = "后台数据异常"
                progressHud.hide(true, afterDelay: 1)
                self.hideActivityIndicatorViewInNavigationItem()
                return
            }
            progressHud.hide(true)
            println(mainJSON)
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
            self.hideActivityIndicatorViewInNavigationItem()
            self.checkValueEmptyForIsEdit()
            self.tableView.reloadData()
            self.title = self.tag_name
            }, failed: {
                progressHud.labelText = "请求失败"
                progressHud.hide(true, afterDelay: 1)
            self.hideActivityIndicatorViewInNavigationItem()
            }, outTime: {
                progressHud.labelText = "请求超时"
                progressHud.hide(true, afterDelay: 1)
                self.hideActivityIndicatorViewInNavigationItem()})
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
    }
    
    func postJson(sender:UIBarButtonItem) {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
        }
        let alert = UIAlertView(title: "保存资料", message: "确定保存资料？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.show()
    }
    
    func textFieldEditenable(sender:UIBarButtonItem) {
        if self.navigationItem.rightBarButtonItem != nil {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "postJson:")
        }
        self.editable = true
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
                if !isEditable {
                    break
                }
            }
            if isEditable {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: "postJson:")
                self.editable = true;self.isNew = true
            }else {
                self.isNew = false
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: "textFieldEditenable:")
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
            cell.editable = self.editable
            if cell.textfield.leftView != nil {
                if !self.emptyAbleArray.containsObject(cell.itemInfo.title) && cell.textfield.text == "" {
                    self.emptyAbleArray.addObject(cell.itemInfo.title)
                }
            }
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
        if value == "" {
            return
        }
        self.postDic.setObject(value, forKey: key)
    }
    
    func signEditingTextField(textfield: UITextField,cell:DetailTableViewCell) {
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
        
        if textfield.leftView != nil {
            if !self.emptyAbleArray.containsObject(cell.itemInfo.title) {
                self.emptyAbleArray.addObject(cell.itemInfo.title)
            }
        }
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
    
    //MARK:--UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            let keys:NSArray = self.postDic.allKeys
            for key in self.emptyAbleArray {
                if !keys.containsObject(key) {
                    let alert:UIAlertView = UIAlertView(title: "错误", message: "请完成必填表单", delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                    return
                }
            }
            var progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.labelText = "正在提交表单"
            progressHud.show(true)
            
            let user_id: NSString = AppDelegate.app().getuser_idFromPlist()
            self.postDic.setObject(AppDelegate.app().getoffline_id(), forKey: "offline_id")
            
            let pjs = JSON(self.postDic)
            println(self.postDic)
            let url = AppDelegate.app().ipUrl + config + "app/save-info"
            NetworkRequest.AlamofirePostParameters(url,
                parameters: ["pro_id":"\(self.pro_id)",
                "data":"\(pjs)",
                "db_table":"\(self.tag_Message.dbjson)",
                    "user_id":"\(user_id)"], success: {(data) in
                        if data as! String == "success" {
                            progressHud.labelText = "提交成功"
                            progressHud.mode = MBProgressHUDMode.CustomView
                            progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                            progressHud.hide(true, afterDelay: 2)
                            var gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
                            dispatch_after(gcdT, dispatch_get_main_queue(), {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            })
                        }else{
                            progressHud.labelText = "提交失败"
                            progressHud.hide(true, afterDelay: 1)
                        }
                }, failed: {
                        progressHud.labelText = "连接异常"
                        progressHud.hide(true, afterDelay: 1)
                }, outTime: {
                    progressHud.labelText = "请求超时"
                    progressHud.hide(true, afterDelay: 1)})
        }
    }
}
