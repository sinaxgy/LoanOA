//
//  DatepickerView.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/25.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol DatePickerViewDateDelegate:NSObjectProtocol {
    func datePickerDidEnsure(date:String)
    func datePickerDidCancel()
}

class DatepickerView: UIView {
    
    var datepicker = UIDatePicker()
    var dateDelegate:DatePickerViewDateDelegate!
    
    init(width:CGFloat) {
        super.init(frame: CGRectMake(0, 0, width, 256))
        self.backgroundColor = UIColor.whiteColor()
        self.initView(width)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.initView(width)
    }
    
    func initView(width:CGFloat) {
        let mainwidth = UIScreen.mainScreen().bounds.width
        let navBar:UINavigationBar = UINavigationBar(frame: CGRectMake(0, 0, mainwidth, 30))
        
        let navItem:UINavigationItem = UINavigationItem()
        let leftItem:UIBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancel:"))
        let rightItem:UIBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("ensure:"))
        navItem.leftBarButtonItem = leftItem
        navItem.rightBarButtonItem = rightItem
        navBar.pushNavigationItem(navItem, animated: false)
        self.addSubview(navBar)
        
        let locale:NSLocale = NSLocale(localeIdentifier: "zh_CN")
        datepicker.datePickerMode = UIDatePickerMode.Date
        datepicker.frame = CGRectMake(0, 30,mainwidth, 216)
        datepicker.locale = locale
        //datepicker.addTarget(view, action: Selector("picker:"), forControlEvents: UIControlEvents.ValueChanged)
        self.addSubview(datepicker)
    }
    
    func cancel(sender:UIBarButtonItem) {
        self.dateDelegate.datePickerDidCancel()
    }
    
    func ensure(sender:UIBarButtonItem) {
        let selectedDate:NSDate = datepicker.date
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString:String = formatter.stringFromDate(selectedDate)
        self.dateDelegate.datePickerDidEnsure(dateString)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}