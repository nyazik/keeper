//
//  SubscriptionDetailVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 25.12.2020.
//

import UIKit

class SubscriptionDetailVC: UIViewController {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var remainingRightsLabel: UILabel!
    @IBOutlet weak var packageStartEndDateLabel: UILabel!
    @IBOutlet weak var packageNameLabel: UILabel!
    
    @IBOutlet weak var switchView: UIView!
    @IBOutlet weak var cardDetailView: UIView!
    @IBOutlet weak var subscriptionDetailView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var packageNameTextField: UIView!
    @IBOutlet weak var startEndDateTextField: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var remainingRightsView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var packetNameLabel: UILabel!
    
    var packageID = ""
    var packetName = ""
    var startEndDate = ""
    var remainingRights = ""
    var currentDay = ""
    var currentMonth = ""
    var price = ""
    var selectedServiceID = ""
    
    var nameSurnameTextField = ""  
    var cardNumberTextField = ""
    var expirationMonthTextField = ""
    var expirationYearTextField = ""
    var CCVTextField = ""
    var startingTime = "" 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        print("selectedServiceID in subscription detail \(selectedServiceID)")
        print("starting time in subscription detail \(startingTime)")
    }

    func configureDate (){
        /// DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"

        /// Today Date
        let currentDate = Date()

        /// Add by Day
        let addDay = Int(startEndDate) // change to desired increased number

        /// DateComponents
        var dateComponent = DateComponents()
        dateComponent.day = addDay

        /// Get futrue Date
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)!

        /// Print result
        print("\(formatter.string(from: currentDate)) - \(formatter.string(from: futureDate))")
        

    }
    
    func setupLayouts(){
        configureView(view: packageNameTextField)
        configureView(view: startEndDateTextField)
        
        configureView(view: remainingRightsView)
        configureView(view: statusView)
        
        configureShadowtoView(view: switchView)
        configureShadowtoView(view: priceView)

        pricePayRoundedCorner(view: priceView)
        pricePayRoundedCorner(view: payView)
        pricePayRoundedCorner(view: payButton)

        switchView.layer.cornerRadius = 15
        cardDetailView.layer.cornerRadius = 15
        subscriptionDetailView.layer.cornerRadius = 15
        
        configureDate ()
        
        packageNameLabel.text = packetName
        remainingRightsLabel.text = remainingRights
        packetNameLabel.text = packetName
        priceLabel.text = "\(price)₺"
    }
    
    func configureShadowtoView(view: UIView){
        view.center = self.view.center
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 15
    }
    
    
    func pricePayRoundedCorner(view : UIView){
        view.layer.cornerRadius = 15
    }
    
    
    func configureView(view: UIView){
        view.layer.cornerRadius = 15
    }

    
    @IBAction func backButoonPressed(_ sender: UIButton) {

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
    
    @IBAction func cardDetailButtonPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CardDetailsVC") as! CardDetailsVC
        vc.startingTime = startingTime
        vc.selectedServiceID = selectedServiceID
        vc.packetName = packetName
        vc.packageID = packageID
        vc.remainingRights = remainingRights
        vc.price = price
        

        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    @IBAction func payButtonPressed(_ sender: UIButton) {
        if nameSurnameTextField != ""  && cardNumberTextField != "" && expirationMonthTextField != "" && expirationYearTextField != "" && CCVTextField != ""{
            buyPacket()
            //dismiss(animated: false, completion: nil)
        }else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
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
                        
//                        self.dismiss(animated: false, completion: nil)
                        
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
                print("Register Response = \(jsonError)")
            }
            
        }
        task.resume()
    }

    
   
   
}
