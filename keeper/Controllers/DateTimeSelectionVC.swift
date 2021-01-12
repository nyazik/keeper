//
//  DateTimeSelectionVC.swift
//  keeper
//
//  Created by Wookweb Creative Agency on 27.12.2020.
//

import UIKit
import CVCalendar
import Lottie

class DateTimeSelectionVC: UIViewController {
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var customerNoteTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthNameLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var getServiceButton: UIButton!
    
    var date : Date?
    var selectedDate : Date?
    var finalDate = ""
    var time = true
    let screenBounds = UIScreen.main.bounds
    let x = 100
    var startingTime = ""
    var finalStartingTime: [String] = []
    var intFinalStartingTime = 0
    var resultTime : [Int] = []
    var packageID = ""
    var selectedTimeString = ""
    var selectedTimeInt = 0
    private var animationBackView = UIView()
    private var animationView = AnimationView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("***\(startingTime)")
        collectionView.delegate = self
        collectionView.dataSource = self
        addressTextView.delegate = self
        customerNoteTextView.delegate = self
        setupLayouts()
//        print("starting time = \(startingTime)")
        selectedStartingTime()
        print("***\(packageID)")
        hideKeyboardWhenTappedAround()
    }
    func selectedStartingTime(){
        let path = NSIndexPath(item: 0, section: 0)
//        print("path \(path)")
        collectionView.selectItem(at: path as IndexPath, animated: true, scrollPosition: .right)
    }
    
    func configureTime(){
        let divider = ":"
        finalStartingTime = startingTime.components(separatedBy: divider)
        print(finalStartingTime)
        intFinalStartingTime = Int(finalStartingTime[0])!
        print(intFinalStartingTime)
        for n in intFinalStartingTime...23{
            resultTime.append(n)
        }
    }
    
    func setupLayouts(){
        configureTime()
        addMonthNameLabel()
        customizeTextFields(textView: addressTextView)
        customizeTextFields(textView: customerNoteTextView)
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
        customizeGetServiceButton(button: getServiceButton)
    }
    
    
    
    
    func customizeGetServiceButton(button: UIButton){
        button.layer.cornerRadius = 15
    }
    
    func customizeTextFields(textView: UITextView){
        textView.layer.cornerRadius = 15
        textView.padding()
        if textView == addressTextView{
            //textView.text = "Adresinizi Giriniz"
        }else if textView == customerNoteTextView{
            //textView.text = "Notunuzu Yazınız."
        }
        textView.textColor = UIColor.lightGray
    }
    
    func addMonthNameLabel(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr")
        dateFormatter.dateFormat = "LLLL"
        let stringDate = dateFormatter.string(from: Date())
        monthNameLabel.text = stringDate
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func getServiceButtonPressed(_ sender: UIButton) {
        if customerNoteTextView.text != "" && addressTextView.text != "" {
            postOrder()
            print("success")
            let vc = self.storyboard?.instantiateViewController(identifier: "HomeVC") as! HomeVC
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        } else {
            let alert = UIAlertController(title: "Hata", message: "Lütfen gerekli alanları giriniz.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    //MARK: Networking
    func postOrder() {

        let accessToken = UserDefaults.standard.string(forKey: "Autherization")!

        addViewsForAnimation()
        
        // Prepare URL
        let url = URL(string: BaseURL.baseURL + "packet/\(packageID)")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString =
            "adres=\(addressTextView.text!)&not=\(customerNoteTextView.text!)&gun[\(finalDate)]=1&saat[\(finalDate)]]=\(selectedTimeString)"
        
        print("adres=\(addressTextView.text!)&not=\(customerNoteTextView.text!)&gun[\(finalDate)]=1&saat[\(finalDate)]]=\(selectedTimeString)")
        
        
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
                        
                        self.removeViewsForAnimation()
                        
                       
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
//                        self.removeViewsForAnimation()
                        
                        let alert = UIAlertController(title: "Hata", message: registerResponse.message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    self.removeViewsForAnimation()
                    
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

//MARK:- CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension DateTimeSelectionVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate{
    func presentationMode() -> CalendarMode {
        return .weekView
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
        print(indexPath)
    }
    
    func dayOfWeekFont() -> UIFont {
        return UIFont(name: "Poppins-Medium", size: 14)!
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return weekday == .sunday ? UIColor(named: "pinkColor")! : UIColor(named: "pinkColor")!
    }
    func shouldShowWeekdaysOut() -> Bool { return time }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor(named: "pinkColor")!]
    }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFont(ofSize: 14) }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return ColorsConfig.selectedText
        case (.sunday, .in, _): return ColorsConfig.sundayText
        case (.sunday, _, _): return ColorsConfig.sundayTextDisabled
        case (_, .in, _): return ColorsConfig.text
        default: return ColorsConfig.textDisabled
        }
    }
    
}


//MARK:- UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension DateTimeSelectionVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultTime.count
    }
    
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")! // Here use your time zone
        date = dayView.date.convertedDate(calendar: calendar)
        //print(date)
//        print("first\(date)")
        selectedDate = dateByAddingDays(inDays: 1)
        //print(selectedDate)
        //let dateFormatter = DateFormatter()
        //var date = dateFormatter.string(from: selectedDate)
        finalDate = changeDateFormatter()
        print(finalDate)
//      print(changeDateFormatter())
       }
    
    func changeDateFormatter() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        let finalDate = dateFormatter.string(from: date!)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var stringFromDate = dateFormatter.date(from: finalDate) ?? Date()
        var stringDate =  dateFormatter.string(from: stringFromDate)
        return stringDate
    }
    
    
    
    class func convertDateString(dateString : String!, fromFormat sourceFormat : String!, toFormat desFormat : String!) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = desFormat
        return dateFormatter.string(from: date!)
    }
    
    
    
    func dateByAddingDays(inDays: Int) -> Date {
        
        let today = Date()
        return Calendar.current.date(byAdding: .day, value: inDays, to: date!)!
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSelectionCell", for: indexPath) as! TimeSelectionCell
        cell.timeLabel.text = String("\(resultTime[indexPath.item]):00")
        cell.isSelected = false
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTimeInt = resultTime[indexPath.item]
        if selectedTimeInt <= 10{
            selectedTimeString = String("0\(resultTime[indexPath.item]):00")
        }else{
            selectedTimeString = String("\(resultTime[indexPath.item]):00")
        }
//            resultTime[indexPath.item]
        print(selectedTimeString)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: 60, height: 60)
    }
    
    
}

struct ColorsConfig {
    static let selectedText = UIColor.white
    static let text = UIColor.black
    static let textDisabled = UIColor.gray
    static let selectionBackground = UIColor(named: "pinkColor")
    static let sundayText = UIColor(named: "pinkColor")
    static let sundayTextDisabled = UIColor(named: "pinkColor")
    static let sundaySelectionBackground = sundayText
}

extension DateTimeSelectionVC  : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == addressTextView{
                textView.text = "Adresinizi Giriniz"
            }else if textView == customerNoteTextView{
                textView.text = "Notunuzu Yazınız."
            }
            textView.textColor = UIColor.lightGray
        }
    }
}
