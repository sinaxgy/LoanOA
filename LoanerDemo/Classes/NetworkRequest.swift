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
    
    static func defaultRequest() {
    
    }
    
    static func AlamofireGetJSON(url:String,closure:(AnyObject)->Void) {
        var request: Alamofire.Request!
        request = Alamofire.request(.GET, url)
        request.responseJSON() {
            (_,_,data,error) in
            request = nil
            if error != nil {
                let alert:UIAlertView = UIAlertView(title: "错误", message: "加载数据失败", delegate: nil, cancelButtonTitle: "确定")
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
    
//    static func POSTResponseString(URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil) -> (NSURLRequest, NSHTTPURLResponse?, String?, NSError?) -> Void {
//        var request: Alamofire.Request?
//        request = Alamofire.request(.POST, URLString, parameters: parameters)
//        
//        request?.responseString(){ (_, _, data, error) in
//            return data
//        }
//    }
}
