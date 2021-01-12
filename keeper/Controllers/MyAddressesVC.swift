//
//  MyAddressesVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 29.12.2020.
//

import UIKit
import SideMenu


class MyAddressesVC: UIViewController {
    
    @IBOutlet weak var addressesTableView: UITableView!
    
    var addressesArray = [AddressDataResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupLayouts()
        
        addressesTableView.dataSource = self
        addressesTableView.delegate = self
        
        //CALLING API
        getAddress()
        
        let notificationCenter : NotificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.getAddress), name: .addAddress, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.getAddress), name: .editAddress, object: nil)
        
    }
    
    func setupLayouts(){
        addressesTableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addAddressButtonPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "AddAddressVC") as! AddAddressVC
        vc.isNewAddress = true
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    //MARK:- NETWORK
    @objc func getAddress() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "address")
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
                
                let addressResponse = try JSONDecoder().decode(AddressDetailResponse.self, from: data)
                
                if addressResponse.status{
                    DispatchQueue.main.async {
                        if addressResponse.data?.isEmpty == false {
                            self.addressesArray = addressResponse.data!
                            self.addressesTableView.reloadData()
                        } else {
                            print("data yok")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let alert = UIAlertController(title: "Hata", message: addressResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError{
                print("Get address Response = \(jsonError)")
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
    
    func deleteAddressed(id: String) {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "address/\(id)")
        
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"
        
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
                DispatchQueue.main.async {
                    if dataString.contains("true") {
                        print(dataString)
                    } else {
                        let alert = UIAlertController(title: "Hata", message: "Bir hata oluştu. Lütfen tekrar deneyiniz.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    
}

//MARK:- UITableViewDataSource, UITabBarDelegate
extension MyAddressesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressesCell
        print("cell for row at")
        cell.addressTitleLabel.text = addressesArray[indexPath.row].title
        cell.districtLabel.text = addressesArray[indexPath.row].ilce_adi
        cell.addressLabel.text = addressesArray[indexPath.row].details
        cell.configureCellView()
        cell.configuretabbarShadow()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let vc = self.storyboard?.instantiateViewController(identifier: "AddAddressVC") as! AddAddressVC
        
        vc.addressTitle = addressesArray[indexPath.row].title!
        vc.cityName  = addressesArray[indexPath.row].il_adi!
        vc.disctric = addressesArray[indexPath.row].ilce_adi!
        vc.address = addressesArray[indexPath.row].details!
        vc.addressID = addressesArray[indexPath.row].id!
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            deleteAddressed(id: self.addressesArray[indexPath.row].id!)
            self.addressesArray.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
}

