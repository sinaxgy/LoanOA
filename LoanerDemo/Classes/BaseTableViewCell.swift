//
//  BaseTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/6/24.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    init(){//json:JSON){
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: "historyCell")
        self.textLabel?.font = UIFont.systemFontOfSize(12)
        //self.initView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
