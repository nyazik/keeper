//
//  CardDetailsVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 24.12.2020.
//

import UIKit

class CardDetailsVC: UIViewController {
    
    @IBOutlet weak var packetNameLabel: UILabel!
    @IBOutlet weak var cardDetailView: UIView!
    @IBOutlet weak var subscriptionDetailView: UIView!
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var nameSurnameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationMonthTextField: UITextField!
    @IBOutlet weak var expirationYearTextField: UITextField!
    @IBOutlet weak var CCVTextField: UITextField!
    
    var selectedServiceID = ""
    var packageID = ""
    var packetName = ""
    var startEndDate = ""
    var remainingRights = ""
    var price = ""
    var startingTime = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("starting time in card detail \(startingTime)")
        hideKeyboardWhenTappedAround()
        setupLayouts()
        print("selectedServiceID in card detail \(selectedServiceID)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    func setupLayouts(){
        
        configureShadowtoView(view: switchView)
        configureShadowtoView(view: priceView)
        configureSwitch(view: cardDetailView)
        configureSwitch(view: subscriptionDetailView)
        
        pricePayRoundedCorner(view: priceView)
        pricePayRoundedCorner(view: payView)
        pricePayRoundedCorner(view: payButton)

        configureTextField(textField: nameSurnameTextField)
        configureTextField(textField: cardNumberTextField)
        configureTextField(textField: expirationMonthTextField)
        configureTextField(textField: expirationYearTextField)
        configureTextField(textField: CCVTextField)
        
        print(packageID)
        print(packetName)
        print(startEndDate)
        print(remainingRights)
        priceLabel.text = "\(price)₺"
        packetNameLabel.text = packetName
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "BuyPackageSubscribeVC") as! BuyPackageSubscribeVC
        vc.startingTime = startingTime
        vc.selectedServiceID = selectedServiceID
        vc.packageID = packageID
        vc.packetName = packageID
        vc.startEndDate = startEndDate
        vc.remainingRights =  remainingRights
        vc.price = price
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)

    }
    
    @IBAction func payButtonPressed(_ sender: UIButton) {
        if nameSurnameTextField.text != ""  && cardNumberTextField.text != "" && expirationMonthTextField.text != "" && expirationYearTextField.text != "" && CCVTextField.text != ""{
            buyPacket()
            
//            dismiss(animated: false, completion: nil)
        }else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func subscriptionDetailButtonPressed(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(identifier: "SubscriptionDetailVC") as! SubscriptionDetailVC
        vc.startingTime = startingTime
        vc.selectedServiceID = selectedServiceID
        vc.packetName = packetName
        vc.startEndDate = startEndDate
        vc.remainingRights = remainingRights
        vc.packageID = packageID
        vc.price = price
        
        vc.nameSurnameTextField = nameSurnameTextField.text!
        vc.cardNumberTextField = cardNumberTextField.text!
        vc.expirationMonthTextField = expirationMonthTextField.text!
        vc.expirationYearTextField = expirationYearTextField.text!
        vc.CCVTextField =  CCVTextField.text!
        
        
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: false, completion: nil)
    }
    
    func configureTextField(textField: UITextField){
        textField.setRightPaddingPoints(20)
        textField.setLeftPaddingPoints(20)
        textField.layer.cornerRadius = 15
    }
    
    func configureSwitch(view : UIView){
        view.layer.cornerRadius = 15
    }
    
    func configureShadowtoView(view: UIView){
        view.center = self.view.center
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 15
    }
   
    
    func pricePayRoundedCorner(view: UIView){
        view.layer.cornerRadius = 15

    }
    
    //MARK:- NETWORKING
 
    func buyPacket() {
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string:BaseURL.baseURL + "buy/\(packageID)")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "packet_id=\(packageID)"
        print("packet_id=\(packageID)")
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
                
                let registerResponse = try JSONDecoder().decode(PostMessageResponse.self, from: data)
                
                if registerResponse.status{
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .buyPackage, object: nil)

                        let vc = self.storyboard?.instantiateViewController(identifier: "BuyPackageSubscribeVC") as! BuyPackageSubscribeVC
                        vc.startingTime = self.startingTime
                        vc.selectedServiceID = self.selectedServiceID
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: false, completion: nil)
                        //self.dismiss(animated: false, completion: nil)
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: registerResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                print("Card details Response = \(jsonError)")
            }
            
        }
        task.resume()
    }

    
}
