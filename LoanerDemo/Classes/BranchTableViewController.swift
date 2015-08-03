//
//  BranchTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

struct proInfomation {
    let editableArray:NSMutableArray
    var promptArray:NSMutableArray
    var subjson:JSON                   //存储所有标签页的“data”对应的value值，数组形式
}

struct operationType {
    var type:String
    var typeName:String
}

class BranchTableViewController: UITableViewController ,UIActionSheetDelegate{
    
    var isAdd:Bool = true
    var pro_id:String = ""
    var typeOp = operationType(type: "", typeName: "")
    var dbjson:JSON = JSON.nullJSON
    var detailKeyArray:NSArray = []
    var url = ""
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    var proMessage = proInfomation(editableArray: [], promptArray: [],subjson: JSON.nullJSON)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.typeOp.typeName
        self.showActivityIndicatorViewInNavigationItem()
        self.loadJSONOfView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action:"cancel:")
    }
    
    func cancel(sender:UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
    
    func loadJSONOfView() {
        NetworkRequest.AlamofireGetJSON(self.url, success: { (data) in
            if data == nil {
                self.hiddenActivityIndicatorViewInNavigationItem()
                self.title = "后台无数据"
                return
            }
            let js:JSON = JSON(data!)
            var jsonArray:NSMutableArray = NSMutableArray()
            var msgArray:NSMutableArray = []
            var jsArray:NSMutableArray = []
            for key in js.dictionary!.keys.array {
                if key == "view" {
                    let viewJson:JSON = js[key]
                    if viewJson.count == 0 {
                        //self.tableView.reloadData()
                        self.navigationItem.titleView = nil
                        self.navigationItem.prompt = nil
                        self.title = "无速评表数据"
                        let alert:UIAlertView = UIAlertView(title: "错误", message: "无速评表数据", delegate: nil, cancelButtonTitle: "确定")
                        alert.show()
                        return
                    }
                    let tabAr:NSArray = viewJson.dictionary!.keys.array     //获取“view”下的key“info”
                    for tab in tabAr {
                        let tabJson:JSON = viewJson.dictionary![tab as! String]!
                        if let tag_name = tabJson.dictionary!["tag_name"]?.description {
                            msgArray.addObject(tag_name)
                        }
                        
                        if let keyarray = tabJson.dictionary?["arraysort"] {
                            if keyarray.type == .Array {
                                self.detailKeyArray = (keyarray.object as? NSArray)!
                            }else {
                                let alert:UIAlertView = UIAlertView(title: "错误", message: "数据有误", delegate: nil, cancelButtonTitle: "确定")
                                alert.show()
                            }
                        }
                        
                        if let value = tabJson.dictionary?["data"] {
                            jsArray.addObject(value.object)
                        }
                        if let editable = tabJson.dictionary?["editable"] {
                            self.proMessage.editableArray.addObject(editable.description)
                        }
                    }
                } else if key == "db_table" {
                    self.dbjson = js[key]
                }
            }
            self.reSortArrayAndJson(msgArray, jsAr: jsArray)
            self.tableView.reloadData()
            self.hiddenActivityIndicatorViewInNavigationItem()
            }, failed: {
                self.title = self.typeOp.typeName
                self.hiddenActivityIndicatorViewInNavigationItem()}, outTime: {
                    self.hiddenActivityIndicatorViewInNavigationItem()})
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
        return self.proMessage.promptArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        cell.textLabel?.text = self.proMessage.promptArray[indexPath.row] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println(self.proMessage.subjson[indexPath.row])
        switch self.proMessage.subjson[indexPath.row].count {
        case 0:
            if self.proMessage.promptArray[indexPath.row] as! String == "图片上传" {
                println("图片上传")
                var imageVC:MasterImageTableViewController = MasterImageTableViewController()
                imageVC.picURL.footer = self.proMessage.subjson[indexPath.row].description
                imageVC.title = "图片上传"
                imageVC.pro_id = self.pro_id
                self.navigationController?.pushViewController(imageVC, animated: true)
                return
            }
            var requestVC:RequestTableViewController = RequestTableViewController()
            let ip = "http://\(AppDelegate.app().IP)/"
            requestVC.tag_Message.suffixURL = self.proMessage.subjson[indexPath.row].description
            requestVC.request = Alamofire.request(.GET, ip + config + self.proMessage.subjson[indexPath.row].description)
            let editable:String = self.proMessage.editableArray[indexPath.row] as! String
            if editable == "true" {
                requestVC.tag_Message.editable = true
            }else if editable == "false" {
                requestVC.tag_Message.editable = false
            }
            requestVC.pro_id = self.pro_id
            self.navigationController?.pushViewController(requestVC, animated: true)
        case 2:
            let circleVC:CircleViewController = CircleViewController()//(nibName: "FeedbackViewController", bundle: nil)
            circleVC.json = self.proMessage.subjson[indexPath.row]
            circleVC.pro_id = self.pro_id
            self.navigationController?.pushViewController(circleVC, animated: true)
        case 13:
            var detailView:DetailTableViewController = DetailTableViewController()
            detailView.json = self.proMessage.subjson[indexPath.row]
            detailView.isAdd = self.isAdd
            detailView.detailKeyArray = self.detailKeyArray
            detailView.typeTitle.typeName = (self.proMessage.promptArray[indexPath.row] as? String)!
            detailView.typeTitle.type = self.typeOp.type
            detailView.dbjson = self.dbjson
            self.navigationController?.pushViewController(detailView, animated: true)
        case 14:
            var detailView:DetailTableViewController = DetailTableViewController()
            detailView.json = self.proMessage.subjson[indexPath.row]
            detailView.isAdd = self.isAdd
            detailView.detailKeyArray = self.detailKeyArray
            detailView.typeTitle.typeName = (self.proMessage.promptArray[indexPath.row] as? String)!
            detailView.typeTitle.type = self.typeOp.type
            detailView.dbjson = self.dbjson
            self.navigationController?.pushViewController(detailView, animated: true)
        default:
            let alert:UIAlertView = UIAlertView(title: "错误", message: "后台传输数据有误", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func reSortArrayAndJson(msgAr:NSMutableArray,jsAr:NSMutableArray) {
        var ar = msgAr
        var jsa = jsAr
        var jsonArray:NSMutableArray = NSMutableArray()
        var index = 0
        for msg in msgAr {
            if msg as! String == "基本信息" {
                self.proMessage.promptArray.addObject(msg)
                ar.removeObject(msg)
                self.proMessage.promptArray.addObjectsFromArray(ar as [AnyObject])
                //println(self.proMessage.promptArray)
                
                jsonArray.addObject(jsAr.objectAtIndex(index))
                jsa.removeObjectAtIndex(index)
                jsonArray.addObjectsFromArray(jsa as [AnyObject])
                //println(jsonArray)
                self.proMessage.subjson = JSON(jsonArray)
                break
            }
            index++
        }
    }
}
