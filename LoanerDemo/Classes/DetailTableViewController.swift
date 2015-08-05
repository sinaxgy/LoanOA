//
//  DetailTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController ,AddTableViewCellTextFieldDelegate,UIAlertViewDelegate{
    
    //var headTitle:String = ""
    var json:JSON = JSON.nullJSON           //存储“data”对应的value值
    var postDic:NSMutableDictionary = NSMutableDictionary()
    var resigntf:UITextField!
    var dbjson:JSON = JSON.nullJSON         //数据表字段json
    var isAdd:Bool = true
    var detailKeyArray:NSArray = []
    
    var typeTitle = operationType(type: "", typeName: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.typeTitle.typeName
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
        self.checkValueEmptyForIsEdit()
        if self.isAdd {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action:"postJson")
        }
    }
    
    func keyboardHide() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
            self.resigntf = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailKeyArray.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.setCellFromAddJSON(indexPath.row, forjson: self.json)
    }
    
    func catchTextFieldvalue(value: String, key: String) {
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
    }
    
    func postJson() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
        }
        if self.postDic.count < self.json.count {
            let alert = UIAlertView(title: "不完整的表单", message: "请完成整个表单", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
            return
        }
        var alert = UIAlertView(title: "注意", message: "确定提交速评表？\n提交完成之后不可修改！", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
        alert.show()
    }
    
    func setCellFromAddJSON(row: Int,forjson jsons:JSON) -> UITableViewCell{
        let key:String = self.detailKeyArray[row] as! String//jsons.dictionaryValue.keys.array[row]
        if let js = jsons.dictionary?[key as String] {
            let cell = DetailTableViewCell(title: key, forjson: js)
            cell.superView = self
            cell.textDelegate = self
            cell.editable = self.tableView.editing
            
            if cell.textfield.leftView != nil {
                cell.textfield.leftView = nil
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
    
    func setCellFromJSON(row: Int, twojson:JSON) -> UITableViewCell{
        let key = twojson.dictionaryValue.keys.array[row]
        if let js = twojson.dictionary?[key] {
            let cell = DetailTableViewCell(title: key, twojson: js)
            cell.superView = self
            cell.textDelegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func setCellFromDictionary(row: Int,dic:NSDictionary) -> UITableViewCell {
        let array:NSArray = dic.allKeys
        if let text:String = dic.objectForKey(array[row]) as? String {
            let cell = DetailTableViewCell(value: text, key: array[row] as! String)
            cell.superView = self
            cell.textDelegate = self
            if self.postDic.count > 0 {             //填写表单时的数据填充
                for rekey in self.postDic.allKeys {
                    if rekey as! String == array[row] as! String {
                        cell.textfield.text = self.postDic.objectForKey(rekey as! String) as! String
                        break
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func checkValueEmptyForIsEdit() {
        if self.json.type == .Dictionary {
            let dic:NSDictionary = (self.json.dictionary?[self.detailKeyArray.firstObject as! String]?.object as? NSDictionary)!
            for (key,value) in dic {
                if key as! String == "value" {
                    if value as! String != "" {
                        self.tableView.editing = false
                    }else {
                        self.tableView.editing = true
                    }
                    self.tableView.reloadData()
                }
                break
            }
        }
    }
    
    //MARK:--UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.show(true)
            progressHud.labelText = "正在提交表单"
            
            let user_id: NSString = AppDelegate.app().getuser_idFromPlist()
            self.postDic.setObject(AppDelegate.app().getoffline_id(), forKey: "offline_id")
            let pjs = JSON(self.postDic)
            let url = AppDelegate.app().ipUrl + config + "assess/app-add"
            
            NetworkRequest.AlamofirePostParameters(url,
                parameters: ["service_type":"\(self.typeTitle.type)","data":"\(pjs)","db_table":"\(self.dbjson)",
                "user_id":"\(user_id)"],
                success: {(data) in
                    println(data)
                    if data as! String == "success" {
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

                }, failed: {
                    progressHud.labelText = "连接异常"
                    progressHud.hide(true, afterDelay: 1)
                }, outTime: {
                    progressHud.labelText = "请求超时"
                    progressHud.hide(true, afterDelay: 1)})
            
            
        }
    }
}
