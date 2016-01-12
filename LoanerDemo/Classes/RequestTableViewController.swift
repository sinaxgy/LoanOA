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

class RequestTableViewController: UITableViewController ,AddTableViewCellTextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate,SignTextDelegate{
    
    var emptyAbleArray:NSMutableArray = []
    var editable:Bool = false
    
    var defaultText:DefaultText = DefaultText(fileName: "", dicTexts: [:])
    
    var tag_Message:tag_Infomation = tag_Infomation(suffixURL: "", editable: false, tableJson: JSON.null, dbjson: JSON.null, arraysort: [])
    
    var postDic:NSMutableDictionary = NSMutableDictionary()
    var resigntf:UITextField!
    var textDelegate:AddTableViewCellTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultText.dicTexts = LoanerHelper.infoWithFileName(self.defaultText.fileName)
        self.tableView.registerNib(UINib(nibName: "LeafTableViewCell", bundle: nil), forCellReuseIdentifier: "requestCell")
        self.reload()
        self.showActivityIndicatorViewInNavigationItem()
    }
    
    func keyboardHide() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
        }
    }
    
    func reload() {
        let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHud)
        progressHud.show(true)
        
        let url = AppDelegate.app().ipUrl + config + self.tag_Message.suffixURL
        NetworkRequest.AlamofireGetJSON(url, success: {(data) in
            let mainJSON = JSON(data!)
            if mainJSON.count == 0 {
                progressHud.labelText = "后台数据异常"
                progressHud.hide(true, afterDelay: 1)
                self.hideActivityIndicatorViewInNavigationItem()
                return
            }
            progressHud.hide(true)
            let mainKeys = mainJSON.dictionary!.keys
            for _ in mainKeys {
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
                    self.title = tag_name.description
                }
                if let data = mainJSON.dictionary?["data"] {
                    self.tag_Message.tableJson = data
                }
            }
            self.hideActivityIndicatorViewInNavigationItem()
            self.checkValueEmptyForIsEdit()
            self.tableView.reloadData()
            }, failed: {
                progressHud.labelText = "请求失败"
                progressHud.hide(true, afterDelay: 1)
            self.hideActivityIndicatorViewInNavigationItem()
            }, outTime: {
                progressHud.mode = MBProgressHUDMode.Text
                progressHud.labelText = "请求超时"
                progressHud.hide(true, afterDelay: 1)
                self.hideActivityIndicatorViewInNavigationItem()})
    }
    
    func showActivityIndicatorViewInNavigationItem() {
        let actView:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
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
            _ = (self.tag_Message.tableJson.dictionary?[self.tag_Message.arraysort.firstObject as! String]?.object as? NSDictionary)!
            for key in self.tag_Message.arraysort {
                let dic:NSDictionary = (self.tag_Message.tableJson.dictionary?[key as! String]?.object as? NSDictionary)!
                for (k,v) in dic {
                    if k as! String == "value" {
                        isEditable = ((v as? String == "") ? true : false)
                        break
                    }
                }
                if !isEditable {
                    break
                }
            }
            if isEditable {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: "postJson:")
                self.editable = true
            }else {
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
            let cell = DetailTableViewCell(title: key, forjson: js)
            cell.superView = self
            cell.textDelegate = self
            cell.editable = self.editable
            if cell.textfield.leftView != nil {
                if !self.emptyAbleArray.containsObject(cell.itemInfo.title) && cell.textfield.text == "" {  //记录所有必填项
                    self.emptyAbleArray.addObject(cell.itemInfo.title)
                }
            }
            if self.postDic.count > 0 {             //填写表单时的数据填充
                for rekey in self.postDic.allKeys {
                    if rekey as! String == cell.itemInfo.title {
                        cell.textfield.text = self.postDic.objectForKey(rekey as! String) as? String
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
        if key == "loan_term" {
            let index = self.tag_Message.arraysort.indexOfObject("repay_method")
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? DetailTableViewCell {
                let strValue = value as NSString
                if strValue.intValue < 31 {
                    cell.textfield.text = "融满付息，到期还本"
                }else {
                    cell.textfield.text = "融满按月付息，到期还本"
                }
            }
        }
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //return self.setCellFromAddJSON(indexPath.row, forjson: self.tag_Message.tableJson)
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! LeafTableViewCell
        
        let key:String = self.tag_Message.arraysort[indexPath.row] as! String
        if let js = self.tag_Message.tableJson.dictionary?[key as String] {
            cell.initCellInfomation(key, forjson: js, editable: self.editable)
        }
        if cell.itemInfo.options.count > 0 {
            for item in cell.itemInfo.options {
                if item as! String == "must" {
                    cell.titleLabel.textColor = UIColor(hex: mainColor)
                    break
                }
            }
        }
        if self.postDic.count > 0 {             //填写表单时的数据填充
            for rekey in self.postDic.allKeys {
                if rekey as! String == cell.itemInfo.title {
                    cell.detailLabel.text = self.postDic.objectForKey(rekey as! String) as? String
                    break
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.editable {return}
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LeafTableViewCell
        if !cell.itemInfo.editable {return}
        if cell.itemInfo.type.isEqualToString("select") {       //选择器
            let selectSheet:UIActionSheet = UIActionSheet()
            selectSheet.delegate = self
            for key in cell.itemInfo.options {
                selectSheet.addButtonWithTitle(key as? String)
            }
            selectSheet.addButtonWithTitle("取消")
            selectSheet.cancelButtonIndex = selectSheet.numberOfButtons - 1
            selectSheet.showInView(self.view)
        }else {
            let signView = SignViewController()
            if cell.itemInfo.options.count > 0 {
                for item in cell.itemInfo.options {
                    if item.description != "must" {signView.verify = item as! String}
                }
            }
            if defaultText.dicTexts.count > 0 {
                if (defaultText.dicTexts.allKeys as NSArray).containsObject(cell.itemInfo.title) {
                    if let dt = defaultText.dicTexts.objectForKey(cell.itemInfo.title) as? NSArray {
                        signView.defaultTexts = NSMutableArray(array: dt)
                    }
                }
            }
            signView.text = cell.itemInfo.value as String
            signView.delegate = self;signView.title = cell.itemInfo.explain as String
            if cell.itemInfo.type.isEqualToString("datepicker") {
                signView.isDateType = true
            }
            self.navigationController?.pushViewController(signView, animated: true)
        }
    }
    
    //MARK:--SignTextDelegate
    func signTextDidBeDone(text: String, texts: NSArray?) {
        
        let cell = self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow!) as! LeafTableViewCell
        cell.detailLabel.text = text
        cell.itemInfo.value = text
        self.postDic.setObject(cell.detailLabel.text!, forKey: cell.itemInfo.title as String)
        if texts != nil{
            if texts?.count > 0 {
                self.defaultText.dicTexts.setObject(texts!, forKey: cell.itemInfo.title as String)
                LoanerHelper.infoWriteToFile(defaultText.fileName, info: self.defaultText.dicTexts)
            }
        }
        //联动数据
        if cell.itemInfo.title == "loan_term" {
            let index = self.tag_Message.arraysort.indexOfObject("repay_method")
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? LeafTableViewCell {
                let strValue = text as NSString
                cell.detailLabel.text = (strValue.intValue < 31 ? "融满付息，到期还本" : "融满按月付息，到期还本")
            }
        }
    }
    
    //MARK:--UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let cell = self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow!) as! LeafTableViewCell
        if buttonIndex > cell.itemInfo.options.count - 1{
            return
        }
        cell.detailLabel.text = cell.itemInfo.options[buttonIndex] as? String
        self.postDic.setObject(cell.detailLabel.text!, forKey: cell.itemInfo.title as String)
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
            let progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.labelText = "正在提交表单"
            progressHud.show(true)
            
            let user_id: NSString = AppDelegate.app().user_id
            self.postDic.setObject(AppDelegate.app().getoffline_id(), forKey: "offline_id")
            
            let pjs = JSON(self.postDic)
            let url = AppDelegate.app().ipUrl + config + "app/save-info"
            NetworkRequest.AlamofirePostParameters(url,
                parameters: ["pro_id":"\(AppDelegate.app().pro_id)",
                "data":"\(pjs)",
                "db_table":"\(self.tag_Message.dbjson)",
                    "user_id":"\(user_id)"], success: {(data) in
                        if data as! String == "success" {
                            progressHud.labelText = "提交成功"
                            progressHud.mode = MBProgressHUDMode.CustomView
                            progressHud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                            progressHud.hide(true, afterDelay: 2)
                            let gcdT:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
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
