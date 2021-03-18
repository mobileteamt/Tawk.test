//
//  ViewController.swift
//  Test
//
//  Created by Shruti Tyagi on 12/03/21.
//

import UIKit
import CoreData


class ListingVC: UIViewController,UISearchBarDelegate {
var array_userList: NSMutableArray = NSMutableArray()
    @IBOutlet weak var tableView : UITableView!
    var filteredUser : [UserList] = [UserList]()
    var filteredOffLineUser : [UserInfo] = [UserInfo]()

    var userListData : [UserList] = [UserList]()
    @IBOutlet weak var searchBar : UISearchBar!
    var searchActive : Bool = false
    var fromDB : String = String()

    var user_info : UserList?
    var isLoading: Bool = false
    var pageNo: NSNumber = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        methodToGetData()
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    func grabAllUserList() {
        fromDB = "YES"
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserInfo")

        do {
            let f = try UserListCoreData.persistentContainer.viewContext.fetch(request)
          let  list = f as! [UserInfo]
            for info in list {
                self.array_userList.add(info)
            }
            tableView.reloadData()
        } catch let error as NSError {
          //  print("woe grabAllPersons \(error)")
        }
        
        
    }
   
   func methodToGetData()  {
    if Reachability.isConnectedToNetwork() {
        Loader.shared.showProgressView(view: self.view)
    let session = URLSession.shared
        let urlStr = ConstantsFile.baseUrl + ConstantsFile.getList
    let url = URL(string: urlStr + String(describing: pageNo))!
    let task = session.dataTask(with: url) { [self] data, response, error in
        if error != nil {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Somethin went wrong.")
            return
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
           // print(json)
            let array  : [[String : Any]] =  (json  as! [[String : Any]])
            for item in array{
                let dict_item : [String : Any] = item 
                let userModal : UserList = UserList(dictUserInfo: dict_item as NSDictionary)
                self.array_userList.add(userModal)
            }
           
            userListData = self.array_userList as! [UserList]
             pageNo = (self.userListData.last?.str_userId)!
          //   print(pageNo)
            methodToStoreDataInDB()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                Loader.shared.hideProgressView()
            }        } catch {
          //  print("JSON error: \(error.localizedDescription)")
        }
    }
        task.resume()
        
    }else{
            grabAllUserList()

        }
}
    
    
    func methodToStoreDataInDB()  {
        for data in self.userListData{
            
            let userInfo = UserInfo(context: UserListCoreData.context)
            userInfo.username = data.str_username!
            userInfo.type = data.str_type!
            userInfo.userId = data.str_userId as! Int64
            let imageURL = URL(string: data.str_userImgurl!)
            let imageData  : Data = try! Data(contentsOf: imageURL!)
             userInfo.image_url = imageData
            
            
            UserListCoreData.persistentContainer.loadPersistentStores { storeDescription, error in
                UserListCoreData.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                if let error = error {
               //     print("Unresolved error \(error)")
                }
            }
            
            UserListCoreData.saveContext()
        }
    }

   
}


extension ListingVC : UITableViewDelegate, UITableViewDataSource{
    
