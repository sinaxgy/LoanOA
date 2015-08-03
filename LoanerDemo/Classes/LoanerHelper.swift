//
//  LoanerHelper.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/31.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class LoanerHelper: NSObject {
    
    static func sortArrayAscending(array:NSArray) -> NSArray{
        let array:NSArray = array.sortedArrayUsingComparator({
            (s1,s2) -> NSComparisonResult in
            if (s1 as! String) > (s2 as! String) {
            return NSComparisonResult.OrderedDescending
            }
            return NSComparisonResult.OrderedAscending
        })
        return array
    }
   
}
