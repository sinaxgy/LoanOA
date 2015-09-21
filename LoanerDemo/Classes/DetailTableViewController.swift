//
//  DetailTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

struct DefaultText {    //TEXT默认文字存储
    var fileName:String! {
        didSet{
            self.dicTexts = LoanerHelper.infoWithFileName(fileName)
        }
    }
    var dicTexts:NSMutableDictionary
}

class DetailTableViewController: UITableViewController ,AddTableViewCellTextFieldDelegate,UIAlertViewDelegate,DatePickerViewDateDelegate,UIActionSheetDelegate,SignTextDelegate{
    
    //var headTitle:String = ""
    var json:JSON = JSON.nullJSON           //存储“data”对应的value值
    var postDic:NSMutableDictionary = NSMutableDictionary()
    var resigntf:UITextField!
    var dbjson:JSON = JSON.nullJSON         //数据表字段json
    var isAdd:Bool = true;var fileName:String = ""
    var detailKeyArray:NSArray = []
    var defaultText:DefaultText = DefaultText(fileName: "", dicTexts: [:])
    
    var typeTitle = operationType(type: "", proNum: "")
    let leafCell = "leafCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.typeTitle.proNum
        self.defaultText.dicTexts = LoanerHelper.infoWithFileName(self.defaultText.fileName)
        if self.isAdd {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action:"postJson")
        }
        self.tableView.registerNib(UINib(nibName: "LeafTableViewCell", bundle: nil), forCellReuseIdentifier: self.leafCell)
    }
    
    func keyboardHide() {
        if self.resigntf != nil {
            self.resigntf.resignFirstResponder()
            //self.resigntf = nil
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !self.isAdd {return}
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! LeafTableViewCell
        if !cell.itemInfo.editable {return}
        if cell.itemInfo.type.isEqualToString("select") {       //选择器
            var selectSheet:UIActionSheet = UIActionSheet()
            selectSheet.delegate = self
            for key in cell.itemInfo.options {
                selectSheet.addButtonWithTitle(key as! String)
            }
            selectSheet.addButtonWithTitle("取消")
            selectSheet.cancelButtonIndex = selectSheet.numberOfButtons - 1
            selectSheet.showInView(self.view)
        }else {
            var signView = SignViewController()
            if cell.itemInfo.options.count > 0 {    //传入校验方式
                for item in cell.itemInfo.options {
                    if item.description != "must" {signView.verify = item as! String}
                }
            }
            if self.defaultText.dicTexts.count > 0 {    //读取并传入对应输入历史
                if (self.defaultText.dicTexts.allKeys as NSArray).containsObject(cell.itemInfo.title) {
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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //return self.setCellFromAddJSON(indexPath.row, forjson: self.json)
        var cell = tableView.dequeueReusableCellWithIdentifier(self.leafCell, forIndexPath: indexPath) as! LeafTableViewCell
        let key:String = self.detailKeyArray[indexPath.row] as! String
        if let js = self.json.dictionary?[key as String] {
            cell.initCellInfomation(key, forjson: js, editable: isAdd)
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
            cell.editable = self.isAdd
            cell.titleLabel.textColor = UIColor.blackColor()
            if cell.textfield.leftView != nil {
                cell.textfield.leftView = nil
            }
            if self.postDic.count > 0 {             //填写表单时的数据填充
                for rekey in self.postDic.allKeys {
                    if rekey as! String == cell.itemInfo.title {
                        cell.textfield.text = self.postDic.objectForKey(rekey as! String) as! String
                        break
                    }
                }
            } 
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK:--UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var progressHud:MBProgressHUD = MBProgressHUD(view: self.navigationController!.view)
            self.navigationController?.view.addSubview(progressHud)
            progressHud.show(true)
            progressHud.labelText = "正在提交表单"
            
            let user_id: NSString = AppDelegate.app().user_id
            self.postDic.setObject(AppDelegate.app().getoffline_id(), forKey: "offline_id")
            let pjs = JSON(self.postDic)
            let url = AppDelegate.app().ipUrl + config + "assess/app-add"
            
            NetworkRequest.AlamofirePostParameters(url,
                parameters: ["service_type":"\(self.typeTitle.type)","data":"\(pjs)","db_table":"\(self.dbjson)",
                "user_id":"\(user_id)"],
                success: {(data) in
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
    
    //MARK:--UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let cell = self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow()!) as! LeafTableViewCell
        if buttonIndex > cell.itemInfo.options.count - 1{
            return
        }
        cell.detailLabel.text = cell.itemInfo.options[buttonIndex] as? String
        self.postDic.setObject(cell.detailLabel.text!, forKey: cell.itemInfo.title as String)
    }
    
    //MARK:--SignTextDelegate
    func signTextDidBeDone(text: String, texts: NSArray?) {
        let cell = self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow()!) as! LeafTableViewCell
        let conditions:NSArray = ["mg_price","mg_assessprice","mg_adviceprice","car_bdate","car_ldate"]
        if conditions.containsObject(cell.itemInfo.title) {
            let message = self.checkInputPriceValue(cell.itemInfo.title as String, text: text)
            if  message != "" {
                let progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
                progressHud.mode = MBProgressHUDMode.Text
                progressHud.detailsLabelText = message as String
                progressHud.detailsLabelFont = UIFont.systemFontOfSize(17)
                progressHud.show(true)
                progressHud.hide(true, afterDelay: 2)
                progressHud.yOffset = Float(progressHud.frame.origin.y)
                self.view.addSubview(progressHud)
                return
            }
        }
        cell.detailLabel.text = text
        cell.itemInfo.value = text
        if text != "" {
            self.postDic.setObject(cell.detailLabel.text!, forKey: cell.itemInfo.title as String)
        }
        if texts != nil{
            if texts?.count > 0 {
                self.defaultText.dicTexts.setObject(texts!, forKey: cell.itemInfo.title as String)
                LoanerHelper.infoWriteToFile(self.defaultText.fileName, info: self.defaultText.dicTexts)
            }
        }
    }
    
    func checkInputPriceValue(key:String,text:String) -> NSString {
        var message:NSMutableString = ""
        switch key {                //远》估》建议金额
        case "mg_price":            //原价：不能小于估价
            if (self.postDic.allKeys as NSArray).containsObject("mg_assessprice") {
                let mg_assessprice: Float = NSString(string: self.postDic["mg_assessprice"] as! String).floatValue
                let value = NSString(string: text).floatValue
                if value < mg_assessprice {
                    message.appendString("抵押物原价不能小于其估价！")
                }
            }
            if (self.postDic.allKeys as NSArray).containsObject("mg_adviceprice") {
                let mg_adviceprice: Float = NSString(string: self.postDic["mg_adviceprice"] as! String).floatValue
                let value = NSString(string: text).floatValue
                if value < mg_adviceprice {
                    message.appendString((message == "" ? "" : "\n"))
                    message.appendString("抵押物原价不能小于建议金额！")
                }
            }
        case "mg_assessprice":      //估价：不能大于原价，不能小于建议金额
            if (self.postDic.allKeys as NSArray).containsObject("mg_price") {
                let mg_price: Float = NSString(string: self.postDic["mg_price"] as! String).floatValue
                if NSString(string: text).floatValue > mg_price {
                    message.appendString("抵押物估价不能大于其原价！")
                }
            }
            if (self.postDic.allKeys as NSArray).containsObject("mg_adviceprice") {
                let mg_adviceprice: Float = NSString(string: self.postDic["mg_adviceprice"] as! String).floatValue
                if NSString(string: text).floatValue < mg_adviceprice {
                    message.appendString((message == "" ? "" : "\n"))
                    message.appendString("抵押物估价不能小于建议金额！")
                }
            }
        case "mg_adviceprice":      //建议金额：不能大于估价
            if (self.postDic.allKeys as NSArray).containsObject("mg_price") {
                let mg_price: Float = NSString(string: self.postDic["mg_price"] as! String).floatValue
                if NSString(string: text).floatValue > mg_price {
                    message.appendString("建议金额不能大于抵押物原价！")
                }
            }
            if (self.postDic.allKeys as NSArray).containsObject("mg_assessprice") {
                let mg_assessprice: Float = NSString(string: self.postDic["mg_assessprice"] as! String).floatValue
                if NSString(string: text).floatValue > mg_assessprice {
                    message.appendString((message == "" ? "" : "\n"))
                    message.appendString("建议金额不能大于抵押物估价！")
                }
            }
        case "car_bdate":      //出厂日期早于初登日期
            if (self.postDic.allKeys as NSArray).containsObject("car_ldate") {
                let car_ldate: String = self.postDic["car_ldate"] as! String
                if text > car_ldate {
                    message.appendString("出厂日期不能晚于初登日期！")
                }
            }
        case "car_ldate":       //初登日期晚于出厂日期
            if (self.postDic.allKeys as NSArray).containsObject("car_bdate") {
                let car_ldate: String = self.postDic["car_bdate"] as! String
                if text < car_ldate {
                    message.appendString("初登日期不能早于出厂日期！")
                }
            }
        default:
            break
        }
        return message
    }
    
    //MARK:--DatePickerViewDateDelegate
    func datePickerDidEnsure(date: String) {
    }
    
    func datePickerDidCancel() {
    }
}
