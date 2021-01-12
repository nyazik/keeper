//
//  HomeVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 23.12.2020.
//


import UIKit
import iOSDropDown
import SideMenu
import SDWebImage
import Lottie

class HomeVC: UIViewController, SideMenuNavigationControllerDelegate {
        
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var chooseDistrictDropDown: DropDown!
    @IBOutlet weak var servicesDropDown: DropDown!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tabbarMenuView: UIView!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var opportunityTableView: UITableView!
    @IBOutlet weak var servicesCollectionView: UICollectionView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    var citiesArray = [CityDataResponse]()
    var servicesArray = [ServicesProfileDataResponse]()
    var campaignsArray = [CampaingsDataResponse]()
    
    var serviceId = ""
    var citiesDropdownListArray: [String] = []
    var servicesDropDownListArray: [String] = []
    
    private var animationBackView = UIView()
    private var animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DELEGATES
        servicesCollectionView.dataSource = self
        opportunityTableView.delegate = self
        opportunityTableView.dataSource = self

        setupLayouts()
        
        //CALLING API
        getCities()
        getServices()
        getCampaigns()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        tableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        self.opportunityTableView.reloadData()
        self.loadViewIfNeeded()
        tableViewHeightConstraint.constant = self.opportunityTableView.contentSize.height
    }
    
    func setupLayouts() {
        setupSideMenu()
        configureView(view: redView)
        configureView(view: mainImageView)
        roundedDropDown()
        configureTabbarShadow(view: tabbarMenuView)
        configureServicesButtonShadow(button: mainMenuButton)
        opportunityTableView.layoutIfNeeded()
        configureDropDown()
        configureDropDown(dropDown: servicesDropDown)
        configureDropDown(dropDown: chooseDistrictDropDown)
        orderButton.layer.borderWidth = 2
        orderButton.layer.borderColor  = UIColor.white.cgColor
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
    
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! SideMenuNavigationController
        settingsSetupSlide()
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func homeButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        if chooseDistrictDropDown.text != "" && servicesDropDown.text != "" {
            let vc = self.storyboard?.instantiateViewController(identifier: "CleanningDetailVC") as! CleanningDetailVC
            vc.selectedServiceID = serviceId
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        } else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları seçiniz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func tabbarProfileButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func tabbarNotificationButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NotificationVC") as! NotificationVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func configureDropDown(dropDown: DropDown){
        dropDown.setLeftPaddingPoints(15)
    }
    
    func roundedDropDown(){
        chooseDistrictDropDown.layer.cornerRadius = 15
        servicesDropDown.layer.cornerRadius = 15
    }
    
    private func setupSideMenu() {
        // Define menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        settingsSetupSlide()
    }
    
    //menuDissolveIn
    func settingsSetupSlide() {
        
        // Enable gestures
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
        var settings = SideMenuSettings()
        //var settings2 = MenuViewController()
        settings.blurEffectStyle = .light
        settings.presentationStyle = .menuSlideIn
        settings.pushStyle = .preserveAndHideBackButton
        settings.statusBarEndAlpha = 0
//        settings.presentationStyle.backgroundColor = UIColor.blue
        settings.presentationStyle.presentingEndAlpha = 0.7
        settings.presentationStyle.onTopShadowOpacity = 0.5
        settings.menuWidth = self.view.frame.width - self.view.frame.width * 0.3
//        settings.presentationStyle.backgroundColor = UIColor.green
//        settings2.presentationStyle.backgroundColor = UIColor.green
        //settings2.presentationStyle.presentingEndAlpha = 0.0
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
//        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.clear
        SideMenuPresentationStyle.menuSlideIn.backgroundColor = UIColor.yellow
        
    }
    
    func configureDropDown(){
        servicesDropDown.optionArray = servicesDropDownListArray
        chooseDistrictDropDown.optionArray = citiesDropdownListArray
        
        //placeholder text
        servicesDropDown.placeholder = "Hizmetler"
        chooseDistrictDropDown.placeholder = "İl Seçiniz"
        
        //get service id
        servicesDropDown.didSelect { (text, index, _) in
            self.serviceId = self.servicesArray[index].id!
        }
        adjustDropDown(dropDown: servicesDropDown)
        adjustDropDown(dropDown: chooseDistrictDropDown)
    }
    
    func adjustDropDown(dropDown: DropDown){
        dropDown.selectedRowColor = UIColor(named: "pinkColor") ?? .black
        dropDown.listHeight = 150
        dropDown.rowHeight = 35
        dropDown.arrowColor = .darkGray
        dropDown.reloadInputViews()
    }
    
    func configureView(view: UIView){
        view.layer.cornerRadius = 15
    }
    
    func configureServicesButtonShadow(button: UIButton){
        button.center = self.view.center
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 15
        button.layer.cornerRadius  = button.frame.size.height / 2
    }
    
    func configureTabbarShadow(view: UIView){
        view.center = self.view.center
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 15
    }
    
    //MARK: - Networking
    func getCities() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "provinces")
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
            
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print(dataString)
//            }
            
            guard let data = data else {return}
            
            do{
                
                let citiesResponse = try JSONDecoder().decode(CityDetailResponse.self, from: data)
                
                if citiesResponse.status{
                    DispatchQueue.main.async {
                        if citiesResponse.data?.isEmpty == false {
                            self.citiesArray = citiesResponse.data!
                            
                            for item in self.citiesArray {
                                self.citiesDropdownListArray.append(item.il_adi!)
                            }
                            self.configureDropDown()
                            
                        } else {
                            print("data yok")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: citiesResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("Cities Response = \(jsonError)")
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    func getServices() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "services")
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
            
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print(dataString)
//            }
            
            guard let data = data else {return}
            
            do {
                
                let servicesResponse = try JSONDecoder().decode(ServicesProfileResponse.self, from: data)
                
                if servicesResponse.status{
                    DispatchQueue.main.async {
                        if servicesResponse.data?.isEmpty == false {
                            self.servicesArray = servicesResponse.data!
                            for item in self.servicesArray {
                                self.servicesDropDownListArray.append(item.name!)
                            }
                            self.configureDropDown()
                            self.servicesCollectionView.reloadData()
                        } else {
                            print("data yok")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let alert = UIAlertController(title: "Hata", message: servicesResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("Services Response = \(jsonError)")
                    
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        task.resume()
    }

    func getCampaigns() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        addViewsForAnimation()
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "campaigns")
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
            
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print(dataString)
//            }
            
            guard let data = data else {return}
            
            do{
                
                let campaignsResponse = try JSONDecoder().decode(CampaingsDetailResponse.self, from: data)
                
                if campaignsResponse.status{
                    DispatchQueue.main.async {
                        if campaignsResponse.data?.isEmpty == false {
                            self.campaignsArray = campaignsResponse.data!
                            //print("campaigns \(self.campaignsArray)")
                            
                            self.tableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
                            self.opportunityTableView.reloadData()
                            self.opportunityTableView.layoutIfNeeded()
                            self.tableViewHeightConstraint.constant = self.opportunityTableView.contentSize.height
                        } else {
                            print("data yok")
                        }
                        self.removeViewsForAnimation()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.removeViewsForAnimation()
                        let alert = UIAlertController(title: "Hata", message: campaignsResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                self.removeViewsForAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    print("Campaigns Response = \(jsonError)")
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



//MARK:- UITableViewDataSource, UITableViewDelegate
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaignsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TestCell
        cell.configureCell()
        cell.serviceTextLabel.text = campaignsArray[indexPath.row].title
        cell.servicesOppportunityLabel.text = campaignsArray[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    
}

//MARK:- UICollectionViewDataSource,
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return servicesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCell", for: indexPath)  as! ServicesCell
        cell.servicesImage.sd_setImage(with: URL(string: BaseURL.imageBaseURL + "\(servicesArray[indexPath.item].image ?? "default.jpeg")"), completed: nil)
        cell.configureView()
        cell.servicesLabel.text = servicesArray[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CleanningDetailVC") as! CleanningDetailVC
        vc.modalPresentationStyle = .fullScreen
        vc.selectedServiceID = servicesArray[indexPath.item].id!
        self.present(vc, animated: false, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: 90, height: 80)
    }
    
}

