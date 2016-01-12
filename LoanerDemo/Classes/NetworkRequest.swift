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
    
    static func AlamofireGetString(url:String,success:(AnyObject?)->Void,failed:()->Void,outTime:()->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.GET, url)
        request.responseString { (response) -> Void in
            request = nil
            if response.result.error != nil {
                failed()
                return
            }
            success(response.result.value)
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                outTime()
            }
        })
    }
    
    static func AlamofireGetJSON(url:String,success:(AnyObject?)->Void,failed:()->Void,outTime:()->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.GET, url)
        request.responseJSON { (xResponse) -> Void in
            request = nil
            if xResponse.result.error != nil {
                failed()
                return
            }
            success(xResponse.result.value)
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                outTime()
            }
        })
    }
    
    static func AlamofirePostParametersResponseJSON(url:String,parameters:[String:AnyObject]?,success:(JSON)->Void,failed:()->Void,outTime:()->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.POST, url, parameters: parameters,encoding: .URL)
        request.responseJSON { (xResponse) -> Void in
            request = nil
            if xResponse.result.error != nil || xResponse.result.value == nil {
                failed()
                return
            }
            success(JSON(xResponse.result.value!))
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                outTime()
            }
        })
    }
    
    static func AlamofirePostParameters(url:String,parameters:[String:AnyObject]?,success:(AnyObject?)->Void,failed:()->Void,outTime:()->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.POST, url, parameters: parameters)
        request.responseString { (response) -> Void in
            request = nil
            if response.result.error != nil {
                failed()
                return
            }
            success(response.result.value)
        }
        let gcdTimer:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * NSEC_PER_SEC))
        dispatch_after(gcdTimer, dispatch_get_main_queue(), {
            if request != nil {
                outTime()
            }
        })
    }
    
    static func AlamofireUploadImage(url:String,data:NSData,progress:(Int64,Int64,Int64)->Void,success:(AnyObject?)->Void,failed:()->Void,outTime:()->Void) {
        var upload:Alamofire.Request!
        upload = Alamofire.upload(.POST, url, data: data)
        upload.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
            progress(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite)
        }
        
        upload.responseString { (response) -> Void in
            upload = nil
            if response.result.error != nil {
                failed()
                return
            }
            success(response.result.value)
        }
    }
}
