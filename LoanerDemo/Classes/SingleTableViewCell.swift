//
//  SingleTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/27.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

protocol singleTableViewCellDelegate {
    func singleImageViewDidselected(view:UIImageView,cell:SingleTableViewCell)
}

class SingleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var mutableView: UIImageView!
    
    var singleDelegate:singleTableViewCellDelegate!
    var isMutable:Bool! = true {
        didSet{
            self.mutableView.hidden = !self.isMutable
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.imageV.addGestureRecognizer(tap)
        //self.mutableView.hidden = !self.isMutable
        //self.isMutable = true
    }
    
    func handleSingleTap(gesture:UITapGestureRecognizer) {
        if let view:UIImageView = gesture.view as? UIImageView {
            self.singleDelegate.singleImageViewDidselected(view, cell: self)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
