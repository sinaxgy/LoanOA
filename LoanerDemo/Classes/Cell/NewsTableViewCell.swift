//
//  NewsTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/16.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var subTextLabel: UILabel!

    
    func setupNewsCell(title:String,date:String,isRead:Bool) {
        self.titleLabel.text = title
        self.titleLabel.font = UIFont.systemFontOfSize(textFontSize)
        self.subTextLabel.font = UIFont.systemFontOfSize(detailFontSize)
        self.subTextLabel.text = date
        self.imageV.frame = CGRectMake(0, 0, 36, 36)
        self.imageV.image = UIImage(named: (isRead ? "ancReaded" : "announce"))
    }
    
    func setupCell(title:String,date:String,isRead:Bool) {
        self.titleLabel.text = title
        self.titleLabel.font = UIFont.systemFontOfSize(textFontSize)
        self.subTextLabel.font = UIFont.systemFontOfSize(detailFontSize)
        self.subTextLabel.text = date
        self.imageV.frame = CGRectMake(0, 0, 36, 36)
        self.imageV.image = UIImage(named: (isRead ? "finance" : "finance"))
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
