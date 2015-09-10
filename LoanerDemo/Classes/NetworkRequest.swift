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
    
    static func AlamofireGetString(url:String,success:(AnyObject?)->Void,failed:()->Void,outTime:()->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.GET, url)
        request.responseString() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                failed()
                return
            }
            success(data)
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
        request.responseJSON() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                failed()
                return
            }
             success(data)
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
        request.responseJSON() {
            (_,_,data,error) in
            request = nil
            if (error != nil && data == nil) {
                failed()
                return
            }
            success(JSON(data!))
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
        request.responseString() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                failed()
                return
            }
            success(data)
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
                return
            }
            success(data)
        }
    }
}
