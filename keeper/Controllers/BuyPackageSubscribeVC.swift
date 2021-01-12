//
//  BuyPackageSubscribeVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 24.12.2020.
//

import UIKit
import Lottie

class BuyPackageSubscribeVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var availablePackageArray = [PackagesDataBuyable]()
    var buyablePackageArray = [PackagesDataBuyable]()
    var connectedAvailableBuyablePackageArray = [PackagesDataBuyable]()
    var selectedServiceID : String = ""
    var startingTime = ""
    
    private var animationBackView = UIView()
    private var animationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter : NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.getPackage), name: .buyPackage, object: nil)
        
        
        print(startingTime)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //CALLING API
        getPackage()
    }
    
    override func viewDidLayoutSubviews() {
        collectionViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        self.collectionView.reloadData()
        collectionViewHeightConstraint.constant = self.collectionView.contentSize.height
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
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: - Networking
    @objc func getPackage() {
        addViewsForAnimation()
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "service/\(selectedServiceID)/packets")
        
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
                
                let packageResponse = try JSONDecoder().decode(GetServicePackages.self, from: data)
                if packageResponse.status{
                    DispatchQueue.main.async {
                        self.availablePackageArray = packageResponse.data!.available ?? []
                        self.buyablePackageArray = packageResponse.data!.buyable ?? []
                        self.connectedAvailableBuyablePackageArray = self.availablePackageArray + self.buyablePackageArray
                        self.collectionView.reloadData()
                        self.removeViewsForAnimation()
                        
                        
                        self.collectionViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
                        self.collectionView.reloadData()
                        self.collectionView.layoutIfNeeded()
                        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height

                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.removeViewsForAnimation()
                        let alert = UIAlertController(title: "Hata", message: packageResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                print("Packages Response = \(jsonError)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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


//MARK:- UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension BuyPackageSubscribeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BuyPackageCellDelegate{
    
    func didBuyButtonPressed(tag: Int) {
        print(tag)
        if connectedAvailableBuyablePackageArray[tag].available! == true{
            print(connectedAvailableBuyablePackageArray[tag].available!)
            let vc = self.storyboard?.instantiateViewController(identifier: "DateTimeSelectionVC") as! DateTimeSelectionVC
            vc.startingTime = startingTime
            vc.packageID = connectedAvailableBuyablePackageArray[tag].id!
//            vc.startingTime = connectedAvailableBuyablePackageArray[tag].
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }else{
            let vc = self.storyboard?.instantiateViewController(identifier: "CardDetailsVC") as! CardDetailsVC
            vc.selectedServiceID = selectedServiceID
            vc.packageID = connectedAvailableBuyablePackageArray[tag].id!
            vc.packetName = connectedAvailableBuyablePackageArray[tag].name!
            vc.startEndDate = connectedAvailableBuyablePackageArray[tag].day!
            vc.remainingRights =  connectedAvailableBuyablePackageArray[tag].amount!
            vc.price = connectedAvailableBuyablePackageArray[tag].price!
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connectedAvailableBuyablePackageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! BuyPackageCell
        cell.configureRadiusComponents()
        
        cell.delegate = self
        cell.buyPackageButton.tag = indexPath.item
        
        cell.packagePriceLabel.text = ("\(connectedAvailableBuyablePackageArray[indexPath.item].price!) ₺")
        cell.packageNameLabel.text = connectedAvailableBuyablePackageArray[indexPath.item].name
        cell.packageDescriptionLabel.text = connectedAvailableBuyablePackageArray[indexPath.item].details
        
        if connectedAvailableBuyablePackageArray[indexPath.item].available == true{
            cell.buyPackageButton.setTitle("Kullan", for: .normal)
        }else if connectedAvailableBuyablePackageArray[indexPath.item].available == false{
            cell.buyPackageButton.setTitle("Satin Al", for: .normal)
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        if connectedAvailableBuyablePackageArray[indexPath.item].available == true{
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        var width = (screenWidth-30)/2
        width = width > 190 ? 190 : width
        //print("\(width) \(screenWidth)")
        return CGSize.init(width: width, height: 200)
    }
    
}
