//
//  MySubscriptionsVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 25.12.2020.
//

import UIKit

class MySubscriptionsVC: UIViewController {
    
    @IBOutlet weak var subscriptionTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var ordersArray = [OrdersDataResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
        self.subscriptionTableView.reloadData()
        tableViewHeightConstraint.constant = self.subscriptionTableView.contentSize.height
        //CALLING API
        getOrders()
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }

    //MARK:- networking
    func getOrders() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "orders")
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
                
                let ordersResponse = try JSONDecoder().decode(OrdersDetailResponse.self, from: data)
                
                if ordersResponse.status!{
                    DispatchQueue.main.async {
                        if ordersResponse.data?.isEmpty == false {
                            
                            self.ordersArray = ordersResponse.data!
                            self.subscriptionTableView.reloadData()
                            
                            self.tableViewHeightConstraint.constant = CGFloat.greatestFiniteMagnitude
                            self.subscriptionTableView.reloadData()
                            self.subscriptionTableView.layoutIfNeeded()
                            self.tableViewHeightConstraint.constant = self.subscriptionTableView.contentSize.height

                        } else {
                            print("data yok")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: ordersResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError{
                print("Orders Response = \(jsonError)")
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

//MARK:- UITableViewDataSource, UITableViewDelegate
extension MySubscriptionsVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SubscriptionCell
        cell.configureCell()
        cell.configuretabbarShadow()
        cell.subscriptionLabel.text = ordersArray[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "SubscriptionInfoVC") as! SubscriptionInfoVC
        vc.subscriotionId = ordersArray[indexPath.row].id!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
}

