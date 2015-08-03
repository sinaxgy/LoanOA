//
//  AppDelegate.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user_id:String = "a"
    var offline_id:String = ""
    var IP = "112.126.64.235:8843"//10.104.4.1521111"             //112.126.64.23:8843/"var IP = "h1ttp://10.104.4.153/"
    var ipUrl = "http://10.104.4.177/"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("selfInfo.plist")
        if !NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            //未保存密码信息，则进入登陆界面
            let loginStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginedView:LoginsViewController = (loginStory.instantiateViewControllerWithIdentifier("LoginsViewController") as? LoginsViewController)!
            self.window?.rootViewController = loginedView
            return true
        }
        self.IP = KeyChain.getIPItem(self.getuser_idFromPlist()) as String
        self.ipUrl = "http://\(self.IP)/"
        return true
    }
    
    func getuser_idFromPlist() -> String {
        let filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("selfInfo.plist")
        if NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            let dicInfo:NSDictionary = NSDictionary(contentsOfFile: filepath)!
            return dicInfo.objectForKey("user_id") as! String
        }
        return self.user_id
    }
    
    func getoffline_id() -> String {
        let filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("selfInfo.plist")
        if NSFileManager.defaultManager().fileExistsAtPath(filepath) {
            let dicInfo:NSDictionary = NSDictionary(contentsOfFile: filepath)!
            return dicInfo.objectForKey("offline_id") as! String
        }
        return self.offline_id as String
    }
    
    static func app() -> AppDelegate{
        return (UIApplication.sharedApplication().delegate as? AppDelegate)!
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

