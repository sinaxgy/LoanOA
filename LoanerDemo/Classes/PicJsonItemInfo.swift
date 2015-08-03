//
//  PicJsonItemInfo.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/21.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class PicJsonItemInfo: NSObject {
    
    var tbName:String = ""
    var pic_explain:String = ""
    var multipage:String = ""
    var imageurl:NSMutableArray = []
    var date:String = ""
    
    init(tbName:String , json:JSON) {
        self.tbName = tbName
        let array:NSArray = (json.object as! NSDictionary).allKeys.map({"\($0)"})
        for key in  array {
            switch ("\(key)") {
            case "pic_explain":
                self.pic_explain = json.dictionary![key as! String]!.description
            case "multipage":
                self.multipage = json.dictionary![key as! String]!.description
            case "date":
                self.date = json.dictionary![key as! String]!.description
            case "imageurl":
                if let value = json.dictionary?["imageurl"]! {
                    let array = value.object as! NSArray
                    self.imageurl.addObjectsFromArray(array as [AnyObject])
                }
            default:
                break
            }
        }
    }
}
