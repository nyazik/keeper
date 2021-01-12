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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        print("====\(selectedServiceID)")
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
    
    
    
    @IBAction func backButoonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func cardDetailButtonPressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CardDetailsVC") as! CardDetailsVC
        vc.selectedServiceID = selectedServiceID
        vc.packetName = packetName
        vc.remainingRights = remainingRights
        vc.price = price
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }

    
    func configureView(view: UIView){
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
    
    
    func pricePayRoundedCorner(view : UIView){
        view.layer.cornerRadius = 15
    }
    
   
   
}
