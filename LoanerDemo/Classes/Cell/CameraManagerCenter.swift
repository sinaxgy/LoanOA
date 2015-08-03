//
//  CameraManageCenter.swift
//  CameraDemo
//
//  Created by 徐成 on 15/6/4.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraManagerDelegate:NSObjectProtocol {
    
    func cameraManagerImage(image: UIImage)
    func cameraManagerDidCancel()
}

class CameraManageCenter: NSObject ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var avSession:AVCaptureSession!
    var cameraDelegate:CameraManagerDelegate!
    let middleSize = CGSizeMake(50, 50)
    
    func takePhoto(viewCtrl:UIViewController){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            var picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            //picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            viewCtrl.presentViewController(picker, animated: true, completion: nil)             //yes?
        }else{
            let alert:UIAlertView = UIAlertView(title: "Error", message: "摄像头不可用", delegate: nil, cancelButtonTitle: "Exit")
            alert.show()
        }
    }
    
    func openPictureLibrary(viewCtrl:UIViewController){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            var picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            //picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            viewCtrl.presentViewController(picker, animated: true, completion: nil)
        }else{
            let alert:UIAlertView = UIAlertView(title: "Error", message: "照片库不可用", delegate: nil, cancelButtonTitle: "Fail")
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
    
    func shrinkImageSizeToMiddle(originalImage:UIImage) -> UIImage {
        UIGraphicsBeginImageContext(self.middleSize)
        originalImage.drawInRect(CGRectMake(0, 0, self.middleSize.width, self.middleSize.height))
        var handledImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return handledImage
    }
    
    //UIImagePickerControllerDelegate拍摄完执行
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image:UIImage = info[UIImagePickerControllerOriginalImage]! as! UIImage
        if picker.sourceType == UIImagePickerControllerSourceType.Camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        println("camera!!!")
        self.cameraDelegate.cameraManagerImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.cameraDelegate.cameraManagerDidCancel()
    }
}