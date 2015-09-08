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
        let bar = self.tabBar.items![1] as! UITabBarItem
        //bar.badgeValue = "{"
        // Do any additional setup after loading the view.
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
