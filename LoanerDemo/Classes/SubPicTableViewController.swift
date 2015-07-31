//
//  SubPicTableViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/27.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import AVFoundation


extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

class SubPicTableViewController: UITableViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,QBImagePickerControllerDelegate,ZLPhotoPickerBrowserViewControllerDelegate,ZLPhotoPickerBrowserViewControllerDataSource,MutableTableViewDelegate{
    
    var subURL:String = ""
    var tableArray:NSMutableArray = []
    let kMutableCell = "mutableCell"
    let kSingleCell = "singleCell"
    let kMutablePhotoesCell = "mutablePhotoesCell"
    var pro_id = ""
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
        NetworkRequest.AlamofireGetJSON(self.subURL, closure: {
            (data) in
            let js:JSON = JSON(data)
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
            println(self.tableArray.count)
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
            return 130
        }
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.tableArray[indexPath.row].isKindOfClass(PicJsonItemInfo) {
            let item:PicJsonItemInfo = self.tableArray[indexPath.row] as! PicJsonItemInfo
            if item.multipage == "0" {
                if var cell:SingleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kSingleCell, forIndexPath: indexPath) as? SingleTableViewCell {
                    cell.titleLabel?.text = item.pic_explain
                    var url = ""
                    if item.imageurl.count == 1 {
                        url = "\(AppDelegate.app().ipUrl)" + (item.imageurl.firstObject as! String)
                    }
                    cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                    cell.subTextLabel?.text = "2015/07/27"
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    
                    var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
                    cell.addGestureRecognizer(longPress)
                    
                    return cell
                }
            }else if item.multipage == "1" {
                if var cell:MutableTableViewCell = tableView.dequeueReusableCellWithIdentifier(kMutableCell, forIndexPath: indexPath) as? MutableTableViewCell {
                    cell.setupShowButtonState()
                    cell.titleLabel.text = item.pic_explain
                    var url = ""
                    if item.imageurl.count > 0 {
                        url = "\(AppDelegate.app().ipUrl)" + (item.imageurl.firstObject as! String)
                    }
                    cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                    cell.subTextLabel.text = "2015/05/27"
                    cell.delagate = self
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    return cell
                }
            }
        }else if self.tableArray[indexPath.row].isKindOfClass(NSArray) {
            if let cell = tableView.dequeueReusableCellWithIdentifier(kMutablePhotoesCell, forIndexPath: indexPath) as? PopMutableTableViewCell {
                cell.setupMutableCollection()
                cell.imageUrlArray = self.tableArray[indexPath.row] as! NSArray
                return cell
            }
        }

        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        let item:PicJsonItemInfo = self.tableArray[indexPath.row] as! PicJsonItemInfo
        if item.imageurl.count > 0 {
            self.hudProgress = MBProgressHUD(view: self.view)
            self.navigationController?.view.addSubview(self.hudProgress)
            self.hudProgress.show(true)
            self.setupPhotoBrowser()
//            let loginStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let browseVC:BrowseViewController = BrowseViewController()
//            browseVC.imageArray = item.imageurl
//            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SingleTableViewCell {
//                browseVC.image = cell.imageV.image!
//            }
//            self.navigationController?.presentViewController(browseVC, animated: true, completion: nil)
        }
        if item.imageurl.count == 0{
            var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
            sheetAction.tag = 201
            sheetAction.showInView(self.view)
        }
    }
    
    //MARK:-----MutableTableViewDelegate
    func mutablePhotoesDidBeshowedMore(cell: MutableTableViewCell, isShow: Bool) {
        let indexPath:NSIndexPath = self.tableView.indexPathForCell(cell)!
        let insertPath:NSIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        println("show");println(indexPath.row)
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

    func openPictureLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            var picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            let alert:UIAlertView = UIAlertView(title: "错误", message: "相册不可用", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func openFlashLight(){
        let device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        if device.torchMode == AVCaptureTorchMode.Off{
            var session:AVCaptureSession = AVCaptureSession()
            let input:AVCaptureDeviceInput = AVCaptureDeviceInput(device: device, error: nil)
            session.addInput(input)
            var output:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            session.addOutput(output)
            session.beginConfiguration()
            device.lockForConfiguration(nil)
            device.torchMode = AVCaptureTorchMode.On
            device.unlockForConfiguration()
            session.commitConfiguration()
            session.startRunning()
        }
    }
    
    //UIImagePickerControllerDelegate拍摄完执行
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)

        var image:UIImage = info[UIImagePickerControllerOriginalImage]! as! UIImage
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        if let cell:SingleTableViewCell = (self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell) {
            var hud:MBProgressHUD = MBProgressHUD(view: cell.contentView)
            cell.contentView.addSubview(hud)
            hud.show(true)
            
            if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                let str = "pro_id=\(self.pro_id)&filename=\(item.tbName)&page=0&nsdata="
                var uploadData:NSMutableData = NSMutableData()
                uploadData.appendString(str)
                uploadData.appendData(UIImagePNGRepresentation(image))
                NetworkRequest.AlamofireUploadImage("\(AppDelegate.app().ipUrl)web/index.php/app/upload", data: uploadData, progress: {
                    (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                        hud.mode = MBProgressHUDMode.Determinate
                        let sub:Float = Float(totalBytesWritten) * 0.000977
                        let sup:Float = Float(totalBytesExpectedToWrite) * 0.000977
                        hud.progress = sub/sup
                        println("totalBytesWritten:\(totalBytesWritten/1024)")
                        println("totalBytesExpectedToWrite:\(totalBytesExpectedToWrite/1024)")
                    }, closure: {
                        data in
                        hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                        hud.mode = MBProgressHUDMode.CustomView
                        hud.hide(true, afterDelay: 1)
                        println(data)
                        if let cell1 = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                            let url = AppDelegate.app().ipUrl + (data as! String) as String + "?\(arc4random() % 10)"
                            //上传成功，更改显示UI及data source
                            cell1.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                            if item.imageurl.count == 0 {
                                item.imageurl = NSMutableArray(object: data as! String)
                            }
                        }
                    },failed:{
                        if !hud.hidden {
                            hud.hide(true)
                        }
                })
            }
        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:----UIGestureRecognizer
    func handleLongPress(recognizer:UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            if let cell:SingleTableViewCell = recognizer.view as? SingleTableViewCell {
                let index = self.tableView.indexPathForCell(cell)!
                println(index.row)
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "删除", otherButtonTitles: "替换")
                self.selectedIndexPath = index
                sheetAction.showInView(self.view)
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet.tag != 201 {
            switch buttonIndex {
            case 0:     //删除
                if var item = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                    let url = AppDelegate.app().ipUrl + config + "app/delete"
                    NetworkRequest.AlamofirePostParameters(url, parameters: ["path":"\(item.imageurl.firstObject as! String)"], closure: {
                        (data) in
                        if data as! String == "success" {
                            if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                                cell.imageV.image = UIImage(named: placeholderImageName)
                                println(item.imageurl.count)
                                item.imageurl = NSMutableArray()
                                let ite = self.tableArray[self.selectedIndexPath.row] as! PicJsonItemInfo
                                println(ite.imageurl.count)
                            }
                        }
                        }, failed: {
                            //失败处理
                    })
                }
            case 1:         //取消
                break
            case 2:         //替换
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                sheetAction.tag = 201
                sheetAction.showInView(self.view)
            default:
                break
            }
        }else {
            switch buttonIndex {
            case 1:             //从相册中选取
                println("1")
                if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                    //self.openPictureLibrary()
                    self.openZLPhotoMutablePicker(1)
                }else {
                    //self.openQBImagePicker()
                    self.openZLPhotoMutablePicker(9)
                }
                
            case 2:             //打开照相机
                println("2")
                self.takePhoto()
            default:
                break
            }
        }
    }
    
    //MARK:-----ZLPhotoPickerViewController
    func openZLPhotoMutablePicker(minCount:NSInteger) {
        var pickerVC:ZLPhotoPickerViewController = ZLPhotoPickerViewController()
        pickerVC.status = PickerViewShowStatus.CameraRoll
        pickerVC.minCount = minCount
        pickerVC.showPickerVc(self)
        pickerVC.callBack = { (assets) in
            if let array:NSArray = assets as? NSArray {
                var queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                var group:dispatch_group_t = dispatch_group_create()
                var imageUrlArray:NSMutableArray = []
                var currentIndex = 0;var total:Float = 0;var current:Float = 0
                let cellView = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath)
                var hud:MBProgressHUD = MBProgressHUD(view: cellView)
                cellView?.addSubview(hud)
                hud.show(true)
                if minCount != 1 {currentIndex++}       //是否多选
                for ass in array {
                    if let asset = ass as? ZLPhotoAssets {
                        let image = asset.originImage()
                        let imageData:NSData = UIImagePNGRepresentation(image)
                        total += Float(imageData.length) * 0.000977
                        println(">>>>>>>>>>>>>>>>")
                        println(imageData.length / 1024)
                        dispatch_group_async(group, queue, {
                            if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                                let str = "pro_id=\(self.pro_id)&filename=\(item.tbName)&page=\(currentIndex++)&nsdata="
                                println(str)
                                var uploadData:NSMutableData = NSMutableData()
                                uploadData.appendString(str)
                                uploadData.appendData(imageData)
                                NetworkRequest.AlamofireUploadImage("\(AppDelegate.app().ipUrl)" + config + uploadUrl, data: uploadData, progress: {
                                    (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                                    hud.mode = MBProgressHUDMode.DeterminateHorizontalBar
                                    hud.progress = current / total
                                    current += (Float(bytesWritten) * 0.000977)
                                    println(current)
                                    println(total)
                                    println("totalBytesWritten:\(totalBytesWritten/1024)")
                                    println("totalBytesExpectedToWrite:\(totalBytesExpectedToWrite/1024)")
                                    }, closure: {
                                        data in
                                        println("completion>>>>>>>>>>>>>>>>>>>")
                                        println(data)
                                        imageUrlArray.addObject(data as! String)
                                        if imageUrlArray.count == array.count { //发送完成
                                            hud.hide(true)
                                            if minCount != 1 {
                                                println(imageUrlArray)
                                                let array:NSArray = imageUrlArray.sortedArrayUsingComparator({
                                                    (s1,s2) -> NSComparisonResult in
                                                    if (s1 as! String) > (s2 as! String) {
                                                        return NSComparisonResult.OrderedDescending
                                                    }
                                                    return NSComparisonResult.OrderedAscending
                                                })
                                                println(array)
                                                item.imageurl = NSMutableArray(array: array)
                                                
                                                if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? MutableTableViewCell {
                                                    let url = AppDelegate.app().ipUrl + (item.imageurl.firstObject as! String)
                                                    cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                                }
                                                
                                            }else {
                                                item.imageurl = NSMutableArray(array: imageUrlArray)
                                                if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                                                    let url = AppDelegate.app().ipUrl + (item.imageurl.firstObject as! String)
                                                    cell.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                                }
                                            }
                                        }
                                    },failed:{
                                })
                            }
                        })
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
        let str: String = AppDelegate.app().ipUrl + (item.imageurl[indexPath.row] as! String)
        println(indexPath.row)
        println(str)
        var photo:ZLPhotoPickerBrowserPhoto = ZLPhotoPickerBrowserPhoto(anyImageObjWith: str)
        if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
            photo.toView = cell.imageV
            //photo.thumbImage = cell.imageV.image
        }else if let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? MutableTableViewCell {
            photo.toView = cell.imageV
            //photo.thumbImage = cell.imageV.image
        }
        return photo
    }
    
    
    //MARK:-----QBImagePickerControllerDelegate
    func openQBImagePicker() {
        var qbPicker = QBImagePickerController()
        qbPicker.delegate = self
        qbPicker.mediaType = QBImagePickerMediaType.Image
        qbPicker.allowsMultipleSelection = true
        qbPicker.showsNumberOfSelectedAssets = true
        qbPicker.minimumNumberOfSelection = 1
        qbPicker.maximumNumberOfSelection = 10
        self.presentViewController(qbPicker, animated: true, completion: nil)
    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        println(assets.count)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        var currentIndex = 0
        for asset in assets {
            let manager = PHImageManager.defaultManager()
            var imageUrlArray:NSMutableArray = []
            manager.requestImageDataForAsset(asset as! PHAsset, options: nil, resultHandler: {
                (data,string,imageOrientation,ip) in
            })
            manager.requestImageForAsset(asset as! PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFit, options: nil, resultHandler: {
                (image,info) in
                currentIndex++
                let imageData:NSData = UIImagePNGRepresentation(image)
                println(imageData.length)
                if var item:PicJsonItemInfo = self.tableArray[self.selectedIndexPath.row] as? PicJsonItemInfo {
                    let str = "pro_id=\(self.pro_id)&filename=\(item.tbName)&page=\(currentIndex)&nsdata="
                    println(str)
                    var uploadData:NSMutableData = NSMutableData()
                    uploadData.appendString(str)
                    uploadData.appendData(imageData)
                    NetworkRequest.AlamofireUploadImage("\(AppDelegate.app().ipUrl)web/index.php/app/upload", data: uploadData, progress: {
                        (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                        let sub:Float = Float(totalBytesWritten) * 0.000977
                        let sup:Float = Float(totalBytesExpectedToWrite) * 0.000977
                        println("totalBytesWritten:\(totalBytesWritten/1024)")
                        println("totalBytesExpectedToWrite:\(totalBytesExpectedToWrite/1024)")
                        }, closure: {
                            data in
                            println(data)
                            println(currentIndex)
                            imageUrlArray.addObject(data as! String)
                            if currentIndex == 0 {
                                if let cell1 = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? MutableTableViewCell {
                                    let url = AppDelegate.app().ipUrl + (data as! String) as String + "?\(arc4random() % 10)"
                                    //上传成功，更改显示UI及data source
                                    cell1.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                }
                            }
                            
                            if currentIndex == assets.count {
                                item.imageurl = NSMutableArray(array: imageUrlArray)
                                if let cell1 = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath) as? SingleTableViewCell {
                                    let url = AppDelegate.app().ipUrl + (data as! String) as String + "?\(arc4random() % 10)"
                                    //上传成功，更改显示UI及data source
                                    cell1.imageV.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
                                }
                            }
                        },failed:{
                    })
                }
            })
        }
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: {
            println("dismissViewControllerAnimated!!!")
        })
    }
}
