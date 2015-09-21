//
//  LeafTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/2.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class LeafTableViewCell: UITableViewCell ,UIActionSheetDelegate{

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    let disenableTableArray = ["pro_num","pro_title","service_type","loan_period","offline_id","repay_method"]
    var itemInfo:tableItemInfo!
    var editable:Bool! {
        didSet{
        }
    }
    
    func initCellInfomation(title:String, forjson json:JSON,editable:Bool) {
        self.itemInfo = tableItemInfo(title: title, json: json, editable: editable)
        self.selectionStyle = UITableViewCellSelectionStyle.Gray
        titleLabel.font = UIFont.systemFontOfSize(textFontSize)
        titleLabel.text = "\(self.itemInfo.explain):"
        detailLabel.text = self.itemInfo.value as String
        detailLabel.font = UIFont.systemFontOfSize(detailFontSize)
        if !itemInfo.editable {
            detailLabel.textColor = UIColor.grayColor()
            self.accessoryType = UITableViewCellAccessoryType.None
        }else {
            detailLabel.textColor = UIColor.blackColor()
            self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
