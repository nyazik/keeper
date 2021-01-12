//
//  BuyPackageCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 24.12.2020.
//

import UIKit

protocol BuyPackageCellDelegate {
    func didBuyButtonPressed(tag: Int)
}

class BuyPackageCell: UICollectionViewCell {
    
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var packagePriceLabel: UILabel!
    @IBOutlet weak var buyPackageButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    var delegate: BuyPackageCellDelegate?
    
    func configureRadiusComponents() {
        cellView.layer.cornerRadius = 15
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.systemPink.cgColor
        cellView.layer.backgroundColor = UIColor.white.cgColor
        //configurations for buyPackageButton
        
        buyPackageButton.layer.borderWidth = 2
        buyPackageButton.layer.cornerRadius = 10
        buyPackageButton.layer.borderColor = UIColor.white.cgColor
        
        priceView.layer.cornerRadius = 15
        priceView.layer.borderWidth = 2
        priceView.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reload()
    }
    
    func reload() {
        if isSelected {
            cellView.backgroundColor  = UIColor(named: "pinkColor")
            packageNameLabel.textColor = UIColor.white
            packageDescriptionLabel.textColor = UIColor.white
        }
        
        else {
            cellView.backgroundColor  = UIColor.white
            packageNameLabel.textColor = UIColor.darkGray
            packageDescriptionLabel.textColor = UIColor.darkGray
        }
    }
    
    @IBAction func buyButtonPressed(_ sender: UIButton){
        delegate?.didBuyButtonPressed(tag: sender.tag)
    }
}
