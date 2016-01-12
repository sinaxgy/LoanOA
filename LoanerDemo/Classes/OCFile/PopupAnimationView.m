//
//  PopupAnimationView.m
//  GDLocationGroup
//
//  Created by 徐成 on 15/5/11.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

#import "PopupAnimationView.h"
#import "MBProgressHUD.h"

@implementation PopupAnimationView
@synthesize okButton,idLabel,idText,parentVC,popupDelegete;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        [self initControllers];
    }
    return self;
}

+ (instancetype)defaultPopupView{
    return [[PopupAnimationView alloc]initWithFrame:CGRectMake(0, 0, 300, 150)];
}

- (void) initControllers
{
    idLabel = [[UILabel alloc] init];
    idLabel.frame = CGRectMake(10, 50, 60, 20);
    idLabel.text = @"IP地址:";
    idLabel.textColor = [UIColor whiteColor];
    [self addSubview:idLabel];
    
    idText = [[UITextField alloc]init];
    idText.frame = CGRectMake(80, 40, 200, 40);
    idText.backgroundColor = [UIColor whiteColor];
    idText.borderStyle = UITextBorderStyleRoundedRect;
    idText.font = [UIFont systemFontOfSize: 14];
    idText.autocorrectionType = UITextAutocorrectionTypeNo;
    idText.keyboardAppearance = UIKeyboardTypeDefault;
    idText.clearButtonMode = UITextFieldViewModeWhileEditing;
    idText.delegate = self;
    idText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    idText.enablesReturnKeyAutomatically = YES;
    [self addSubview:idText];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 300, 1)];
    line.image = [UIImage imageNamed:@"line"];
    [self addSubview:line];
    
    okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 -40, self.bounds.size.height - 20, 80, 30)];
    okButton.frame = CGRectMake(self.bounds.size.width / 2 -50, self.bounds.size.height - 40, 100, 30);
    okButton.backgroundColor = [UIColor greenColor];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor grayColor];
    okButton.layer.cornerRadius = 6.0f;
    [okButton addTarget:self action:@selector(personalMsgEdited) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okButton];
}

- (void) setTextField:(NSString*)idtext
{
    idText.text = idtext;
}

- (void) personalMsgEdited
{
    [popupDelegete textfieldMessageID:idText.text];
    [parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self personalMsgEdited];
    return YES;
}

-(BOOL)isVaildIP:(NSString*)str {
    NSString*pre = @"^\\d{1,3}(.\\d{1,3}){3}(:\\d{1,4})?";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pre];
    return [predicate evaluateWithObject:str];
}

#pragma mark UITextFieldDelegate
//处理键盘弹出时会遮盖单行输入框的问题，将视图上移
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int offset = parentVC.view.center.y - 150;
    NSTimeInterval animationDuration = 0.30f; //Duration  持续
    [UIView beginAnimations:@"ResizeForKeyboard" context:Nil];
    [UIView setAnimationDuration:animationDuration];
    if (offset > 0) {
        self.center = CGPointMake(parentVC.view.center.x, parentVC.view.center.y - 100);
    }
    [UIView commitAnimations];
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (![self isVaildIP:textField.text]) {
//        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.parentVC.view];
//        [self.parentVC.view addSubview:hud];
//        [hud show:true];
//        hud.mode = MBProgressHUDModeText;
//        hud.detailsLabelFont = [UIFont systemFontOfSize:17];
//        hud.detailsLabelText = @"请输入正确格式的IP地址\n端口号使用:连接";
//        [hud hide:true afterDelay:2];
//        return false;
//    }
//    [self personalMsgEdited];
//    return true;
//}

@end
