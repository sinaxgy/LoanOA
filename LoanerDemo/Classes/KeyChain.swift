//
//  KeyChain.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/13.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class KeyChain: NSObject {
    
    static func isExistMatching() -> Bool{
        return true
    }
    
    static func addKeyChainItem(user_id:NSString,user_password:NSString,IP:NSString) -> Bool {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)

        if SecItemCopyMatching(keyChainItem,nil) == noErr{
            return false
        }else{
            keyChainItem.setObject(user_password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)!, forKey: kSecValueData as String)
            keyChainItem.setObject(IP, forKey:  kSecAttrServer as NSString)
            var status = SecItemAdd(keyChainItem, nil)
            if status == 0 {
                return true
            }
            return false
        }
    }
    
    static func updateIPItem(user_id:NSString,IP:NSString) -> Bool {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)
        
        if SecItemCopyMatching(keyChainItem,nil) == noErr{
            var updateDictionary = NSMutableDictionary()
            updateDictionary.setObject(IP, forKey:kSecAttrServer as String)
            var status = SecItemUpdate(keyChainItem,updateDictionary)
            return true
        }
        return false
    }
    
    static func updateKeyChainItem(user_id:NSString,user_password:NSString) -> Bool {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)
        
        if SecItemCopyMatching(keyChainItem,nil) == noErr{
            var updateDictionary = NSMutableDictionary()
            updateDictionary.setObject(user_password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)!, forKey:kSecValueData as String)
            var status = SecItemUpdate(keyChainItem,updateDictionary)
            return true
        }
        return false
    }
    
    static func getKeyChainItem(user_id:NSString) -> NSString {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)
        
        keyChainItem.setObject(kCFBooleanTrue, forKey: kSecReturnData as String)
        keyChainItem.setObject(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        var queryResult: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(keyChainItem,&queryResult)
        let opaque = queryResult?.toOpaque()
        var contentsOfKeychain: NSString?
        if let op = opaque {
            let retrievedData = Unmanaged<NSDictionary>.fromOpaque(op).takeUnretainedValue()
            let passwordData = retrievedData.objectForKey(kSecValueData) as! NSData
            return NSString(data: passwordData, encoding: NSUTF8StringEncoding)!
        }
        return ""
    }
    
    static func getIPItem(user_id:NSString) -> NSString {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)
        
        keyChainItem.setObject(kCFBooleanTrue, forKey: kSecReturnData as String)
        keyChainItem.setObject(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        var queryResult: Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(keyChainItem,&queryResult)
        let opaque = queryResult?.toOpaque()
        var contentsOfKeychain: NSString?
        if let op = opaque {
            let retrievedData = Unmanaged<NSDictionary>.fromOpaque(op).takeUnretainedValue()
            let IP = retrievedData.objectForKey(kSecAttrServer) as! NSString
            return IP
        }
        return ""
    }

    static func deleteKeyChainItem(user_id:NSString) -> Bool {
        var keyChainItem = NSMutableDictionary()
        keyChainItem.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        keyChainItem.setObject(user_id, forKey: kSecAttrAccount as NSString)
        
        if SecItemCopyMatching(keyChainItem,nil) == noErr{
            let status = SecItemDelete(keyChainItem)
            if status == 0 {
                return true
            }
        }
        return false
    }

   
}
