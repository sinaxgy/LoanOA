//
//  BranchTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/7.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class BranchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
