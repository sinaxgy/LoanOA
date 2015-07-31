//
//  BrowseViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/29.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    var imageArray:NSArray = []
    var imageView:UIImageView!
    var currentPageLabel:UILabel!
    var originalBtn:UIButton!
    var image:UIImage = UIImage()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSubView()
        self.imageView.image = image
//        if self.imageArray.count > 0 {
//            let url = "\(AppDelegate.app().ipUrl)" + (self.imageArray.firstObject as! String)
//            self.imageView.setImageWithURL(NSURL(string: url), placeholderImage: nil)
//            self.currentPageLabel.text = "1/1"
//        }
        // Do any additional setup after loading the view.
    }
    
    func initSubView() {
        self.imageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(self.imageView)
        var singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        self.imageView.addGestureRecognizer(singleTap)
        
        var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "keyboardHide")
        self.view.addGestureRecognizer(tapGesture)
        
        self.currentPageLabel = UILabel(frame: CGRectMake(20, self.view.bounds.height - 40, 200, 20))
        self.currentPageLabel.textColor = UIColor.whiteColor()
        self.currentPageLabel.text = "1/1"
        self.view.addSubview(self.currentPageLabel)
        
        self.originalBtn = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        self.originalBtn.frame = CGRectMake(self.view.bounds.width - 100, 30, 80, 30)
        self.originalBtn.setTitle("显示原图", forState: UIControlState.Normal)
        self.originalBtn.addTarget(self, action: "showOriginalImage:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.originalBtn)
    }
    
    func showOriginalImage(sender:UIButton) {
        if var str = self.imageArray.firstObject as? NSString {
            println(str.length)
            let subUrl = str.stringByReplacingCharactersInRange(NSMakeRange(str.length - 10, 10), withString: ".jpg")
            println(subUrl)
            let url = AppDelegate.app().ipUrl + subUrl + "?\(arc4random() % 10)"
            self.imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
        }
    }
    
    func keyboardHide() {
        println("asasdasdasdh")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleSingleTap() {
        println("asdh")
        self.dismissViewControllerAnimated(true, completion: nil)
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
