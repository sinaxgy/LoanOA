//
//  LoanerHelper.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/31.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

let predicateType = [""]

class LoanerHelper: NSObject {
    
    static func sortArrayAscending(array:NSArray) -> NSArray{
        let array:NSArray = array.sortedArrayUsingComparator({
            (s1,s2) -> NSComparisonResult in
            if (s1 as! String) > (s2 as! String) {
            return NSComparisonResult.OrderedDescending
            }
            return NSComparisonResult.OrderedAscending
        })
        return array
    }
    
    static func OriginalImageURLStrWithSmallURLStr(small:NSString)->String {
        return small.stringByReplacingCharactersInRange(NSMakeRange(small.length - 10, 10), withString: ".jpg")
    }
    
    static func OriginalUrlArraywith(imageUrl:NSMutableArray) -> NSMutableArray {
        var original:NSMutableArray = []
        if imageUrl.count <= 9 {
            for item in imageUrl {
                original.addObject(AppDelegate.app().ipUrl + LoanerHelper.OriginalImageURLStrWithSmallURLStr(item as! NSString) + "?\(arc4random() % 100)")
            }
        }else {
            
        }
        return original
    }
    
    static func isvaildIP(targetString:String) -> Bool {
        let predicateString = "^\\d{1,3}(.\\d{1,3}){3}(:\\d{1,4})?"
        var predicate:NSPredicate = NSPredicate(format:"SELF MATCHES %@", predicateString)
        return predicate.evaluateWithObject(targetString)
    }
    
    static func vaildInputWith(type:String,targetString:String) -> String? {
        var predicateString = "";var promptMsg = ""
        switch type {
        case "num":
            predicateString = "^[0-9]*$"
            promptMsg = "请输入正确数字"
        case "tel":
            predicateString = "((^(\\d{3}-)?\\d{8}|(^\\d{4}-)?\\d{7})(-\\d{1,4})?)|^1[34578]\\d{9}"
            promptMsg = "请输入正确座机号或手机号\n座机号或分机号使用-连接"
        case "email":
            predicateString = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]+.)+(com|cn)+"
            promptMsg = "邮箱格式不正确"
        case "idnum":
            predicateString = "^[1-9]\\d{5}(19|20)\\d{2}(0[1-9]|1[0-2])([0-2]\\d|3[0-1])\\d{4}"
            promptMsg = "身份证格式不正确\n末位为字母的请用0代替"
        case "banknum":
            predicateString = "^\\d{19}$"
            promptMsg = "请输入正确银行卡卡号"
        case "percent":
            predicateString = "^\\d*(.\\d+)*%$"
            promptMsg = "格式有误，此处应输入正确百分比"
        case "pnum":
            predicateString = "^[0-9]*$"
            promptMsg = "请输入正确数字"
        case "decimal":
            predicateString = "^0\\.\\d+$"
            promptMsg = "利率格式不正确"
        default:
            return nil
        }
        var predicate:NSPredicate = NSPredicate(format:"SELF MATCHES %@", predicateString)
        var isVaild:Bool = predicate.evaluateWithObject(targetString)
        if !isVaild {
            return promptMsg
        }
        return nil
    }
    
    static func keyboardTypeWithType(type:String) -> UIKeyboardType? {
        switch type {
        case "email":
            return UIKeyboardType.URL
        case "num","tel","idnum","banknum","percent","pnum","decimal":
            return UIKeyboardType.NumbersAndPunctuation
        default:
            return UIKeyboardType.Default
        }
    }
    
    static func infoWithFileName(fileName:String) -> NSMutableDictionary {
        let filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileName).plist")//.stringByAppendingPathComponent("\(fileName).plist")
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            return NSMutableDictionary(contentsOfFile: filePath)!
        }
        return NSMutableDictionary()
    }
    
    static func infoWriteToFile(fileName:String,info:NSMutableDictionary) {
        let filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileName).plist")//.stringByAppendingPathComponent("\(fileName).plist")
        let k = info.writeToFile(filePath, atomically: false)
        println(k)
        println(NSFileManager.defaultManager().fileExistsAtPath(filePath))
    }
}
