import UIKit

class UserList: NSObject {
    
    var str_username : String?
    var str_userId : NSNumber?
    var str_userImgurl : String?
    var str_type : String?

    
    override init()
    {
        str_username = ""
        str_userId = 0
        str_userImgurl = ""
        str_type = ""

    }

    init(dictUserInfo: NSDictionary) {
        str_username = (dictUserInfo.value(forKey: "login") as! String)
        str_userId = (dictUserInfo.value(forKey: "id") as! NSNumber)
        str_type = (dictUserInfo.value(forKey: "type") as! String)
        str_userImgurl = (dictUserInfo.value(forKey: "avatar_url") as! String)
    }
}
