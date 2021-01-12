//
//  ProfileDetailTableVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 2.01.2021.
//

import UIKit

class ProfileDetailTableVC: UITableViewController {
    
    @IBOutlet weak var accountCellView: UIView!
    @IBOutlet weak var subscriptionCellView: UIView!
    @IBOutlet weak var addressCellView: UIView!
    @IBOutlet weak var changePasswordCellView: UIView!
    @IBOutlet weak var signOutCellView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
    }
    
    func setupLayouts(){
        configureViewsShadow(newView: accountCellView)
        configureViewsShadow(newView: subscriptionCellView)
        configureViewsShadow(newView: addressCellView)
        configureViewsShadow(newView: changePasswordCellView)
        configureViewsShadow(newView: signOutCellView)
    }
    
    func configureViewsShadow(newView:UIView){
        newView.center = self.view.center
        newView.layer.shadowColor = UIColor.lightGray.cgColor
        newView.layer.shadowOpacity = 0.3
        newView.layer.shadowOffset = CGSize.zero
        newView.layer.shadowRadius = 5
        newView.layer.cornerRadius = 15
        newView.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0){
            let vc = self.storyboard?.instantiateViewController(identifier: "AccountDetailVC") as! AccountDetailVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }else if (indexPath.row == 1){
            let vc = self.storyboard?.instantiateViewController(identifier: "MySubscriptionsVC") as! MySubscriptionsVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }else if (indexPath.row == 2){
            let vc = self.storyboard?.instantiateViewController(identifier: "MyAddressesVC") as! MyAddressesVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }else if (indexPath.row == 3){
            let vc = self.storyboard?.instantiateViewController(identifier: "ChangePasswordVC") as! ChangePasswordVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }else if (indexPath.row == 4){
            let vc = self.storyboard?.instantiateViewController(identifier: "SignInVC") as! SignInVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
            
        }
    }
    
    
    
}
