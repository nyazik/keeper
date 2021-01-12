//
//  SubscriptionCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 28.12.2020.
//

import UIKit

class SubscriptionCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var subscriptionLabel: UILabel!
    
    func configureCell(){
        cellView.layer.cornerRadius = 15
        
    }
    
    func configuretabbarShadow(){
        cellView.backgroundColor = UIColor.white
        cellView.layer.shadowColor = UIColor.lightGray.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowRadius = 5
    }

}
