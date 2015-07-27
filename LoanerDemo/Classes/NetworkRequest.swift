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
        let request = Alamofire.request(.GET, url)
        request.responseJSON() {
            (_,_,data,error) in
            if error != nil {
                
            }
             closure(data!)
        }
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
