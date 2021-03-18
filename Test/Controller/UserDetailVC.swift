//
//  UserDetailVC.swift
//  Test
//
//  Created by Shruti Tyagi on 15/03/21.
//

import UIKit
import CoreData


class UserDetailVC: UIViewController , UITextViewDelegate{
    @IBOutlet weak var detailView : UIView!
    @IBOutlet weak var notesView : UIView!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var Username : UILabel!
    @IBOutlet weak var company : UILabel!
    @IBOutlet weak var blog : UILabel!
    @IBOutlet weak var follower : UILabel!
    @IBOutlet weak var following : UILabel!
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var user_img : UIImageView!
    var keyboardHeight: CGFloat = 0.0


    
    var user_name : String = String()
    var img_Url : String = String()
    var followerVal : Int64 = 0
    var userId : Int64 = 0

    var followeringVal : Int64 = 0
    var notes : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.text = "Add Note"
        textView.textColor = UIColor.lightGray

        notesView = self.methodForUIView(notesView)
        detailView = self.methodForUIView(detailView)
        methodToGetData()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetail")
        do {
            let f = try UserListCoreData.persistentContainer.viewContext.fetch(request)
          let  list = f as! [UserDetail]
            
            let filteredData = list.filter{ ($0.username!.contains(user_name)) }
            if filteredData.count > 0{
                    self.textView.text = filteredData[0].note!
                    if #available(iOS 13.0, *) {
                        if UITraitCollection.current.userInterfaceStyle == .dark {
                            textView.textColor = UIColor.white
                        } else {
                            textView.textColor = UIColor.black

                        }
                        }
            }
        } catch let error as NSError {
           // print("woe grabAllPersons \(error)")
        }
    }
    
    @IBAction func back_btn_clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func methodForUIView(_ view : UIView) -> UIView {
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.systemGray2.cgColor
        return  view
    }
   
    func methodToGetData()  {
        if Reachability.isConnectedToNetwork() {
     let session = URLSession.shared
            let urlStr = ConstantsFile.baseUrl + ConstantsFile.getUserDeatail
     let url = URL(string:  urlStr + user_name )!
     let task = session.dataTask(with: url) { [self] data, response, error in
     
         if error != nil {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Somethin went wrong.")
             return
         }
         do {
             let json = try JSONSerialization.jsonObject(with: data!, options: [])
          //   print(json)
            let userInfo : [String:Any] = (json as! [String:Any])
            DispatchQueue.main.async {
            self.name.text = "name: " + (userInfo["name"] as! String)
                self.Username.text = (userInfo["name"] as! String)
                self.company.text = "company: " + (userInfo["company"] as? String ?? "")
                self.blog.text = "blog: " + (userInfo["blog"] as! String)
                followeringVal = userInfo["following"] as! Int64
                followerVal = userInfo["followers"] as! Int64
                userId = userInfo["id"] as! Int64
                self.follower.text = "followers: " + String(followerVal)
                self.following.text = "following: " + String(followeringVal)
                img_Url = userInfo["avatar_url"] as! String
                let imageURL = URL(string: img_Url)
                    let imageData = try? Data(contentsOf: imageURL!)
                let image = UIImage(data: imageData!)
                user_img.image = image
                methodToStoreDataInDB() 
            }
         } catch {
         //    print("JSON error: \(error.localizedDescription)")
         }
     }
            task.resume()}else{
                grabAllUserList()
            }
 }
    func grabAllUserList() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetail")

        do {
            let f = try UserListCoreData.persistentContainer.viewContext.fetch(request)
          let  list = f as! [UserDetail]
            let filteredData = list.filter{ ($0.username!.contains(user_name)) }

            if filteredData.count > 0{
                    self.name.text = "name: " + filteredData[0].name!
                        self.Username.text = filteredData[0].name!
                        self.company.text = "company: " + filteredData[0].company!
                    self.blog.text = "blog: " + filteredData[0].blog!
                        
                    self.follower.text = "followers: " + String(filteredData[0].follower)
                        self.following.text = "following: " + String(filteredData[0].following)
                    self.textView.text = filteredData[0].note!
                        let image = UIImage(data: filteredData[0].imageurl!)
                        user_img.image = image

            }
           
        } catch let error as NSError {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Somethin went wrong.")
            
        }
        
        
    }
    func methodToStoreDataInDB()  {
        
            let userInfo = UserDetail(context: UserListCoreData.context)

        userInfo.name = Username.text!
       
            let imageURL = URL(string: img_Url)
        let imageData : Data = try! Data(contentsOf: imageURL!)
        
        userInfo.imageurl = imageData
        userInfo.follower = followerVal
        userInfo.blog = blog.text!
        userInfo.company = company.text!
        userInfo.following = followeringVal
        userInfo.username = user_name
        userInfo.note = textView.text!
        userInfo.userId = userId
        
        UserListCoreData.persistentContainer.loadPersistentStores { storeDescription, error in
            UserListCoreData.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            if let error = error {
            //    print("Unresolved error \(error)")
            }
        }
                    UserListCoreData.saveContext()
        
       
    }
    @IBAction func save_btn_clicked(_ sender: Any) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserDetail")

        do {
            let f = try UserListCoreData.persistentContainer.viewContext.fetch(request)
          let  list = f as! [UserDetail]
            
            let filteredlist = list.filter{ ($0.username!.contains(self.user_name)) }

            if filteredlist.count > 0{
            filteredlist[0].note = textView.text!
                    UserListCoreData.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

                    UserListCoreData.saveContext()
                    textView.resignFirstResponder()
                    Utility.showMessageDialog(onController: self, withTitle: "Message", withMessage: "Note has been added successfully.")
            
            }
           
        } catch let error as NSError {
           // print("woe grabAllPersons \(error)")
        }
        
        
    }
    
    
    // MARK:    ////////Methods to Set keyBoard////////
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    
    override func viewWillDisappear(_ animated: Bool) {
            NotificationCenter.default.removeObserver(self)
        }


     @objc func keyboardWillAppear(_ notification: NSNotification) {

        guard let userInfo = notification.userInfo else {return}

        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}

        let keyboardFrame = keyboardSize.cgRectValue
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardFrame.height
                }
            
        }

     @objc func keyboardWillDisappear(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}

        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}

        let keyboardFrame = keyboardSize.cgRectValue

                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y += keyboardFrame.height
                }
            
        }
    
    
    // MARK:   /////////////textview delegate methods///////////
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if(text == "\n") {

               textView.resignFirstResponder()
               return false
           }
           return true
       }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Note" {
            textView.text = nil
            if #available(iOS 13.0, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    textView.textColor = UIColor.white
                } else {
                    textView.textColor = UIColor.black

                }
                }}
        }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = UIColor.lightGray
        }
    }

}
