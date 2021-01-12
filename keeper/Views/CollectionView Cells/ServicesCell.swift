//
//  ServicesCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 23.12.2020.
//

import UIKit

class ServicesCell: UICollectionViewCell {
    @IBOutlet weak var servicesImage: UIImageView!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    
    func configureView(){
        cellView.layer.cornerRadius = 10
    }
    
}
