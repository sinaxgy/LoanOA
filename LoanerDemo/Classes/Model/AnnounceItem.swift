//
//  AnnounceItem.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/9.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class AnnounceItem: NSObject {
    
    var title:String = ""
    var isReaded:Bool = false
    var date:String = ""
    var url:String = ""
    
    init(json:JSON){
        for (key,value) in json {
            switch key {
            case "title":
                self.title = value.description
            case "date":
                self.date = value.description
            case "isReaded":
                self.isReaded = NSString(string: value.description).boolValue
            case "url":
                self.url = AppDelegate.app().ipUrl + config + value.description
            default:
                break
            }
        }
    }
   
}
