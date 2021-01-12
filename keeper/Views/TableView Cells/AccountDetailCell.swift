//
//  AccountDetailCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 2.01.2021.
//

import UIKit

class AccountDetailCell: UITableViewCell {
    @IBOutlet weak var accountDetailNameLabel: UILabel!
    
    @IBOutlet weak var cellView: UIView!
    
    func configureViewsShadow(){
        cellView.layer.shadowColor = UIColor.lightGray.cgColor
        cellView.layer.shadowOpacity = 0.3
        cellView.layer.shadowOffset = CGSize.zero
        cellView.layer.shadowRadius = 5
        cellView.layer.cornerRadius = 15
        cellView.backgroundColor = UIColor.white
    }
    
}
