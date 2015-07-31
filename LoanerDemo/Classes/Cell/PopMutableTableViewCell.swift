//
//  PopMutableTableViewCell.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/7/31.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class PopMutableTableViewCell: UITableViewCell ,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var mutableCollection: UICollectionView!
    let mColCell = "mutableCollectionCell"
    var imageUrlArray:NSArray = []
    
    func setupMutableCollection() {
        self.mutableCollection.registerNib(UINib(nibName: "SubPopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: mColCell)
        self.mutableCollection.allowsMultipleSelection = true
        self.mutableCollection.dataSource = self
        self.mutableCollection.delegate = self
        self.mutableCollection.backgroundColor = UIColor.whiteColor()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageUrlArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = self.mutableCollection.dequeueReusableCellWithReuseIdentifier(self.mColCell, forIndexPath: indexPath) as? SubPopCollectionViewCell {
            let url = AppDelegate.app().ipUrl + (self.imageUrlArray[indexPath.row] as! String)
            cell.imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: placeholderImageName))
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(60, 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 15, 5, 15)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("collectionView")
        println(indexPath.row)
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
