//
//  AccountDetailVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 29.12.2020.
//

import UIKit



class AccountDetailVC: UIViewController {
    
    
    @IBOutlet weak var nameSurnameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    var nameSurname : String = ""
    var email : String = ""
    var phone : String = ""
    
    var textFields: [UITextField] {
        return [nameSurnameTextField, mailTextField, phoneNumberTextField]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        hideKeyboardWhenTappedAround()
        textFields.forEach {$0.delegate = self}
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    
    func setupLayouts(){
        nameSurnameTextField.text = nameSurname
        mailTextField.text = email
        phoneNumberTextField.text = phone
        configureTextFields(textField: nameSurnameTextField)
        configureTextFields(textField: mailTextField)
        configureTextFields(textField: phoneNumberTextField)
    }
    
    @IBAction func changeButtonPRessed(_ sender: UIButton) {
        updateAccountDetailInfo()
        
    }
    
    func configureTextFields(textField: UITextField){
        textField.layer.cornerRadius = 15
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    func updateAccountDetailInfo() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "user")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "mail=\(mailTextField.text!)&name=\(nameSurnameTextField.text!)&phone=\(phoneNumberTextField.text!)"
        
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        // Set HTTP Request Header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Set HTTP Request URL Encoded
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
                if dataString.contains("true") {
                    DispatchQueue.main.async {
                        
                        NotificationCenter.default.post(name: .updateAccountDetail, object: nil)
                        
                        self.dismiss(animated: false, completion: nil)
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        
                        
                        let alert = UIAlertController(title: "Hata", message: "Bir hata oluştu. Lütfen tekrar deneyiniz.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    
}


extension AccountDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let selectedTextFieldIndex = textFields.firstIndex(of: textField), selectedTextFieldIndex < textFields.count - 1 {
            textFields[selectedTextFieldIndex + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder() // last textfield, dismiss keyboard directly
        }
        return true
    }
}
