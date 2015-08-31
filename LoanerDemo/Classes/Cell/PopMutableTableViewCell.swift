//
//  PopMutableTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/31.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol popMutablePhotoesDelegate {
    func photoesDidBeChanged(array:NSArray,cell:UITableViewCell)
}

class PopMutableTableViewCell: UITableViewCell ,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ZLPhotoPickerBrowserViewControllerDelegate,ZLPhotoPickerBrowserViewControllerDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var mutableCollection: UICollectionView!
    let mColCell = "mutableCollectionCell"
    var imageUrlArray:NSMutableArray = [];var editable = false
    var viewController:UIViewController = UIViewController()
    var selectedIndexPath:NSIndexPath = NSIndexPath()
    var tbName = "";var pro_id = "";var delegate:popMutablePhotoesDelegate!
    
    func setupMutableCollection(viewController:UIViewController) {
        self.viewController = viewController
        self.mutableCollection.registerNib(UINib(nibName: "SubPopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: mColCell)
        self.mutableCollection.allowsMultipleSelection = true
        self.mutableCollection.dataSource = self
        self.mutableCollection.delegate = self
        self.mutableCollection.backgroundColor = UIColor.whiteColor()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageUrlArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.mutableCollection.dequeueReusableCellWithReuseIdentifier(self.mColCell, forIndexPath: indexPath) as? SubPopCollectionViewCell {
            let url = AppDelegate.app().ipUrl + (self.imageUrlArray[indexPath.row] as! String) + "?\(arc4random() % 100)"
            cell.imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
            
            var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
            cell.addGestureRecognizer(longPress)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(80, 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.setupPhotoBrowser(indexPath)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handleLongPress(recognizer:UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began && self.editable {
            if let index = self.mutableCollection.indexPathForCell((recognizer.view as? SubPopCollectionViewCell)!) {
                self.selectedIndexPath = index
                if index.row != self.imageUrlArray.count - 1 {      //最后一个
                    var actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "替换")
                    actionSheet.tag = 218
                    actionSheet.showInView(self.viewController.view)
                }else {
                    var actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "删除", otherButtonTitles: "替换")
                    actionSheet.tag = 217
                    actionSheet.showInView(self.viewController.view)
                }
            }
        }
    }
    
    //MARK:----UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch actionSheet.tag {
        case 217:
            switch buttonIndex {
            case 0:         //删除
                let url = AppDelegate.app().ipUrl + config + "app/delete"
                NetworkRequest.AlamofirePostParameters(url, parameters: ["path":"\(JSON([self.imageUrlArray[self.selectedIndexPath.row]]))"], success: {(data) in
                    if data as! String == "success" {
                        self.imageUrlArray.removeObjectAtIndex(self.selectedIndexPath.row)
                        self.mutableCollection.reloadData()
                        self.delegate.photoesDidBeChanged(self.imageUrlArray,cell: self)
                    }
                    }, failed: {}, outTime: {})
            case 2:         //替换
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                sheetAction.tag = 219
                sheetAction.showInView(self.viewController.view)
            default:
                break
            }

        case 218:
            switch buttonIndex {
            case 0:         //替换
                var sheetAction:UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册中选取","打开照相机")
                sheetAction.tag = 219
                sheetAction.showInView(self.viewController.view)
            default:
                break
            }

//        case 219:
//            switch buttonIndex {
//            case 1:             //从相册中选取
//                self.openZLPhotoSinglePicker()
//            case 2:             //打开照相机
//                self.takePhoto()
//                break
//            default:
//                break
//            }

        default:
            break
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if actionSheet.tag == 219 {
            switch buttonIndex {
            case 1:             //从相册中选取
                self.openZLPhotoSinglePicker()
            case 2:             //打开照相机
                self.takePhoto()
                break
            default:
                break
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
            self.viewController.presentViewController(picker, animated: true, completion: nil)             //yes?
        }else{
            let alert:UIAlertView = UIAlertView(title: "错误", message: "摄像头不可用", delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
        
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
        
        if let cell:SubPopCollectionViewCell = (self.mutableCollection.cellForItemAtIndexPath(self.selectedIndexPath) as? SubPopCollectionViewCell) {
            var hud:MBProgressHUD = MBProgressHUD(view: cell.contentView)
            cell.contentView.addSubview(hud)
            hud.show(true)
            let str = "pro_id=\(self.pro_id)&filename=\(self.tbName)&page=\(self.selectedIndexPath.row + 1)&nsdata="
            var uploadData:NSMutableData = NSMutableData()
            uploadData.appendString(str)
            uploadData.appendData(UIImagePNGRepresentation(image))
            NetworkRequest.AlamofireUploadImage("\(AppDelegate.app().ipUrl)web/index.php/app/upload", data: uploadData, progress: {
                (bytesWritten,totalBytesWritten,totalBytesExpectedToWrite) in
                hud.mode = MBProgressHUDMode.Determinate
                let sub:Float = Float(totalBytesWritten) * 0.000977
                let sup:Float = Float(totalBytesExpectedToWrite) * 0.000977
                hud.progress = sub/sup
                }, success: {
                    data in
                    if data == nil {println("empty return");return}
                    hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark"))
                    hud.mode = MBProgressHUDMode.CustomView
                    hud.hide(true, afterDelay: 1)
                    //self.imageUrlArray.replaceObjectAtIndex(self.selectedIndexPath.row, withObject: data as! String)
                    self.delegate.photoesDidBeChanged(self.imageUrlArray,cell: self)
                    self.mutableCollection.reloadData()
                },failed:{
                    if !hud.hidden {
                        hud.hide(true)
                    }
                },outTime:{})
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: --
    func setupPhotoBrowser(indexPath:NSIndexPath) {
        var photoBrowser:ZLPhotoPickerBrowserViewController = ZLPhotoPickerBrowserViewController()
        photoBrowser.delegate = self
        photoBrowser.dataSource = self
        photoBrowser.editing = true
        photoBrowser.currentIndexPath = indexPath
        self.viewController.presentViewController(photoBrowser, animated: false, completion: nil)
    }
    func numberOfSectionInPhotosInPickerBrowser(pickerBrowser: ZLPhotoPickerBrowserViewController!) -> Int {
        return 1
    }
    
    func photoBrowser(photoBrowser: ZLPhotoPickerBrowserViewController!, numberOfItemsInSection section: UInt) -> Int {
        return self.imageUrlArray.count
    }
    
    func photoBrowser(pickerBrowser: ZLPhotoPickerBrowserViewController!, photoAtIndexPath indexPath: NSIndexPath!) -> ZLPhotoPickerBrowserPhoto! {
        let str: String = AppDelegate.app().ipUrl  + LoanerHelper.OriginalImageURLStrWithSmallURLStr(self.imageUrlArray[indexPath.row] as! String) + "?\(arc4random() % 100)"
        var photo:ZLPhotoPickerBrowserPhoto = ZLPhotoPickerBrowserPhoto(anyImageObjWith: str)
        if let cell = self.mutableCollection.cellForItemAtIndexPath(indexPath) as? SubPopCollectionViewCell {
            photo.toView = cell.imageView
            photo.thumbImage = cell.imageView.image
        }
        return photo
    }
    
    //MARK:-----ZLPhotoPickerViewController
    func openZLPhotoSinglePicker() {    //单张的上传与替换
        var pickerVC:ZLPhotoPickerViewController = ZLPhotoPickerViewController()
        pickerVC.status = PickerViewShowStatus.CameraRoll
        pickerVC.minCount = 1
        pickerVC.showPickerVc(self.viewController)
        pickerVC.callBack = { (assets) in
            if let array:NSArray = assets as? NSArray {
                var queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                var group:dispatch_group_t = dispatch_group_create()
                let currentIndexPath:NSIndexPath = self.selectedIndexPath
                let cellView = self.mutableCollection.cellForItemAtIndexPath(currentIndexPath)
                var hud:MBProgressHUD = MBProgressHUD(view: cellView)
                cellView?.addSubview(hud);hud.show(true)
                if let asset = array.firstObject as? ZLPhotoAssets {
                    let image = asset.originImage()
                    let imageData:NSData = UIImagePNGRepresentation(image)
                    dispatch_group_async(group, queue, {
                        let str = "pro_id=\(self.pro_id)&filename=\(self.tbName)&page=\(currentIndexPath.row + 1)&nsdata="
                        let url = "\(AppDelegate.app().ipUrl)" + config + uploadUrl
                        var uploadData:NSMutableData = NSMutableData()
                        uploadData.appendString(str)
                        uploadData.appendData(imageData)
                        NetworkRequest.AlamofireUploadImage(url, data: uploadData, progress: {(_,written,totalExpectedToWrite) in
                            hud.mode = MBProgressHUDMode.Determinate
                            let sub:Float = Float(written) * 0.000977
                            let sup:Float = Float(totalExpectedToWrite) * 0.000977
                            hud.progress = sub/sup
                            }, success: {(data) in
                                if data == nil {println("empty return");hud.hide(true);return}
                                hud.hide(true)
                                //self.imageUrlArray.replaceObjectAtIndex(currentIndexPath.row, withObject: data as! String)
                                self.delegate.photoesDidBeChanged(self.imageUrlArray,cell: self)
                                self.mutableCollection.reloadData()
                            }, failed: {},outTime:{})
                    })
                }}
        }
    }
}
