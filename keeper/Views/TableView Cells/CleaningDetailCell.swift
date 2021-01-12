//
//  CleaningDetailCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 26.12.2020.
//

import UIKit

class CleaningDetailCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var commentsDateLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    
    func configurelogoImageView(){
        logoImageView.layer.cornerRadius = logoImageView.frame.size.height/2

    }
}
