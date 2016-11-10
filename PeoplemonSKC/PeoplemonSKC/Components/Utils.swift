//
//  Utils.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import Foundation
import AFDateHelper

// Step 9: Create file and showError/isValidEmail functions
class Utils {
    
    var imageSet: UIImage?
    
    class func createAlert(title: String, message: String, dismissButtonTitle: String = "Dismiss") -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil))
        return alert
    }
    
    class func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9-_.]+[@]{1}[A-Za-z0-9-]+[.]*[A-Za-z0-9-]+[.]{1}[A-Za-z]+"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func adjustedTime(_ date: Date = Date()) -> Date {
        return date.dateByAddingSeconds(TimeZone.current.secondsFromGMT())
    }
    
    class func isNumber(_ string: String) -> Bool {
        let set = CharacterSet(charactersIn:"0123456789.-").inverted
        let components = string.components(separatedBy: set)
        let filtered = components.joined(separator: "")
        return string == filtered
    }
    
    class func formatNumber(_ amount: Double, prefix: String) -> String {
        return String(format: "\(prefix)$%.2f", abs(amount))
    }
    
    class func imageFromString(imageString: String?) -> UIImage? {
        if let imageString = imageString, let imageData = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters) {
            return UIImage(data: imageData as Data)
        }
        return UIImage(named: "question-mark")
    }
    
    class func stringFromImage(image: UIImage?) -> String {
        if let image = image, let imageData = UIImagePNGRepresentation(image) {
            return imageData.base64EncodedString()
        }
        return ""
    }
    
    class func resizeImage(image: UIImage, maxSize: CGFloat) -> UIImage {
        let newSize: CGSize!
        if image.size.width > image.size.height {
            newSize = CGSize(width: maxSize, height: maxSize * (image.size.height / image.size.width))
        } else {
            newSize = CGSize(width: maxSize * (image.size.width / image.size.height), height: maxSize)
        }
        
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context!.concatenate(flipVertical)
        context!.draw(image.cgImage!, in: newRect)
        let newImage = UIImage(cgImage: context!.makeImage()!)
        UIGraphicsEndImageContext()
        return newImage
    }
}
