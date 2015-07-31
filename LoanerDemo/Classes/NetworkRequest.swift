//
//  Network.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/6.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit
import Alamofire

class NetworkRequest: NSObject {
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    static func AlamofireGetJSON(url:String,closure:(AnyObject)->Void) {
        var request: Alamofire.Request!
        println(url)
        request = Alamofire.request(.GET, url)
        request.responseJSON() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                let alert:UIAlertView = UIAlertView(title: "错误", message: "网络请求失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
             closure(data!)
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                request?.cancel()
                request = nil
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        })
    }
    
    static func AlamofirePostParameters(url:String,parameters:[String:AnyObject]?,closure:(AnyObject)->Void,failed:()->Void) {
        var request: Alamofire.Request!
        println(url)
        request = Alamofire.request(.POST, url, parameters: parameters)
        request.responseString() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                let alert:UIAlertView = UIAlertView(title: "错误", message: "网络请求失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                failed()
            }
            closure(data!)
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                request?.cancel()
                request = nil
                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
            }
        })
    }
    
    static func AlamofireUploadImage(url:String,data:NSData,progress:(Int64,Int64,Int64)->Void,closure:(AnyObject)->Void,failed:()->Void) {
        var upload:Alamofire.Request!
        upload = Alamofire.upload(.POST, url, data)
        upload.progress(closure: {
            bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
            progress(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite)
        })
        upload.responseString() {
            (_,_,data,error) in
            upload = nil
            if error != nil {
                println("error>>>>>>>>>>>>>>>>>>>")
                println(error)
                failed()
                let alert:UIAlertView = UIAlertView(title: "错误", message: "网络请求失败", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return
            }
            closure(data!)
        }
//        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
//        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
//            if upload != nil {
//                upload?.cancel()
//                upload = nil
//                let alert:UIAlertView = UIAlertView(title: "错误", message: "请求超时，请检查网络配置", delegate: nil, cancelButtonTitle: "确定")
//                alert.show()
//            }
//        })
    }
}
