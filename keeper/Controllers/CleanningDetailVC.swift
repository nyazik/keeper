//
//  CleanningDetailVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 26.12.2020.
//

import UIKit
import SDWebImage
import Cosmos
import Lottie


class CleanningDetailVC: UIViewController{
    
    @IBOutlet weak var commentRatingView: CosmosView!
    @IBOutlet weak var pointAvgLabel: UILabel!
    @IBOutlet weak var numbersOfCommentsLabel: UILabel!
    @IBOutlet weak var productDetailLabel: UILabel!
    @IBOutlet weak var quantityOfCommentsLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var serviceNameView: UIView!
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var serviseNameLabel: UILabel!
    @IBOutlet weak var serviseImageView: UIImageView!
    
    @IBOutlet weak var advantagesTableView: UITableView!
    @IBOutlet weak var commentTitleTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var advantagesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTableViewHeightConstraint: NSLayoutConstraint!
    
    var commentsArray = [ServiceDetailComment]()
    var advantagesArray = [String]()
    var servicesDropDownListArray: [String] = []
    var startTime = ""
    var selectedServiceID : String = ""
    var time = ""
    var commentRateValue: Double = 0.0
    
    private var animationBackView = UIView()
    private var animationView = AnimationView()

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        configureRatingView()
        setupLayouts()
        
        //CALL API
        getServiceDetails()
        
        //DELEGATES
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        advantagesTableView.dataSource = self
        advantagesTableView.delegate = self
        
        commentTextView.delegate = self
    }
    
    
    
    func configureRatingView(){
        commentRatingView.didFinishTouchingCosmos = { rating in
            print("pitchRateView = \(rating)")
            self.commentRateValue = rating
        }
        commentRatingView.settings.starSize = 25

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        addKeyboardObserver()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        advantagesTableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        self.advantagesTableView.reloadData()
        self.loadViewIfNeeded()
        advantagesTableViewHeightConstraint.constant = self.advantagesTableView.contentSize.height

        commentsTableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        self.commentsTableView.reloadData()
        self.loadViewIfNeeded()
        commentsTableViewHeightConstraint.constant = self.commentsTableView.contentSize.height
    }

    func setupLayouts(){
        mainImageView.layer.borderWidth = 2
        mainImageView.layer.borderColor = UIColor.lightText.cgColor
        configureImageView(view: mainImageView)
        configureImageView(view: commentView)
        configureImageView(view: serviceNameView)
        configureImageView(view: commentView)
        configureImageView(view: pointView)
        configureborderView(view: serviceNameView)
        configurePaddingView(textField: commentTitleTextField)
        configureTextView(textView: commentTextView)
    }
    
    func configureTextView(textView : UITextView){
        textView.layer.cornerRadius = 15
        textView.padding()
        textView.text = "Yorumunuz"
        textView.textColor = UIColor.lightGray
        
    }
    
    func configureImageView(view : UIView){
        view.layer.cornerRadius = 15
        
    }
    
    func configurePaddingView(textField: UITextField){
        textField.setLeftPaddingPoints(20)
        textField.setRightPaddingPoints(20)
        textField.layer.cornerRadius = 15
    }
    
    func configureborderView(view : UIView){
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "BuyPackageSubscribeVC") as! BuyPackageSubscribeVC
        vc.selectedServiceID = selectedServiceID
        vc.startingTime = time
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sendCommentButtonPressed(_ sender: UIButton) {
        if commentTitleTextField.text != "" &&  commentTextView.text != ""{
            sendComment()
            commentsArray.removeAll()
            getServiceDetails()
            commentTitleTextField.text = ""
            commentTextView.text = ""
        }else{
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //MARK:- NETWORKING
    func getServiceDetails() {
        
        self.addViewsForAnimation()
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "service/\(selectedServiceID)")
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
                
                let serviceDetailsResponse = try JSONDecoder().decode(ServicesDetailResponse.self, from: data)
                if serviceDetailsResponse.status{
                    DispatchQueue.main.async {
                        
                        self.advantagesArray = serviceDetailsResponse.data?.advantages! ?? []
                        self.commentsArray = serviceDetailsResponse.data?.comments! ?? []
                        self.serviseNameLabel.text = serviceDetailsResponse.data?.name
                        self.pointAvgLabel.text = String("\((serviceDetailsResponse.data?.comments_point_avg)!) Puan")
                        self.mainImageView.sd_setImage(with: URL(string: BaseURL.bannerBaseURL +  "\(serviceDetailsResponse.data?.banner ?? "iconAwesomeClock.png")"), completed: nil)
                        self.time = (serviceDetailsResponse.data?.aralik1)!
                        self.productDetailLabel.text  = serviceDetailsResponse.data?.details
                        self.serviseImageView.sd_setImage(with: URL(string: BaseURL.imageBaseURL + "\(serviceDetailsResponse.data?.image ?? "default.jpeg")"), completed: nil)
                        
                        self.commentsTableView.reloadData()
                        self.advantagesTableView.reloadData()
                        
                        self.commentsTableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
                        self.commentsTableView.reloadData()
                        self.commentsTableView.layoutIfNeeded()
                        self.commentsTableViewHeightConstraint.constant = self.commentsTableView.contentSize.height

                        self.advantagesTableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
                        self.advantagesTableView.reloadData()
                        self.advantagesTableView.layoutIfNeeded()
                        self.advantagesTableViewHeightConstraint.constant = self.advantagesTableView.contentSize.height
                        
                        
                        
                        self.removeViewsForAnimation()
                        
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.removeViewsForAnimation()
                        
                        let alert = UIAlertController(title: "Hata", message: serviceDetailsResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.removeViewsForAnimation()
                    print("Service Detail Response = \(jsonError)")
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatası", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
        task.resume()
    }

    func sendComment() {
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!

        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "service/\(selectedServiceID)/comment")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString =
            "title=\(commentTitleTextField.text!)&comment=\(commentTextView.text!)&point=\(commentRateValue)"
        
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
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: registerResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        self.commentsTableView.reloadData()
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

}

//MARK:- UITableViewDataSource, UITableViewDelegate

extension CleanningDetailVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == advantagesTableView {
            return advantagesArray.count
        }else{
            quantityOfCommentsLabel.text = "Yorumlar(\(commentsArray.count))"
            numbersOfCommentsLabel.text = "\(commentsArray.count) Yorum"
            return commentsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == advantagesTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdvantagesCell", for: indexPath) as! AdvantagesCell
            cell.advantagesImageView.image = #imageLiteral(resourceName: "iconFeatherCheckSquare")
            cell.advantagesTitleLabel.text = advantagesArray[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CleaningDetailCell
            cell.logoImageView.image = #imageLiteral(resourceName: "keeper_icon")
            cell.logoImageView.backgroundColor = UIColor(named: "pinkColor")
            cell.commentsDateLabel.text = commentsArray[indexPath.row].date
            cell.configurelogoImageView()
            cell.commentLabel.text = commentsArray[indexPath.row].text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == advantagesTableView{
            return 30
        }else{
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
   
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//
//    }
    
}

extension CleanningDetailVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            if textView.text == "" {
                textView.text = "Yorumunuz"
            }
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
             if textView.text == "Yorumunuz" {
                textView.text  = ""
            }
            textView.textColor = UIColor.lightGray
        
    }
}
