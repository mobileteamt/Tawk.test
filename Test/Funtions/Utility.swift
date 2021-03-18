//
//  Utils.swift
//  App4Taxi
//
//  Created by MACMINI2 on 14/11/17.
//  Copyright © 2017 Udaan. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class Utility: NSObject {
    class func removeWhiteSpace(_ str:String) -> String {
        return str.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    class func isValidPassword(testStr:String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        let result = passwordTest.evaluate(with: testStr)
        return result
    }
    class func showMessageDialog( onController controller: UIViewController, withTitle title: String?,  withMessage message: String?, withError error: NSError? = nil, onClose closeAction: (() -> Void)? = nil) {
        var mesg: String?
        if let err = error {
            mesg = "\(String(describing: message))\n\n\(err.localizedDescription)"
            NSLog("Error: %@ (error=%@)", message!, (error ?? ""))
        } else {
            mesg = message
        }
        
        let alert = UIAlertController(title: title, message: mesg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
            if let action = closeAction {
                action()
            }
        })
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    class func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
}
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