    // MARK:   *********** SearchBar methods ***********
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           searchActive = true
       }

       func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
           searchActive = false
           searchBar.endEditing(true)
          tableView.reloadData()

       }

       func searchBarCancelButtonClicked(searchBar: UISearchBar) {
           searchBar.text = ""
           searchBar.resignFirstResponder()
           self.searchBar.showsCancelButton = false
           searchActive = false
           tableView.reloadData()
       }

       func searchBarSearchButtonClicked(searchBar: UISearchBar) {
           searchActive = false
            tableView.reloadData()
  
       }

       func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchActive = false
        tableView.reloadData()

                   return true
       }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if fromDB == "YES"{
            
            filteredOffLineUser = (array_userList as! [UserInfo]).filter { (userinfo : UserInfo) -> Bool in
              return userinfo.username!.lowercased().contains(searchText.lowercased())
            }
                
            }else{

        filteredUser = userListData.filter { (userinfo : UserList) -> Bool in
          return userinfo.str_username!.lowercased().contains(searchText.lowercased())
        }
            
        }
        if searchText.count == 0{
            searchActive = false
            searchBar.endEditing(true)
        }else{
            searchActive = true

        }
        tableView.reloadData()
        }
    
    // MARK:   ***********  TableView methods ***********
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchActive) {
            if fromDB == "YES"{
                return filteredOffLineUser.count
            }else{
            return filteredUser.count
            }  }else{
            return self.array_userList.count
        }
            
         
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        if indexPath.row % 4 != 0{
            let cell : ListCell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
           
                if (searchActive) {
                    cell.noteicon.isHidden = true
                    if fromDB == "YES" {
                        let obj_userInfo : UserInfo = filteredOffLineUser[indexPath.row]

                        cell.str_name.text =  obj_userInfo.username
                        
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                        
                        
                        let image = UIImage(data: obj_userInfo.image_url!)
                        cell.cat_img.image = image
                    }else{
                    let obj_userInfo : UserList = filteredUser[indexPath.row]

                    cell.str_name.text =  obj_userInfo.str_username
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.str_username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                    let imageURL = URL(string: obj_userInfo.str_userImgurl!)
                        let imageData = try? Data(contentsOf: imageURL!)
                    let image = UIImage(data: imageData!)
                            cell.cat_img.image = image
                
                    }
                    
                }else{
                    if fromDB == "YES" {
                        let obj_userInfo : UserInfo = array_userList[indexPath.row] as! UserInfo

                        cell.str_name.text =  obj_userInfo.username
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                     
                        let image = UIImage(data: obj_userInfo.image_url!)
                        cell.cat_img.image = image
                        }else{
                    let obj_userInfo : UserList = array_userList[indexPath.row] as! UserList

                    cell.str_name.text =  obj_userInfo.str_username
                            let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.str_username!)
                            if value == false{
                                cell.noteicon.isHidden = false
                            }else{
                                cell.noteicon.isHidden = true

                            }
                            
                    let imageURL = URL(string: obj_userInfo.str_userImgurl!)
                        let imageData = try? Data(contentsOf: imageURL!)
                    let image = UIImage(data: imageData!)
                            cell.cat_img.image = image
                    }
                    
                }
            cell.selectionStyle = .none
            return cell
        }else{
            let cell : InvertedListCell = tableView.dequeueReusableCell(withIdentifier: "InvertedListCell", for: indexPath) as! InvertedListCell
           
                if (searchActive) {
                    cell.noteicon.isHidden = true
                    if fromDB == "YES" {
                        let obj_userInfo : UserInfo = filteredOffLineUser[indexPath.row]

                        cell.str_name.text =  obj_userInfo.username
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                        let image = UIImage(data: obj_userInfo.image_url!)
                        cell.cat_img.image = image?.inverseImage(cgResult: true)
                    }else{
                     let obj_userInfo : UserList = filteredUser[indexPath.row]

                    cell.str_name.text =  obj_userInfo.str_username
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.str_username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                    let imageURL = URL(string: obj_userInfo.str_userImgurl!)
                        let imageData = try? Data(contentsOf: imageURL!)
                    let image = UIImage(data: imageData!)
                            cell.cat_img.image = image?.inverseImage(cgResult: true)
                
                    } }else{
                    if fromDB == "YES" {
                     
                        let obj_userInfo : UserInfo = array_userList[indexPath.row] as! UserInfo

                        cell.str_name.text =  obj_userInfo.username
                        let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.username!)
                        if value == false{
                            cell.noteicon.isHidden = false
                        }else{
                            cell.noteicon.isHidden = true

                        }
                      
                     
                        let image = UIImage(data: obj_userInfo.image_url!)
                        cell.cat_img.image = image?.inverseImage(cgResult: true)
                        }
                    else{
                    let obj_userInfo : UserList = array_userList[indexPath.row] as! UserList

                    cell.str_name.text =  obj_userInfo.str_username
                            let value = methodToIdentifyNoteAddedOrNot(obj_userInfo.str_username!)
                            if value == false{
                                cell.noteicon.isHidden = false
                            }else{
                                cell.noteicon.isHidden = true

                            }
                    let imageURL = URL(string: obj_userInfo.str_userImgurl!)
                        let imageData = try? Data(contentsOf: imageURL!)
                    let image = UIImage(data: imageData!)
                            cell.cat_img.image = image?.inverseImage(cgResult: true)
                    }
                    
                }
            cell.selectionStyle = .none
            return cell
        }
        
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rootVC: UserDetailVC = self.storyboard!.instantiateViewController(withIdentifier: "UserDetailVC") as! UserDetailVC
        if (searchActive) {
            if fromDB == "YES"{
                let obj_userInfo : UserInfo = filteredOffLineUser[indexPath.row]

                    rootVC.user_name = obj_userInfo.username!
                
            }else{
                        
                let obj_userInfo : UserList = filteredUser[indexPath.row]

                rootVC.user_name = obj_userInfo.str_username!}
              self.navigationController!.pushViewController(rootVC, animated: true)
        }else{
        if fromDB == "YES"{
            let obj_userInfo : UserInfo = array_userList[indexPath.row] as! UserInfo

                rootVC.user_name = obj_userInfo.username!}else{
                    
        let obj_userInfo : UserList = array_userList[indexPath.row] as! UserList

            rootVC.user_name = obj_userInfo.str_username!}
          self.navigationController!.pushViewController(rootVC, animated: true)
    }
    }
   
    
    // MARK:   *********** Pagination ***********
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if searchActive == false{
        if (tableView.contentOffset.y).rounded() >= (tableView.contentSize.height - tableView.frame.size.height).rounded() {
            if !isLoading {
                self.methodToGetData()
            }
        }
        }
        
    }
    
    
    // MARK:  *********** method to identify note added or not ***********
    func methodToIdentifyNoteAddedOrNot(_ user_name : String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetail")
        var result : Bool = true
        do {
            let f = try UserListCoreData.persistentContainer.viewContext.fetch(request)
          let  list = f as! [UserDetail]
            let filteredlist = list.filter{ !($0.note!.contains("Add Note")) }
            let filteredData = filteredlist.filter{ ($0.username!.contains(user_name)) }
           
            if filteredData.count == 0{
                result = true
            
            }else{
                result =  false
            }

            
            
        }catch let error as NSError {
              //  print("woe grabAllPersons \(error)")
            }
        return result
    }
   
}

