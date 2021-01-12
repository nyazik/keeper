//
//  AddressesCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 29.12.2020.
//

import UIKit

class AddressesCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    func configureCellView(){
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
