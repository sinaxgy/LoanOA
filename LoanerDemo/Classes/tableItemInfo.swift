//
//  tableItemInfo.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class tableItemInfo: NSObject {
    var title:NSString = ""
    var explain:NSString = ""
    var type:NSString = ""
    var value:NSString = ""
    var options:NSArray = []
    
    init(title:String,forjson json:JSON) {
        self.title = title
        //var key:String = "" as String
        let array:NSArray = (json.object as! NSDictionary).allKeys.map({"\($0)"})
        for key in  array {
            switch ("\(key)") {
            case "explain":
                self.explain = json.dictionary![key as! String]!.description
            case "type":
                self.type = json.dictionary![key as! String]!.description
            case "value":
                self.value = json.dictionary![key as! String]!.description
            case "options":
                let opt = json.dictionary?["options"]!
                var nextJson: JSON = JSON(opt!.object)
                switch nextJson.type {
                case .String:
                    let str:NSString = nextJson.description
                    if str != ""{
                        self.options = str.componentsSeparatedByString(",")
                    }
                default:
                    return
                }
                //self.explain = json.dictionary![key as! String]!.description
            default:
                break
            }
        }
//        self.explain = json.dictionary!["explain"]!.description
//        self.type = json.dictionary!["type"]!.description
//        self.value = json.dictionary!["value"]!.description
//        let opt = json.dictionary?["options"]!
//        var nextJson: JSON = JSON(opt!.object)
//        switch nextJson.type {
//        case .String:
//            let str:NSString = nextJson.description
//            if str != ""{
//                self.options = str.componentsSeparatedByString(",")
//            }
//        default:
//            return
//        }
    }
    
    init(value:String,twojson:JSON) {
        self.title = value
        self.explain = twojson.dictionary!["explain"]!.description
        self.value = twojson.dictionary!["value"]!.description
//        for key in twojson.dictionary!.keys.array {
//        }
        
    }
    
    init(value:String,key:String) {
        self.title = key
        self.explain = value
        self.type = "text"
    }
}
