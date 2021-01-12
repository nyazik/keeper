//
//  ForgotPasswordVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 23.12.2020.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var underlineView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts ()
    }
    
    func setupLayouts (){
        configureSendButton(button: sendButton)
        configureTextField(textField: mailTextField)
        configureView(view: underlineView)
    }
    
    func configureSendButton(button: UIButton){
        button.layer.cornerRadius = 15
    }
    
    func configureView(view: UIView){
        view.layer.cornerRadius = 2
    }
    
    func configureTextField(textField: UITextField){
        textField.layer.cornerRadius = 15
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
    }
    
    @IBAction func backToSignIn(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sendPassword(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    
    
    
}