class ListCell: UITableViewCell {
    @IBOutlet weak var str_name : UILabel!
    @IBOutlet weak var str_detail : UILabel!
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var noteicon : UIImageView!

    @IBOutlet weak var cat_img : UIImageView!
    
    override func awakeFromNib() {

        cat_img.layoutIfNeeded()
        cat_img.layer.cornerRadius = cat_img.frame.height / 2.0
        cat_img.layer.borderWidth = 1.0
        cat_img.layer.borderColor = UIColor.systemGray2.cgColor
        cat_img.layer.masksToBounds = true
        
        bgView.layer.borderWidth = 1.0
        bgView.layer.cornerRadius = 15.0
        bgView.layer.masksToBounds = true
        bgView.layer.borderColor = UIColor.systemGray2.cgColor
        
 
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
               noteicon.tintColor = UIColor.white                                            }
            else {
               noteicon.tintColor = UIColor.darkGray                                             }
        }
        noteicon.isHidden = true
       }
    
}

class InvertedListCell: UITableViewCell {
    @IBOutlet weak var str_name : UILabel!
    @IBOutlet weak var str_detail : UILabel!
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var noteicon : UIImageView!

    @IBOutlet weak var cat_img : UIImageView!
    
    override func awakeFromNib() {

        cat_img.layoutIfNeeded()
        cat_img.layer.cornerRadius = cat_img.frame.height / 2.0
        cat_img.layer.borderWidth = 1.0
        cat_img.layer.borderColor = UIColor.systemGray2.cgColor
        cat_img.layer.masksToBounds = true
        
        bgView.layer.borderWidth = 1.0
        bgView.layer.cornerRadius = 15.0
        bgView.layer.masksToBounds = true
        bgView.layer.borderColor = UIColor.systemGray2.cgColor
        
       
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                noteicon.tintColor = UIColor.white                                            }
            else {
                noteicon.tintColor = UIColor.darkGray                                             }
        }
        noteicon.isHidden = true
       }
    
}
extension UIImage {
func inverseImage(cgResult: Bool) -> UIImage? {
    let coreImage = UIKit.CIImage(image: self)
    guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
    filter.setValue(coreImage, forKey: kCIInputImageKey)
    guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
    if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
        return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)
    }
    return UIImage(ciImage: result)
  }
}
