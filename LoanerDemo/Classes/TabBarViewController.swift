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
    
    var animation = CubeTabBarControllerAnimation.None
    var backgroundColor:UIColor = UIColor()
    var nextVC:UIViewController = UIViewController()
    
    override var selectedViewController: UIViewController? {
        didSet {
            //oldValue.cancel()
            if self.animation == CubeTabBarControllerAnimation.None {
                super.selectedViewController = nextVC//self.selectedViewController
                return
            }
            if nextVC == self.selectedViewController {
                return
            }
            self.view.userInteractionEnabled = false
            let array:NSArray = NSArray(array: self.viewControllers!)
            var nextIndex:Int = 0
            for index in array {
                if index.isKindOfClass(UIViewController) {
                    nextIndex = array.indexOfObject(self.nextVC)
                }
            }
            let currentVC = self.selectedViewController!
            nextVC.view.frame = self.selectedViewController!.view.frame
            let halfWidth:CGFloat = self.selectedViewController!.view.bounds.size.width / 2
            let duration:CGFloat = 0.7
            let perspective:CGFloat = -1/1000
            var superView:UIView = self.selectedViewController!.view.superview!
            var transformLayer:CATransformLayer = CATransformLayer()
            transformLayer.frame = self.view.layer.bounds
            self.selectedViewController!.view.removeFromSuperview()
            
            transformLayer.addSublayer(currentVC.view.layer)
            transformLayer.addSublayer(self.nextVC.view.layer)
            superView.backgroundColor = self.backgroundColor
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            var transform3D:CATransform3D = CATransform3DIdentity
            switch self.animation {
            case .None:
                transform3D = CATransform3DTranslate(transform3D, 0, 0, -halfWidth)
                transform3D = CATransform3DRotate(transform3D, CGFloat((nextIndex > self.selectedIndex ? M_PI_2:-M_PI_2)), 0, 1, 0)
                transform3D = CATransform3DTranslate(transform3D, 0, 0, halfWidth)
            case .Inside:
                transform3D = CATransform3DTranslate(transform3D, 0, 0, halfWidth)
                transform3D = CATransform3DRotate(transform3D, CGFloat((nextIndex > self.selectedIndex ? -M_PI_2:M_PI_2)), 0, 1, 0)
                transform3D = CATransform3DTranslate(transform3D, 0, 0, -halfWidth)
            default:
                break
            }
            self.nextVC.view.layer.transform = transform3D
            CATransaction.commit()
            CATransaction.begin()
            
            CATransaction.setCompletionBlock({
                () in
                self.nextVC.view.layer.removeFromSuperlayer()
                self.nextVC.view.layer.transform = CATransform3DIdentity
                currentVC.view.layer.removeFromSuperlayer()
                superView.backgroundColor = UIColor.clearColor()
                superView.addSubview(currentVC.view)
                transformLayer.removeFromSuperlayer()
                super.selectedViewController = self.nextVC
                self.view.userInteractionEnabled = true
            })
            
            var transformAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform3D")
            transform3D = CATransform3DIdentity
            transform3D.m34 = perspective           //透视效果
            transformAnimation.fromValue = NSValue(CATransform3D: transform3D)  //动画的开始值
            transform3D = CATransform3DIdentity
            transform3D.m34 = perspective
            switch self.animation {
            case .Outside:
                transform3D = CATransform3DTranslate(transform3D, 0, 0, -halfWidth)
                transform3D = CATransform3DRotate(transform3D, CGFloat((nextIndex>self.selectedIndex ? -M_PI_2:M_PI_2)), 0, 1, 0)
                transform3D = CATransform3DTranslate(transform3D, 0, 0, halfWidth)
            case .Inside:
                transform3D = CATransform3DTranslate(transform3D, 0, 0, halfWidth)
                transform3D = CATransform3DRotate(transform3D, CGFloat((nextIndex>self.selectedIndex ? M_PI_2:-M_PI_2)), 0, 1, 0)
                transform3D = CATransform3DTranslate(transform3D, 0, 0, -halfWidth)
            default:
                break
            }
            transformAnimation.toValue = NSValue(CATransform3D: transform3D)
            transformAnimation.duration = CFTimeInterval(duration)
            transformLayer.addAnimation(transformAnimation, forKey: "rotate")
            transformLayer.transform = transform3D
            CATransaction.commit()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
