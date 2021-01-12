//
//  SignInVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 22.12.2020.
//

import UIKit
import SideMenu
import Lottie

class SignInVC: UIViewController {
    
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var animationBackView = UIView()
    private var animationView = AnimationView()
    
    var textFields: [UITextField] {
        return [mailTextField, passwordTextField]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupLayout()
        
        textFields.forEach {$0.delegate = self}
    }
    
    func setupLayout() {
        configureTextFields(textField: mailTextField)
        configureTextFields(textField: passwordTextField)
        configureButton(button: signInButton)
        configureView(view: underlineView)
    }
    
    func configureView(view: UIView){
        view.layer.cornerRadius = 2
    }
    
    func configureTextFields(textField : UITextField){
        textField.layer.cornerRadius = 15
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
    }
    
    func configureButton(button: UIButton){
        button.layer.cornerRadius = 15
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if mailTextField.text != "" && passwordTextField.text != "" {
            if mailTextField.text!.isValidEmail() {
                loginUser()
            } else {
                let alert = UIAlertController(title: "Hata", message: "Lütfen geçerli bir e-posta adresi giriniz.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpVC") as! SignUpVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ForgotPasswordVC") as! ForgotPasswordVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    
    //MARK: -LOTTIE
    func addViewsForAnimation() {
        animationBackView = UIView(frame: CGRect(x: 0, y: 0, width: Int(self.view.frame.size.width), height: Int(self.view.frame.size.height)))
        animationBackView.backgroundColor = UIColor.lightGray
        animationBackView.alpha = 0.5
        self.view.addSubview(animationBackView)
        
        animationView = .init(name: "loading")
        animationView.contentMode = .scaleAspectFit
        animationView.frame = CGRect(x: (self.view.frame.size.width / 2) - 100, y: (self.view.frame.size.height / 2) - 100, width: 200, height: 200)
        animationView.loopMode = .loop
        self.view.addSubview(animationView)
        animationView.play()
    }
    
    func removeViewsForAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animationView.stop()
            self.animationBackView.removeFromSuperview()
            self.animationView.removeFromSuperview()
        }
    }
    
    
    //MARK: -Networking
    func loginUser() {

        addViewsForAnimation()
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "login")
        
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "mail=\(mailTextField.text!)&password=\(passwordTextField.text!)"
        
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            
            guard let data = data else {return}
            
            do{
                
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                if loginResponse.status{
                    DispatchQueue.main.async {
                        
                        print("ACCESS TOKEN: \(loginResponse.data!.token!)")
                        
                        UserDefaults.standard.set(loginResponse.data!.token!, forKey: "Autherization")
                        
                        let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                        self.removeViewsForAnimation()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.removeViewsForAnimation()
                        let alert = UIAlertController(title: "Hata", message: loginResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Login Response = \(jsonError)")
                    self.removeViewsForAnimation()
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
}

extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let selectedTextFieldIndex = textFields.firstIndex(of: textField), selectedTextFieldIndex < textFields.count - 1 {
            textFields[selectedTextFieldIndex + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder() // last textfield, dismiss keyboard directly
        }
        return true
    }
}


