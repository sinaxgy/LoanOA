//
//  UIViewController+DropViewController.m
//  GDLocationGroup
//
//  Created by 徐成 on 15/5/11.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import "UIViewController+DropViewController.h"


@interface UIViewController (DropViewControllerPrivate)
@property (nonatomic, retain) UIView *lewPopupView;
@property (nonatomic, retain) UIView *lewOverlayView;
@end

@implementation UIViewController (DropViewController)

#pragma mark - inline property
- (UIView *)lewPopupView {
    return objc_getAssociatedObject(self.view, kLEWPopupView);
}

- (void)setLewPopupView:(UIViewController *)lewPopupView {
    objc_setAssociatedObject(self.view, kLEWPopupView, lewPopupView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)lewOverlayView{
    return objc_getAssociatedObject(self, kLEWOverlayView);
}

- (void)setLewOverlayView:(UIView *)lewOverlayView {
    objc_setAssociatedObject(self, kLEWOverlayView, lewOverlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(void))lewDismissCallback{
    return objc_getAssociatedObject(self, kLEWPopupViewDismissedBlock);
}

- (void)setLewDismissCallback:(void (^)(void))lewDismissCallback{
    objc_setAssociatedObject(self, kLEWPopupViewDismissedBlock, lewDismissCallback, OBJC_ASSOCIATION_COPY);
}

- (id<PopupAnimationDelegete>)delegete{
    return objc_getAssociatedObject(self, KLEWPopupAnimation);
}

- (void)setLewPopupAnimation:(id<PopupAnimationDelegete>)popupDelegete{
    objc_setAssociatedObject(self, KLEWPopupAnimation, popupDelegete, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma public method
- (void)lew_presentPopupView:(UIView *)popupView animation:(id<PopupAnimationDelegete>)animationDelegete dismissed:(void (^)(void))dismissed{
    [self presentPopupView:popupView animation:animationDelegete dismissed:dismissed];
}

- (void)lew_presentPopupView:(UIView *)popupView animation:(id<PopupAnimationDelegete>)animationDelegete{
    [self presentPopupView:popupView animation:animationDelegete dismissed:nil];
}

- (void)lew_dismissPopupViewWithanimation:(id<PopupAnimationDelegete>)animationDelegete{
    [self dismissPopupViewWithAnimation:animationDelegete];
}

- (void)lew_dismissPopupView{
    [self dismissPopupViewWithAnimation:self.delegete];
}

#pragma mark - view handle

- (void)presentPopupView:(UIView*)popupView animation:(id<PopupAnimationDelegete>)animationDelegete dismissed:(void(^)(void))dismissed{
    
    
    // check if source view controller is not in destination
    if ([self.lewOverlayView.subviews containsObject:popupView]) return;
    
    self.lewPopupView = nil;
    self.lewPopupView = popupView;
    self.lewPopupAnimation = nil;
    self.lewPopupAnimation = animationDelegete;
    
    UIView *sourceView = [self topView];
    
    // customize popupView
    popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    popupView.tag = kLEWPopupViewTag;
    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
    popupView.layer.masksToBounds = NO;
    popupView.layer.shadowOffset = CGSizeMake(5, 5);
    popupView.layer.shadowRadius = 5;
    popupView.layer.shadowOpacity = 0.5;
    popupView.layer.shouldRasterize = YES;
    popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Add overlay
    if (self.lewOverlayView == nil) {
        UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayView.tag = kLEWOverlayViewTag;
        overlayView.backgroundColor = [UIColor clearColor];
        
        // BackgroundView
//        UIView *backgroundView = [[LewPopupBackgroundView alloc] initWithFrame:sourceView.bounds];
//        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        backgroundView.backgroundColor = [UIColor clearColor];
//        [overlayView addSubview:backgroundView];
        
        // Make the Background Clickable
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lew_dismissPopupView)];
        [overlayView addGestureRecognizer:tap];
        self.lewOverlayView = overlayView;
    }
    
    [self.lewOverlayView addSubview:popupView];
    [sourceView addSubview:self.lewOverlayView];
    
    self.lewOverlayView.alpha = .9f;
    popupView.center = self.lewOverlayView.center;
    if (animationDelegete) {
        [animationDelegete showView:popupView overlayView:self.lewOverlayView];
    }
    
    [self setLewDismissCallback:dismissed];
    
}

- (void)dismissPopupViewWithAnimation:(id<PopupAnimationDelegete>)animationDelegete{
    if (animationDelegete) {
        [animationDelegete dismissView:self.lewPopupView overlayView:self.lewOverlayView completion:^(void) {
            [self.lewOverlayView removeFromSuperview];
            [self.lewPopupView removeFromSuperview];
            self.lewPopupView = nil;
            self.lewPopupAnimation = nil;
            
            id dismissed = [self lewDismissCallback];
            if (dismissed != nil){
                ((void(^)(void))dismissed)();
                [self setLewDismissCallback:nil];
            }
        }];
    }else{
        [self.lewOverlayView removeFromSuperview];
        [self.lewPopupView removeFromSuperview];
        self.lewPopupView = nil;
        self.lewPopupAnimation = nil;
        
        id dismissed = [self lewDismissCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            [self setLewDismissCallback:nil];
        }
    }
}

-(UIView*)topView {
    UIViewController *recentView = self;
    
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

#pragma mark others
- (NSString*) getMainIDunique
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *data = [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath]mutableCopy];
    return [data objectForKey:@"idunique"];
}

- (NSString*) getMainName
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *data = [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath]mutableCopy];
    return [data objectForKey:@"username"];
}

- (void) setMainIDunique:(NSString*)idunique name:(NSString*)mainName
{
    NSString *plistPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)       objectAtIndex:0]stringByAppendingPathComponent:@"UserInfo.plist"];
    NSMutableDictionary *data = [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath]mutableCopy];
    [data setObject:idunique forKey:@"idunique"];
    [data setObject:mainName forKey:@"username"];
    [data writeToFile:plistPath atomically:YES];
}


@end
