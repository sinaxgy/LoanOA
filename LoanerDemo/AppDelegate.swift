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
    var user_id:String = "a";var pro_id:String = ""
    var offline_id:String = ""
    var ipUrl = "http://123.57.219.112/"//"http://10.104.7.241/"
    var IP = "123.57.219.112"//10.104.5.16"//"
        {
        didSet{
            self.ipUrl = "http://\(self.IP)/"
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        // 改变 navigation bar 的背景色
        var navigationBarAppearace = UINavigationBar.appearance()
        //        navigationBarAppearace.translucent = false
        navigationBarAppearace.barTintColor = UIColor(hex: navColor)
        navigationBarAppearace.tintColor = UIColor.whiteColor()
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(20, weight: 10)]
        if !UserHelper.readValueOfPWIsSaved() {
            let loginStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginedView:LoginsViewController = (loginStory.instantiateViewControllerWithIdentifier("LoginsViewController") as? LoginsViewController)!
            self.window?.rootViewController = loginedView
            return true
        }
        self.user_id = UserHelper.readRecentID()
        self.offline_id = self.getoffline_id()
        //self.IP = KeyChain.getIPItem(UserHelper.readRecentID(recentID)!) as String
        return true
    }
    
    func getoffline_id() -> String {
        let dicInfo:NSDictionary = UserHelper.readCurrentUserInfo(self.user_id)
        if dicInfo.count == 0 {return ""}
        return dicInfo.objectForKey("offline_id") as! String
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

