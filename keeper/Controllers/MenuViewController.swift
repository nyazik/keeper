//
//  MenuViewController.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 30.12.2020.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        
        //CALLING API
        getUserProfile()
        
        let notificationCenter : NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.getUserProfile), name: .addedPhoto, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.getUserProfile), name: .userUpdated, object: nil)
    }
    
    func setupLayouts(){
//        upperView.roundCorners(corners: [.topRight], radius: 50)
//        lowerView.roundCorners(corners: [.bottomRight], radius: 50)
        roundView.layer.cornerRadius = roundView.frame.size.height / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        configureRoundView(view: roundView)
    }
    
    func configureRoundView(view: UIView){
        view.layer.cornerRadius = view.frame.size.height/2
        view.backgroundColor = UIColor(patternImage: UIImage(named:"gradient.png")!)
        
    }
    
    @IBAction func mySubscriptionsButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "MySubscriptionsVC") as! MySubscriptionsVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func goToMyProfile(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as!ProfileVC
        self.dismiss(animated: true) {
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    @IBAction func opportunityButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as!HomeVC
        self.dismiss(animated: true) {
            UIApplication.shared.windows.first?.rootViewController = vc
        }
    }
    
    @IBAction func subscribeButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "MySubscriptionsVC") as! MySubscriptionsVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)

    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FirstScreenVC") as!FirstScreenVC
        self.dismiss(animated: true) {
            UIApplication.shared.windows.first?.rootViewController = vc
        }
        
    }
    
    //MARK: -Networking
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
                        self.profileImageView.sd_setImage(with: URL(string: BaseURL.imageBaseURL + "\(userProfileResponse.data?.image ?? "default.jpeg")"), completed: nil)
                        self.profileNameLabel.text = userProfileResponse.data!.name!
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

}
