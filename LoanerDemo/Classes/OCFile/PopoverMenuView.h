//
//  PopoverMenuView.h
//  LoanerDemo
//
//  Created by 徐成 on 15/6/23.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NSGB2312StringEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

@class PopoverMenuView;

@protocol PopoverMenuViewDelegate <NSObject>

- (void) menuPopover:(PopoverMenuView*)menuView didSelectMenuItemAtIndex:(NSInteger)selectedIndex;

@end

@interface PopoverMenuView : UIView <UITableViewDataSource,UITableViewDelegate>


@property(nonatomic,assign) id<PopoverMenuViewDelegate> menuPopoverDelegate;

- (id)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems;
- (void)showInView:(UIView *)view;
- (void)dismissMenuPopover;
- (void)layoutUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
