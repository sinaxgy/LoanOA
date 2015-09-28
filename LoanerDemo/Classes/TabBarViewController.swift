//
//  TabBarViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/9.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

enum CubeTabBarControllerAnimation {
    case None,Outside,Inside
}

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getAnnouncemetMessageNum()
        // Do any additional setup after loading the view.
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName:UIFont.systemFontOfSize(12),
                NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName:UIFont.systemFontOfSize(10),
                NSForegroundColorAttributeName:UIColor(red: 0.0/255.0, green: 46.0/255.0, blue: 116.0/205.0, alpha: 1)], forState: UIControlState.Selected)
        for item in self.tabBar.items! {
            item.image = item.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
    }
    
    func getAnnouncemetMessageNum() {
        let url = AppDelegate.app().ipUrl + config + "app/count?id=\(AppDelegate.app().offline_id)"
        NetworkRequest.AlamofireGetJSON(url, success: {
            (data) in
            let num = String(stringInterpolationSegment: data!)
            if num != "0" {
                let bar = self.tabBar.items![1] 
                bar.badgeValue = num
            }
            }, failed: {}, outTime: {})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
