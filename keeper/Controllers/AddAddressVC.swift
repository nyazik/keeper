//
//  AddAddressVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 30.12.2020.
//

import UIKit
import iOSDropDown

class AddAddressVC: UIViewController {
    
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var addressTitleTextField: UITextField!
    @IBOutlet weak var cityDropDown: DropDown!
    @IBOutlet weak var districtDropDown: DropDown!
    @IBOutlet weak var addressTextField: UITextField!
    
    var citiesArray = [CityDataResponse]()
    var districtsArray = [AddressDataResponse]()
    
    var citiesDropdownListArray: [String] = []
    var districtsDropdownListArray: [String] = []
    var cityId = ""
    var districtId = ""
    var isNewAddress: Bool = false
    
    var addressTitle = ""
    var cityName = ""
    var disctric = ""
    var address = ""
    var addressID = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hideKeyboardWhenTappedAround()
        setupLayouts()
        
        if isNewAddress == true {
            addAddressButton.setTitle("Adres Ekle", for: .normal)
            if cityDropDown.isSelected{
                addressTitleTextField.resignFirstResponder()
                cityDropDown.becomeFirstResponder()
                districtDropDown.isEnabled = true
                
            }
        }else {
            districtDropDown.isEnabled = true
            addAddressButton.setTitle("Güncelle", for: .normal)
        }
        
        //CALLING API
        getCities()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    func setupLayouts() {
        districtDropDown.isEnabled = false
        configureTextField(textField: addressTitleTextField)
        configureTextField(textField: addressTextField)
        configureDropDown(dropDown: cityDropDown)
        configureDropDown(dropDown: districtDropDown)
        
        if isNewAddress == false {
            addressTitleTextField.text = addressTitle
            cityDropDown.text = cityName
            districtDropDown.text = disctric
            addressTextField.text = address
        }
        
        
    }
    
    func configureDropDown(dropDown: DropDown) {
        dropDown.layer.cornerRadius = 15
        dropDown.setLeftPaddingPoints(20)
        dropDown.font = UIFont(name: "Poppins-Regular", size: 16)
        dropDown.textColor = UIColor.darkGray
        dropDown.cornerRadius = 10
        dropDown.selectedRowColor = UIColor(named: "pinkColor") ?? .black
        dropDown.listHeight = 150
        dropDown.rowHeight = 35
        dropDown.arrowColor = .darkGray
        
        if dropDown == cityDropDown {
            dropDown.placeholder = "Şehir Seçiniz"
        } else if dropDown == districtDropDown {
            dropDown.placeholder = "İlçe Seçiniz"
        }
    }
    
    func configureTextField(textField: UITextField) {
        textField.layer.cornerRadius = 15
        textField.setRightPaddingPoints(20)
        textField.setLeftPaddingPoints(20)
    }
    
    @IBAction func addAddressButtonPressed(_ sender: UIButton) {
        if addressTitleTextField.text != "" && cityDropDown.text != "" && districtDropDown.text != "" && addressTextField.text != "" {
            
            
            if isNewAddress == true {
                self.addAddress()
            }else {
                districtDropDown.isEnabled = true
                self.changeAddress()
            }
            
        } else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları doldurunuz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    func fetchDataDropDown() {
        for city in citiesArray {
            cityDropDown.optionArray.append(city.il_adi!)
        }
        for city in districtsArray {
            districtDropDown.optionArray.append(city.ilce_adi!)
        }
        
        districtDropDown.didSelect { (text, index, _) in
            print("District -> Text = \(text) - Index = \(index) - Id = \(self.districtsArray[index].id!)")
            self.districtId = self.districtsArray[index].id!
            
        }
        
        cityDropDown.didSelect { (text, index, _) in
            print("City -> Text = \(text) - Index = \(index) - Id = \(self.citiesArray[index].id!)")
            self.cityId = self.citiesArray[index].id!
            self.districtDropDown.isEnabled = true
        }
        
        if isNewAddress == false {
            let selectedCityIndex = citiesArray.firstIndex{ $0.il_adi == cityName }
            cityDropDown.selectedIndex = selectedCityIndex
            print("city index = \(cityDropDown.selectedIndex)")
            self.cityId = self.citiesArray[cityDropDown.selectedIndex!].id!
            
            let selectedDistrictIndex = districtsArray.firstIndex{ $0.ilce_adi == disctric }
            districtDropDown.selectedIndex = selectedDistrictIndex
            print("disctric index = \(districtDropDown.selectedIndex)")
            self.districtId = self.districtsArray[districtDropDown.selectedIndex!].id!
        }
        
        
    }
    
    //MARK: -NETWORKING
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
            
            //if let data = data, let dataString = String(data: data, encoding: .utf8) {
            //    print(dataString)
            //}
            
            guard let data = data else {return}
            
            do{
                
                let citiesResponse = try JSONDecoder().decode(CityDetailResponse.self, from: data)
                
                if citiesResponse.status{
                    DispatchQueue.main.async {
                        if citiesResponse.data?.isEmpty == false {
                            
                            self.citiesArray = citiesResponse.data!
                            self.getDistricts()
                            
                        } else {
                            print("Data not found!")
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
                
            } catch let jsonError{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
    
    func getDistricts() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "province/\(40)")
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
                
                let districtResponse = try JSONDecoder().decode(AddressDetailResponse.self, from: data)
                
                if districtResponse.status{
                    DispatchQueue.main.async {
                        if districtResponse.data?.isEmpty == false {
                            
                            self.districtsArray = districtResponse.data!
                            self.fetchDataDropDown()
                            
                        } else {
                            print("Data not found!")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let alert = UIAlertController(title: "Hata", message: districtResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
    
    func addAddress() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "add-address")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // Set HTTP Request Header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString =
            "title=\(addressTitleTextField.text!)&province_id=\(cityId)&district_id=\(districtId)&details=\(addressTextField.text!)"
        
        print("title=\(addressTitleTextField.text!)&province_id=\(cityId)&district_id=\(districtId)&details=\(addressTextField.text!)")
        
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
                
                let addAddressResponse = try JSONDecoder().decode(PostMessageResponse.self, from: data)
                
                if addAddressResponse.status{
                    DispatchQueue.main.async {
                        
                        NotificationCenter.default.post(name: .addAddress, object: nil)

                        
                        self.dismiss(animated: false, completion: nil)
                    }
                    
                } else {
                    print(addAddressResponse.status)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let alert = UIAlertController(title: "Hata", message: addAddressResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Add Address Response \(jsonError)")
                    let alert = UIAlertController(title: "Hata", message: "Sunucu Hatasi", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
    
    func changeAddress() {
        
        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "address/\(addressID)")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "title=\(addressTitleTextField.text!)&province_id=\(cityId)&district_id=\(districtId)&details=\(addressTextField.text!)"
        
        print("title=\(addressTitleTextField.text!)&province_id=\(cityId)&district_id=\(districtId)&details=\(addressTextField.text!)")
        
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        // Set HTTP Request Header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Set HTTP Request URL Encoded
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
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
                
                let loginResponse = try JSONDecoder().decode(PostMessageResponse.self, from: data)
                
                if loginResponse.status{
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .editAddress, object: nil)

                        
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let alert = UIAlertController(title: "Hata", message: loginResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }catch let jsonError {
                print("Change Password Response = \(jsonError)")
            }
            
        }
        task.resume()
    }
    
}


