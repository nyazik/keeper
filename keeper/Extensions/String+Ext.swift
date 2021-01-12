//
//  String+Ext.swift
//  Yapinta
//
//  Created by Wookweb Creative Agency on 10.10.2020.
//

import UIKit
import Foundation

extension String {
    
    func isValidEmail() -> Bool {
        //        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        //        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
        
    }
    
}
