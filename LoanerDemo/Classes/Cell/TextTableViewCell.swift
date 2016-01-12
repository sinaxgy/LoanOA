//
//  TextTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/2.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol defaultTextDelegate {
    func defaultTextShouldBeDelete(text:String)
}

class TextTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    var delegate:defaultTextDelegate!
    var titleText:String! = "" {didSet{self.titleLabel.text = titleText}}
    @IBAction func deleteAction(sender: AnyObject) {
        self.delegate.defaultTextShouldBeDelete(self.titleText)
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
