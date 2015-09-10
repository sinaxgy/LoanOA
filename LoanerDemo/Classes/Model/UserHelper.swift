//
//  UserHelper.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/8/31.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

let PWIsSaved = "PWIsSaved"
let recentID = "recentID"

class UserHelper: NSObject {
    
    static func setValueOfPWIsSaved(isSaved:Bool) {
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            user?.setObject(isSaved, forKey: PWIsSaved)
            user?.synchronize()
        }
    }
    
    static func setRecentID(recentId:String) {
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            user?.setObject(recentId, forKey: recentID)
            user?.synchronize()
        }
    }
    
    static func setCurrentUserInfo(dicInfo:NSDictionary,user_id:String) -> Bool {
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            user?.setObject(dicInfo, forKey: user_id)
            return user!.synchronize()
        }
        return false
    }
   
    static func readCurrentUserInfo(user_id:String?) -> NSDictionary? {
        if user_id == nil {return NSDictionary()}
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            if let dic =  user?.objectForKey(user_id!) as? NSDictionary {
                return dic
            }
        }
        return nil
    }
    
    static func readValueOfPWIsSaved() -> Bool {
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            return user!.boolForKey(PWIsSaved)
        }
        return false
    }
    
    static func readRecentID(recentId:String) -> String? {
        var user:NSUserDefaults? = NSUserDefaults.standardUserDefaults()
        if (user != nil) {
            if NSUserDefaults.standardUserDefaults().objectForKey(recentID) != nil {
            return user!.stringForKey(recentID)!
            }
        }
        return nil
    }
}
