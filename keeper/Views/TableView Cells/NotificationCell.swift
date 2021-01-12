//
//  NotificationCell.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 25.12.2020.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var notificationTextLabel: UILabel!
    
    @IBOutlet weak var notificationDataLabel: UILabel!
    
    
    func configureImage(){
        notificationImageView.layer.cornerRadius = notificationImageView.frame.size.height / 2
    }
    
}
