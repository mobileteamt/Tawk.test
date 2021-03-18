//
//  File.swift
//  Keeperies
//
//  Created by Shruti Tyagi on 21/05/19.
//

import Foundation
import UIKit

public typealias Parameter = [String:Any]


let indicatorViewTag = 10001
let errorToastViewTag = 10002

struct ConstantsFile
{
    static let appVersion =  Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    static let getList =  "users?since="
    static let getUserDeatail =  "users/"
   


     /// new base url
    static let baseUrl:String = "https://api.github.com/"
    
}
