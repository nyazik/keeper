//
//  ViewController.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 22.12.2020.
//

import UIKit

class FirstScreenVC: UIViewController {
    
    @IBOutlet weak var singnInButton: UIView!
    @IBOutlet weak var signUpButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    func setupLayout() {
        configureRoundedButton(button: singnInButton)
        configureRoundedButton(button: signUpButton)
    }
    
    func configureRoundedButton(button: UIView){
        button.layer.cornerRadius = 15
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignInVC") as! SignInVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    @IBAction func signUp(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpVC") as! SignUpVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
}

