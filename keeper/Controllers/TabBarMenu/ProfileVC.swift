//
//  ProfileVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 25.12.2020.
//

import UIKit
import SideMenu
import SDWebImage
import Lottie

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameSurnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var tabbarMenuView: UIView!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var accountDetailVC = AccountDetailVC()
 
    private var animationBackView = UIView()
    private var animationView = AnimationView()
    
    var imagePicker = UIImagePickerController()
    var userDetailArray = [UserProfileDataResponse]()
    var accountDetailArray = ["Hesabım", "Aboneliklerim", "Adreslerim", "Şifre Değiştir", "Çıkış Yap"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter : NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.getUserProfile), name: .updateAccountDetail, object: nil)

        //CALLING API
        getUserProfile()
        setupLayouts()
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
    
    func setupLayouts(){
        configureNotificationTabbarShadow(view: tabbarMenuView)
        configureNotificationMainMenuButton(button: mainMenuButton)
        configureRoundView(view: roundView)
        configureAddButton()
        congifureProfileImage(view: profileImageView)
        setupSideMenu()
    }
    
    @objc func getUserProfile() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "user")
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
                
                let userProfileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
                
                if userProfileResponse.status{
                    DispatchQueue.main.async {
                        self.userDetailArray = [userProfileResponse.data!]
                        self.nameSurnameLabel.text = userProfileResponse.data?.name
                        self.emailLabel.text = userProfileResponse.data?.mail
                        self.profileImageView.sd_setImage(with: URL(string: BaseURL.imageBaseURL + "\(userProfileResponse.data?.image ?? "default.jpeg")"), completed: nil)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: userProfileResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                print("User Profile Response = \(jsonError)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! SideMenuNavigationController
        settingsSetupSlide()
        present(menu, animated: true, completion: nil)
    }

    @IBAction func tabbarNotificationButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "NotificationVC") as! NotificationVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func tabbarMainButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func addPhoto(imageView: UIImageView, param: [String:String]?) {
        
        addViewsForAnimation()
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "change-avatar")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        
        // Set HTTP Request Header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = imageView.image!.jpegData(compressionQuality: 0.2)
        
        if(imageData == nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "image", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        //myActivityIndicator.startAnimating();
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let data = data {
                
                let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                print(responseString!)
                
                if responseString!.contains("true") {
                    DispatchQueue.main.async {
                        
                        //self.dismiss(animated: true, completion: nil)
                        NotificationCenter.default.post(name: .addedPhoto, object: nil)
                        self.removeViewsForAnimation()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.removeViewsForAnimation()
                        
                        let alert = UIAlertController(title: "Hata", message: "Bilgileriniz güncellenirken bir hata oluştu. Lütfen tekrar deneyiniz.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            } else if let error = error {
                print(error)
                self.removeViewsForAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        task.resume()
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    @objc func goToCameraRoll(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                profileImageView.image = image
                //uploadToServer()
            addPhoto(imageView: profileImageView, param: nil)
        }
        
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
        settings.blurEffectStyle = .light
        settings.presentationStyle = .menuSlideIn
        settings.pushStyle = .preserveAndHideBackButton
        settings.statusBarEndAlpha = 0
        settings.presentationStyle.backgroundColor = .clear
        settings.presentationStyle.presentingEndAlpha = 0.7
        settings.presentationStyle.onTopShadowOpacity = 0.5
        settings.menuWidth = self.view.frame.width - self.view.frame.width * 0.3
        SideMenuManager.default.leftMenuNavigationController?.settings = settings
    }
    
    func congifureProfileImage(view : UIView){
        view.layer.cornerRadius = view.frame.size.height/2
    }
    
    func configureRoundView(view: UIView){
        view.layer.cornerRadius = view.frame.size.height/2
        view.backgroundColor = UIColor(patternImage: UIImage(named:"gradient.png")!)
        
    }
    
    func configureAddButton(){
        addPhotoButton.layer.cornerRadius = 15
    }
    
    func configureNotificationTabbarShadow(view: UIView){
        view.center = self.view.center
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 15
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
    }
    
    func configureNotificationMainMenuButton(button: UIButton){
        button.center = self.view.center
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 15
        button.layer.cornerRadius = mainMenuButton.frame.size.height / 2
    }
    
    
    func configureViewsShadow(newView:UIView){
        newView.center = self.view.center
        newView.layer.shadowColor = UIColor.lightGray.cgColor
        newView.layer.shadowOpacity = 0.3
        newView.layer.shadowOffset = CGSize.zero
        newView.layer.shadowRadius = 10
        newView.layer.cornerRadius = 15
        newView.backgroundColor = UIColor.white
    }
    
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AccountDetailCell
        cell.accountDetailNameLabel.text = accountDetailArray[indexPath.row]
        cell.configureViewsShadow()
        return  cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(identifier: "AccountDetailVC") as! AccountDetailVC
            vc.nameSurname = userDetailArray[indexPath.row].name!
            vc.email = userDetailArray[indexPath.row].mail!
            vc.phone = userDetailArray[indexPath.row].phone!
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }else if indexPath.row == 1{
            let vc = self.storyboard?.instantiateViewController(identifier: "MySubscriptionsVC") as! MySubscriptionsVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }else if indexPath.row == 2{
            let vc = self.storyboard?.instantiateViewController(identifier: "MyAddressesVC") as! MyAddressesVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }else if indexPath.row == 3{
            let vc = self.storyboard?.instantiateViewController(identifier: "ChangePasswordVC") as! ChangePasswordVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }else if indexPath.row == 4{
            let vc = self.storyboard?.instantiateViewController(identifier: "FirstScreenVC") as! FirstScreenVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
        tableView.reloadData()
    }
    
}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
    
}
