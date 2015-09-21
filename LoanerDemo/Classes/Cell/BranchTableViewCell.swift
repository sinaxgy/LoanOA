//
//  BranchTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/7.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class BranchTableViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleLabel: UILabel!
    var titleImage:UIImage? {
        didSet {
            self.imgView.image = self.titleImage
        }
    }
    
    var title:String? {
        didSet{
            self.titleLabel.text = self.title
        }
    }
    
    init(width:CGFloat, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: "")
        imgView = UIImageView(frame: CGRectMake(15, 0, width, width))
        imgView.contentMode = UIViewContentMode.ScaleAspectFit
        imgView.centerY = cellHeight / 2
        self.addSubview(imgView)
        titleLabel = UILabel(frame: CGRectMake(30 + width, 0, UIScreen.mainScreen().bounds.width - width - 50, width))
        titleLabel.centerY = cellHeight / 2
        titleLabel.font = UIFont.systemFontOfSize(detailFontSize)
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.addSubview(titleLabel)
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
