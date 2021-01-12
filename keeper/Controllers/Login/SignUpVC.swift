//
//  SignUpViewController.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 22.12.2020.
//

import UIKit
import SideMenu
import Lottie

class SignUpVC: UIViewController {
    
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nameSurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmationPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private var animationBackView = UIView()
    private var animationView = AnimationView()
    
    var textFields: [UITextField] {
        return [nameSurnameTextField, emailTextField, phoneNumberTextField, passwordTextField, confirmationPasswordTextField]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLayout()
        textFields.forEach {$0.delegate = self}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    func setupLayout() {
        configureTextFields(textField: nameSurnameTextField)
        configureTextFields(textField: emailTextField)
        configureTextFields(textField: phoneNumberTextField)
        configureTextFields(textField: passwordTextField)
        configureTextFields(textField: confirmationPasswordTextField)
        configureButton(button: loginButton)
        configureView(view: underlineView)
    }
    
    func configureView(view: UIView){
        view.layer.cornerRadius = 2
    }
    
    func configureButton(button: UIButton){
        button.layer.cornerRadius = 15
    }
    
    func configureTextFields(textField: UITextField){
        textField.layer.cornerRadius = 15
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if nameSurnameTextField.text != "" && emailTextField.text != "" && phoneNumberTextField.text != "" && passwordTextField.text != "" && confirmationPasswordTextField.text != "" {
            if emailTextField.text!.isValidEmail(){
                if passwordTextField.text! == confirmationPasswordTextField.text! {
                    self.registerUser()
                }else{
                    let alert = UIAlertController(title: "Hata", message: "Şifreler uyuşmamaktadır. Lütfen kontrol ediniz.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }else {
                let alert = UIAlertController(title: "Hata", message: "Lütfen geçerli bir e-posta adresi giriniz.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SignInVC") as! SignInVC
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
    
    //MARK:- Networking
    func registerUser() {
        
        addViewsForAnimation()
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "register")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString =
            "mail=\(emailTextField.text!)&password=\(passwordTextField.text!)&name=\(nameSurnameTextField.text!)&phone=\(phoneNumberTextField.text!)"
        
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
                
                let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                
                if registerResponse.status{
                    DispatchQueue.main.async {
                        
                        self.removeViewsForAnimation()
                        
                        print("ACCESS TOKEN: \(registerResponse.data!.token!)")
                        UserDefaults.standard.set(registerResponse.data!.token!, forKey: "Autherization")
                        
                        let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                       
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        self.removeViewsForAnimation()
                        
                        let alert = UIAlertController(title: "Hata", message: registerResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    self.removeViewsForAnimation()
                    
                    print(jsonError)
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatasi", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let selectedTextFieldIndex = textFields.firstIndex(of: textField), selectedTextFieldIndex < textFields.count - 1 {
            textFields[selectedTextFieldIndex + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder() // last textfield, dismiss keyboard directly
        }
        return true
    }
}
