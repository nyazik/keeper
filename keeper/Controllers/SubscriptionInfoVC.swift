//
//  SubscriptionInfoVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 29.12.2020.
//

import UIKit

class SubscriptionInfoVC: UIViewController {
    
    @IBOutlet weak var subscriberIDTextField: UITextField!
    @IBOutlet weak var serviceTextField: UITextField!
    @IBOutlet weak var packageTextField: UITextField!
    @IBOutlet weak var remainingNumberTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!
    
    var subscriotionId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        print(subscriotionId)
        getPackageInfo()
    }
    
    func setupLayouts(){
        configureTextFieldPadding(textField: subscriberIDTextField)
        configureTextFieldPadding(textField: serviceTextField)
        configureTextFieldPadding(textField: packageTextField)
        configureTextFieldPadding(textField: remainingNumberTextField)
        configureTextFieldPadding(textField: startDateTextField)
        configureTextFieldPadding(textField: endDateTextField)
        configureTextFieldPadding(textField: statusTextField)
    }
    
    func configureTextFieldPadding(textField: UITextField){
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
//        let vc = self.storyboard?.instantiateViewController(identifier: "BuyPackageSubscribeVC") as! BuyPackageSubscribeVC
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: false, completion: nil)
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func getPackageInfo() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "order/\(subscriotionId)")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // Set HTTP Request Header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
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
                
                let packageInfoResponse = try JSONDecoder().decode(PackageDetailResponse.self, from: data)
                
                if packageInfoResponse.status{
                    DispatchQueue.main.async {
                        self.subscriberIDTextField.text = packageInfoResponse.data?.id ?? ""
                        self.serviceTextField.text = packageInfoResponse.data?.service_name
                        self.packageTextField.text = packageInfoResponse.data?.packet_name
                        
                        self.startDateTextField.text = packageInfoResponse.data?.date_start
                        self.endDateTextField.text = packageInfoResponse.data?.date_end
                        self.statusTextField.text = packageInfoResponse.data?.status
                        self.remainingNumberTextField.text = packageInfoResponse.data?.amount
//                        self.subscriotionId =
                        //self.subscriotionId = packageInfoResponse.data.id
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: packageInfoResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("Package Info Response = \(jsonError)")
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
