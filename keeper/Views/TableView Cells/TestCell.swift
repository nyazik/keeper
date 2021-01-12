//
//  TestCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 23.12.2020.
//

import UIKit

class TestCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceTextLabel: UILabel!
    @IBOutlet weak var servicesOppportunityLabel: UILabel!
    
    
    
    func configureCell() {
        cellView.layer.cornerRadius = 15
    }

}
