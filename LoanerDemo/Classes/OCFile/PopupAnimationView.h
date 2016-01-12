//
//  PopupAnimationView.h
//  GDLocationGroup
//
//  Created by 徐成 on 15/5/11.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+DropViewController.h"
#import "LewPopupViewAnimationDrop.h"

@protocol personalMessageEditDelegete <NSObject>
@optional

- (void) textfieldMessageID:(NSString*)idunique;

@end

@interface PopupAnimationView : UIView<UITextFieldDelegate>
//@property (nonatomic, strong)IBOutlet UIView *innerView;
@property (nonatomic, weak)UIViewController *parentVC;

@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UITextField *idText;
@property (nonatomic ,weak) id <personalMessageEditDelegete> popupDelegete;

+ (instancetype)defaultPopupView;
- (void) setTextField:(NSString*)idtext;
@end
