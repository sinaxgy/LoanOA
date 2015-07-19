//
//  UIViewController+DropViewController.h
//  GDLocationGroup
//
//  Created by 徐成 on 15/5/11.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
//#import "PromptMessageView.h"

#define kLEWPopupView @"kLEWPopupView"
#define kLEWOverlayView @"kLEWOverlayView"
#define kLEWPopupViewDismissedBlock @"kLEWPopupViewDismissedBlock"
#define KLEWPopupAnimation @"KLEWPopupAnimation"

#define kLEWPopupViewTag 8002
#define kLEWOverlayViewTag 8003

@protocol PopupAnimationDelegete <NSObject>
@required

- (void) showView:(UIView*)popupView overlayView:(UIView*)overlayview;

- (void) dismissView:(UIView*)popupView overlayView:(UIView*)overlayView completion:(void(^)(void))completion;

@end

@interface UIViewController (DropViewController)

@property (nonatomic,retain,readonly) UIView* lewPopupView;
@property (nonatomic,retain,readonly) UIView* lewOverlayView;
@property (nonatomic,retain,readonly) id <PopupAnimationDelegete> delegete;

- (void)lew_presentPopupView:(UIView *)popupView animation:(id<PopupAnimationDelegete>)animation;
- (void)lew_presentPopupView:(UIView *)popupView animation:(id<PopupAnimationDelegete>)animation dismissed:(void(^)(void))dismissed;

- (void)lew_dismissPopupView;
- (void)lew_dismissPopupViewWithanimation:(id<PopupAnimationDelegete>)animation;

- (UIView*)topView;
- (NSString*) getMainIDunique;
- (NSString*) getMainName;
- (void) setMainIDunique:(NSString*)idunique name:(NSString*)mainName;
@end
