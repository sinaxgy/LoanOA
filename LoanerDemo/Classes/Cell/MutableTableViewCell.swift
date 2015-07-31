//
//  MutableTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/27.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol MutableTableViewDelegate {
    func mutablePhotoesDidBeshowedMore(cell:MutableTableViewCell,isShow:Bool)
}

class MutableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var subTextLabel: UILabel!
    var delagate:MutableTableViewDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupShowButtonState() {
        self.showBtn.setImage(UIImage(named: "hideUp"), forState: UIControlState.Normal)
        self.showBtn.setImage(UIImage(named: "showDown"), forState: UIControlState.Selected)
    }
    
    @IBAction func showSubViewClicked(sender: UIButton) {
        println("showSubViewClicked")
        self.showBtn.selected = !self.showBtn.selected
        self.delagate.mutablePhotoesDidBeshowedMore(self,isShow: self.showBtn.selected)
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
