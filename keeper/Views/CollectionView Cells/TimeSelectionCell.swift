//
//  TimeSelectionCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 27.12.2020.
//

import UIKit

class TimeSelectionCell: UICollectionViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func layoutSubviews() {
            super.layoutSubviews()
            reload()
        }
    
    
    func reload() {
        if isSelected {
            cellView.backgroundColor  = UIColor(named: "pinkColor")
            timeLabel.textColor = UIColor.white
        }
        
        
        else {
            cellView.backgroundColor  = UIColor(named: "grayColornhjb")
            timeLabel.textColor = UIColor.darkGray
        }
    }
    
    
}
