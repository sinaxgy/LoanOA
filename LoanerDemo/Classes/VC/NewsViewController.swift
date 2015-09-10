//
//  NewsViewController.swift
//  LoanerDemo
//
//  Created by 徐成 on 15/9/9.
//  Copyright (c) 2015年 徐成. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var titles:String = ""
    var date:String = ""
    var detail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = titles
        self.dateLabel.text = date
        self.detailText.text = detail
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Bordered, target: self, action: "cancel:")
        // Do any additional setup after loading the view.
    }
    
    func cancel(sender:UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupMessage(title:String,date:String,text:String) {
        self.titleLabel.text = title
        self.dateLabel.text = date
        self.detailText.text = text
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
