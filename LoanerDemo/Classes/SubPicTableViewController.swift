//
//  SubPicTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/27.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import AVFoundation

let parallelNum = 2
//MARK:--自定义运算符
infix operator %+ {associativity left precedence 150}
func %+ (left:Int,right:Int) -> Int {
    if left % right != 0 {
        return left / right + 1
    }
    return left / right
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

class SubPicTableViewController: UITableViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ZLPhotoPickerBrowserViewControllerDelegate,ZLPhotoPickerBrowserViewControllerDataSource,UIAlertViewDelegate{
    
    var subURL:String = "";let deleteTag = 200;let replaceTag = 201
    var tableArray:NSMutableArray = []
    let kMutableCell = "mutableCell"
    let kSingleCell = "singleCell"
    let kMutablePhotoesCell = "mutablePhotoesCell"
    //var pro_id = "";
    var editable = false
    var selectedIndexPath:NSIndexPath = NSIndexPath()
    var hudProgress:MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "MutableTableViewCell", bundle: nil), forCellReuseIdentifier: kMutableCell)
        self.tableView.registerNib(UINib(nibName: "SingleTableViewCell", bundle: nil), forCellReuseIdentifier: kSingleCell)
        self.tableView.registerNib(UINib(nibName: "PopMutableTableViewCell", bundle: nil), forCellReuseIdentifier: kMutablePhotoesCell)
        self.reload()
        
    }
    
    func reload(){
        self.showActivityIndicatorViewInNavigationItem()
        //var progressHud:MBProgressHUD = MBProgressHUD(view: self.view)
        //self.navigationController?.view.addSubview(progressHud)
        //progressHud.show(true)
        NetworkRequest.AlamofireGetJSON(self.subURL, success: {
            (data) in
            //progressHud.hide(true)
            let js:JSON = JSON(data!)
            if js.type == .Array {
                for var i:Int = 0; i < js.count ; i++ {
                    let element = js[i]
                    for (key,value) in element {
                        let item:PicJsonItemInfo = PicJsonItemInfo(tbName: key as String, json: value)
                        self.tableArray.addObject(item)
                    }
                }
            }
            self.tableView.reloadData()
            self.hiddenActivityIndicatorViewInNavigationItem()
            }, failed: {
//                progressHud.labelText = "连接异常"
                //                progressHud.hide(true, afterDelay: 1)
                self.hiddenActivityIndicatorViewInNavigationItem()
            }, outTime: {
                self.hiddenActivityIndicatorViewInNavigationItem()
//                    progressHud.labelText = "请求超时"
//                    progressHud.hide(true, afterDelay: 1)
        })
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
        return self.tableArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let item = self.tableArray[indexPath.row] as? NSArray {
            let k = item.count %+ Int(UIScreen.mainScreen().bounds.width / 90)
            return CGFloat(k) * 100
        }
        return 70
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        println("_____________________")
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item = self.tableArray[indexPath.row] as! PicJsonItemInfo
        if item.imageurl.count == 0 {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        self.selectedIndexPath = indexPath
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SingleTableViewCell {
            var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "删除") { (rowAction, index) -> Void in
                    if cell.isMutable {
                        let alert = UIAlertView(title: "注意", message: "此条目包含多张图片，继续将删除所有条目", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "继续")
                        alert.tintColor = UIColor.redColor()
                        alert.tag = self.deleteTag
                        alert.show()
                    }else {
                        self.delete()
                    }
            }
            deleteRowAction.backgroundColor = UIColor.redColor()
            
            var replaceRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "替换") { (rowAction, index) -> Void in
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SingleTableViewCell {
                    var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                    sheetAction.showInView(self.view)
                }
            }
            replaceRowAction.backgroundColor = UIColor(hex: mainColor)
            
            if cell.isMutable {
                replaceRowAction.title = "新增"
            }
            return [deleteRowAction,replaceRowAction]
        }
        return []
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.tableArray[indexPath.row].isKindOfClass(PicJsonItemInfo) {
            let item:PicJsonItemInfo = self.tableArray[indexPath.row] as! PicJsonItemInfo
            if var cell:SingleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kSingleCell, forIndexPath: indexPath) as? SingleTableViewCell {
                let url = (item.imageurl.count > 0 ? ("\(AppDelegate.app().ipUrl)" + (item.imageurl.firstObject as! String) + "?\(arc4random() % 1000)") : "")
                cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                cell.subTextLabel?.text = item.date
                cell.isMutable = NSString(string: item.multipage).boolValue
                cell.titleLabel.text = (cell.isMutable ? (item.pic_explain + "（\(item.imageurl.count)）") : item.pic_explain)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        if let item:PicJsonItemInfo = self.tableArray[indexPath.row] as? PicJsonItemInfo{
            if item.imageurl.count > 0 {
                self.hudProgress = MBProgressHUD(view: self.view)
                self.navigationController?.view.addSubview(self.hudProgress)
                self.hudProgress.show(true)
                //self.setupPhotoBrowser()
                var photoBrowser:ZLPhotoPickerBrowserViewController = ZLPhotoPickerBrowserViewController()
                let nav:UINavigationController = UINavigationController(rootViewController: photoBrowser)
                photoBrowser.delegate = self
                photoBrowser.dataSource = self
                photoBrowser.isMutable = NSString(string: item.multipage).boolValue
                photoBrowser.imageUrls = LoanerHelper.OriginalUrlArraywith(item.imageurl)
                photoBrowser.navigationItem.title = item.pic_explain
                photoBrowser.currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.presentViewController(nav, animated: false, completion: nil)
            }
            if item.imageurl.count == 0 && self.editable {
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                //sheetAction.tintColor = UIColor(hex: mainColor)
                sheetAction.showInView(self.view)
            }
        }
    }
    
    //MARK:-----MutableTableViewDelegate
    func mutablePhotoesDidBeshowedMore(cell: MutableTableViewCell, isShow: Bool) {
        let indexPath:NSIndexPath = self.tableView.indexPathForCell(cell)!
        let insertPath:NSIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        if let item = self.tableArray[indexPath.row] as? PicJsonItemInfo {
            if item.imageurl.count == 0 {
                return
            }else {
                if isShow { //展示
                    self.tableArray.insertObject(item.imageurl, atIndex: indexPath.row + 1)
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([insertPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    self.tableView.endUpdates()
                }else {
                    self.tableArray.removeObjectAtIndex(insertPath.row)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths([insertPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    //MARK:-----Camera function
    func takePhoto(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            var picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            //picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(picker, animated: true, completion: nil)             //yes?
        }else{
            let alert:UIAlertView = UIAlertView(title: "错误", message: "摄像头不可用", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    //UIImagePickerControllerDelegate拍摄完执行
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        var image:UIImage = info[UIImagePickerControllerOriginalImage]! as! UIImage
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        if image.imageOrientation != UIImageOrientation.Up {
            UIGraphicsBeginImageContext(image.size)
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        let currentIndexPath = self.selectedIndexPath
        let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(currentIndexPath)!
        var hud:MBProgressHUD = MBProgressHUD(view: cell.contentView)
        cell.contentView.addSubview(hud)
        hud.show(true)
        
        if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo { var index = 0
            if item.multipage == "1" {index = item.imageurl.count + 1}
            let str = "pro_id=\(AppDelegate.app().pro_id)&filename=\(item.tbName)&page=\(index)&nsdata="
            var uploadData:NSMutableData = NSMutableData()
            uploadData.appendString(str)
            uploadData.appendData(UIImagePNGRepresentation(image))
            let url = "\(AppDelegate.app().ipUrl)" + config + uploadUrl
            NetworkRequest.AlamofireUploadImage(url, data: uploadData, progress: {
                (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                    hud.mode = MBProgressHUDMode.DeterminateHorizontalBar
                    let sub:Float = Float(totalBytesWritten) * 0.000977
                    let sup:Float = Float(totalBytesExpectedToWrite) * 0.000977
                    hud.progress = sub/sup  
                }, success: {
                    data in
                    println(data)
                    hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                    hud.mode = MBProgressHUDMode.CustomView
                    hud.hide(true, afterDelay: 1)
                    if let cell1 = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                        if !cell1.isMutable || item.imageurl.count == 0  {
                            //单张或者无图片数据时，更新略缩图
                            let url = AppDelegate.app().ipUrl + (data as! String) as String + "?\(arc4random() % 1000)"
                            //上传成功，更改显示UI及data source
                            cell1.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                            item.imageurl = NSMutableArray(object: data as! String)
                        }else {     //多张且有图片数据时，添加数据
                            item.imageurl.addObject(data as! String)
                        }
                    }
                },failed:{
                    if !hud.hidden {
                        hud.hide(true)
                    }
                },outTime:{
                    if !hud.hidden {
                        hud.hide(true)
                    }
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        self.tableView.reloadData()
        switch buttonIndex {
        case 1:             //从相册中选取
            if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                if !cell.isMutable {
                    self.openZLPhotoSinglePicker()
                }else {
                    self.openZLPhotoMutablePicker(9)
                }
                if cell.editing {
                    cell.editing = false
                }
            }
        case 2:             //打开照相机
            self.takePhoto()
        default:
            break
        }
    }
    
    func delete() {
        if var item = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
            let url = AppDelegate.app().ipUrl + config + "app/delete"
            NetworkRequest.AlamofirePostParameters(url, parameters: ["path":"\(JSON(item.imageurl))"], success: {
                (data) in
                if data == nil {println("empty return");return}
                if data as! String == "success" {
                    if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                        cell.imageV.image = UIImage(named: placeholderImageName)
                        item.imageurl = NSMutableArray()
                        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    }
                }
                }, failed: {
                    //失败处理
                },outTime:{})
        }
    }
    
    //MARK:-----ZLPhotoPickerViewController
    func openZLPhotoSinglePicker() {    //单张的上传与替换
        var pickerVC:ZLPhotoPickerViewController = ZLPhotoPickerViewController()
        pickerVC.status = PickerViewShowStatus.CameraRoll
        pickerVC.minCount = 1
        pickerVC.showPickerVc(self)
        pickerVC.callBack = { (assets) in
            if let array:NSArray = assets as? NSArray {
                var queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                var group:dispatch_group_t = dispatch_group_create()
                let currentIndexPath:NSIndexPath = self.selectedIndexPath
                let cellView = self.tableView.cellForRowAtIndexPath(currentIndexPath)
                var hud:MBProgressHUD = MBProgressHUD(view: cellView)
                cellView?.addSubview(hud);hud.show(true)
                if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                if let asset = array.firstObject as? ZLPhotoAssets {
                    let image = asset.originImage()
                    let imageData:NSData = UIImagePNGRepresentation(image)
                    dispatch_group_async(group, queue, {
                        let str = "pro_id=\(AppDelegate.app().pro_id)&filename=\(item.tbName)&page=0&nsdata="
                        let url = "\(AppDelegate.app().ipUrl)" + config + uploadUrl
                        var uploadData:NSMutableData = NSMutableData()
                        uploadData.appendString(str)
                        uploadData.appendData(imageData)
                        NetworkRequest.AlamofireUploadImage(url, data: uploadData, progress: {(_,written,totalExpectedToWrite) in
                            hud.mode = MBProgressHUDMode.DeterminateHorizontalBar
                            let sub:Float = Float(written) * 0.000977
                            let sup:Float = Float(totalExpectedToWrite) * 0.000977
                            hud.progress = sub/sup
                            }, success: {(data) in
                                if data == nil {println("empty return");return}
                                hud.hide(true)
                                item.imageurl.addObject(data as! String)
                                if let cell = self.tableView.cellForRowAtIndexPath(currentIndexPath) as? SingleTableViewCell {
                                    let url = AppDelegate.app().ipUrl + (item.imageurl.firstObject as! String) + "?\(arc4random() % 1000)"
                                    cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                }
                                self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                            }, failed: {},outTime:{})
                    })
                    }}
            }
        }
    }
    
    func openZLPhotoMutablePicker(minCount:NSInteger) {
        var pickerVC:ZLPhotoPickerViewController = ZLPhotoPickerViewController()
        pickerVC.status = PickerViewShowStatus.CameraRoll
        pickerVC.minCount = minCount
        pickerVC.showPickerVc(self)
        pickerVC.callBack = { (assets) in
            if let array:NSArray = assets as? NSArray {
                var queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                var group:dispatch_group_t = dispatch_group_create()
                let serialQueue:dispatch_queue_t = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL)
                let currentIndexPath:NSIndexPath = self.selectedIndexPath
                var total:Float = 0;var current:Float = 0
                let cellView = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath)
                var hud:MBProgressHUD = MBProgressHUD(view: cellView)
                cellView?.addSubview(hud)
                hud.show(true)
                if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                    var currentIndex = item.imageurl.count + 1;
                    var imageUrlArray:NSMutableArray = [];//NSMutableArray(array: item.imageurl)
                for ass in array {
                    if let asset = ass as? ZLPhotoAssets {
                        let image = asset.originImage()
                        let imageData:NSData = UIImagePNGRepresentation(image)
                        total += Float(imageData.length) * 0.000977
                        dispatch_async(serialQueue, {
                        //dispatch_group_async(group, queue, {
                            let str = "pro_id=\(AppDelegate.app().pro_id)&filename=\(item.tbName)&page=\(currentIndex++)&nsdata="
                            var uploadData:NSMutableData = NSMutableData()
                            uploadData.appendString(str);uploadData.appendData(imageData)
                            NetworkRequest.AlamofireUploadImage("\(AppDelegate.app().ipUrl)" + config + uploadUrl, data: uploadData, progress: {
                                (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                                hud.mode = MBProgressHUDMode.DeterminateHorizontalBar
                                hud.progress = current / total
                                current += (Float(bytesWritten) * 0.000977)
                                }, success: {
                                    data in
                                    println(data)
                                    if data == nil {println("empty return");return}
                                    imageUrlArray.addObject(data as! String)
                                    if imageUrlArray.count == array.count { //发送完成
                                        hud.hide(true)
                                        let array:NSArray = imageUrlArray.sortedArrayUsingComparator({
                                            (s1,s2) -> NSComparisonResult in
                                            if (s1 as! String) > (s2 as! String) {
                                                return NSComparisonResult.OrderedDescending
                                            }
                                            return NSComparisonResult.OrderedAscending
                                        })
                                        if item.imageurl.count == 0{
                                            if let cell = self.tableView.cellForRowAtIndexPath(currentIndexPath) as? SingleTableViewCell {
                                                let url = AppDelegate.app().ipUrl + (array.firstObject as! String) + "?\(arc4random() % 1000)"
                                                cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                            }
                                        }
                                        item.imageurl.addObjectsFromArray(array as [AnyObject])
                                        let nextIndex = NSIndexPath(forRow: currentIndexPath.row, inSection: currentIndexPath.section)
                                        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: currentIndexPath.row + 1, inSection: currentIndexPath.section)) as? PopMutableTableViewCell {
                                            cell.imageUrlArray = NSMutableArray(array: item.imageurl)
                                            cell.mutableCollection.reloadData()
                                        }
                                    }
                                    self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                                },failed:{
                                },outTime:{})
        
                            sleep(2)
                        })
                    }
                }
                }
                dispatch_group_notify(group, queue, {
                })
            }
        }
    }
    
    func setupPhotoBrowser() {
        var photoBrowser:ZLPhotoPickerBrowserViewController = ZLPhotoPickerBrowserViewController()
        photoBrowser.delegate = self
        photoBrowser.dataSource = self
        photoBrowser.editing = true
        photoBrowser.currentIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.presentViewController(photoBrowser, animated: false, completion: nil)
    }
    
    func numberOfSectionInPhotosInPickerBrowser(pickerBrowser: ZLPhotoPickerBrowserViewController!) -> Int {
        return 1
    }
    
    func photoBrowser(photoBrowser: ZLPhotoPickerBrowserViewController!, numberOfItemsInSection section: UInt) -> Int {
        let item = self.tableArray[self.selectedIndexPath.row] as! PicJsonItemInfo
        return item.imageurl.count
    }
    
    func photoBrowser(pickerBrowser: ZLPhotoPickerBrowserViewController!, photoAtIndexPath indexPath: NSIndexPath!) -> ZLPhotoPickerBrowserPhoto! {
        if self.hudProgress != nil {
            self.hudProgress.hide(true)
            self.hudProgress = nil
        }
        let item = self.tableArray[self.selectedIndexPath.row] as! PicJsonItemInfo
        let str: String = AppDelegate.app().ipUrl + (item.imageurl[indexPath.row] as! String) + "?\(arc4random() % 1000)"
        var ar:NSArray = NSArray(array: [NSString(string: str)])
        var photo:ZLPhotoPickerBrowserPhoto = ZLPhotoPickerBrowserPhoto(anyImageObjWith: str)
        if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
            photo.toView = cell.imageV
            photo.thumbImage = UIImage(named: placeholderImageName)//cell.imageV.image
        }
        return photo
    }
    
    func photoBrowser(photoBrowser: ZLPhotoPickerBrowserViewController!, removePhotoAtIndexPath indexPath: NSIndexPath!) {
        println(indexPath.row)
    }
    
    func photoBrowser(photoBrowser: ZLPhotoPickerBrowserViewController!, didRemoveLastOneSuccess success: ((String!) -> Void)!, failed: (() -> Void)!) {
        if let item = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
            let url = AppDelegate.app().ipUrl + config + "app/delete"
            let path:JSON = JSON(NSArray(object: item.imageurl.lastObject!))
            NetworkRequest.AlamofirePostParameters(url, parameters: ["path":"\(path)"], success: {
                (data) in
                success(data! as! String)
                item.imageurl.removeLastObject()
                if item.imageurl.count == 0 {
                    if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                        cell.imageV.image = UIImage(named: placeholderImageName)
                    }
                }
                self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                }, failed: {
                    //失败处理
                    failed()
                },outTime:{failed()})
        }
    }
    
    func photoBrowser(photoBrowser: ZLPhotoPickerBrowserViewController!, didUploadImage image: UIImage!, index: Int, progress: ((Float, Float) -> Void)!, success: ((String!) -> Void)!, failed: (() -> Void)!) {
        
        if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
            if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                let page = (cell.isMutable ? index + 1 : index)
                var queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                var group:dispatch_group_t = dispatch_group_create()
                let str = "pro_id=\(AppDelegate.app().pro_id)&filename=\(item.tbName)&page=\(page)&nsdata="
                let url = "\(AppDelegate.app().ipUrl)" + config + uploadUrl
                var uploadData:NSMutableData = NSMutableData()
                uploadData.appendString(str);uploadData.appendData(UIImagePNGRepresentation(image))
                dispatch_group_async(group, queue, {
                NetworkRequest.AlamofireUploadImage(url, data: uploadData, progress: { (_, written, total) -> Void in
                    progress(Float(written) * 0.000977,Float(total) * 0.000977)
                }, success: { (data) -> Void in
                    println(data)
                    if data == nil {println("empty return");return}
                    let str = AppDelegate.app().ipUrl + (data! as! String) + "?\(arc4random() % 1000)"
                    success(str)
                    
                    if index == 0 {
                        self.tableView.reloadRowsAtIndexPaths([self.selectedIndexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    }
                    
                }, failed: { () -> Void in
                    failed()
                }, outTime: { () -> Void in
                    
                })
                })
            }
        }
    }
    
    //MARK:--popMutablePhotoesDelegate
    func photoesDidBeChanged(array: NSArray, cell: UITableViewCell) {
        let index = self.tableView.indexPathForCell(cell)
        if let item = self.tableArray[index!.row - 1] as? PicJsonItemInfo {
            item.imageurl = NSMutableArray(array: array)
        }
    }
    
    //MARK:--UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        println(buttonIndex)
        if buttonIndex == 1 {
            switch alertView.tag {
            case deleteTag:
                self.delete()
            case replaceTag:
                self.delete()
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                sheetAction.showInView(self.view)
            default:
                break
            }
        }
    }
}
