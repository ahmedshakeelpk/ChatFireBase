//
//  AllUsers.swift
//  Chat
//
//  Created by Apple on 10/05/2021.
//

import UIKit
import FirebaseDatabase

class AllUsers: UIViewController, UITextFieldDelegate, UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        userModel = searchText.isEmpty ? tempUserModel : userModel?.filter{(value) -> Bool in
            (value.username?.lowercased().contains((searchText.lowercased())))!
        }
        tablev.reloadData()
    }
    
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet weak var tablev: UITableView!
    @IBOutlet weak var andicator: UIActivityIndicatorView!

    var isSearch = false
    var tempUserModel = [UserModel]()
    var userModel: [UserModel]? {
        didSet {
            tablev.reloadData()
        }
    }
    override func viewDidLoad() {
        title = "Users"
        txtSearch.delegate = self
        tablev.tableFooterView = UIView()
        tablev.register(UINib(nibName: "AllUsersCell", bundle: nil), forCellReuseIdentifier: "AllUsersCell")
        fetchAllUsers()
       // txtSearch.delegate = self
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /////
    
    //////
    // MARK: - Fetch all chat users from server
    func fetchAllUsers()   {
        UserDB.queryOrderedByKey().observe(.value) { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                
                print(snapShot)
                //let datadic = snapShot as NSArray
                
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapShot {
                        self.tempUserModel.append(UserModel(snapShot: snap))
                    }
                    
                    self.userModel = self.tempUserModel
                }
                
                self.tablev.reloadData()
            }
        }
    }
    //MARK:- Search Section
    
   
}
extension AllUsers: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablev.dequeueReusableCell(withIdentifier: "AllUsersCell") as! AllUsersCell
        cell.userModel = userModel?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Messaging", bundle: nil).instantiateViewController(withIdentifier: "Chat") as! Chat
        vc.toUserUID = userModel?[indexPath.row].uid ?? ""
        vc.toUserPhoneNumber = userModel?[indexPath.row].phone ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AllUsers {
    struct UserModel {
        var username: String?
        var phone: String?
        var email: String?
        var fcmToken: String?
        var uid: String?
        var user_epass: String?
        
        init(snapShot: DataSnapshot) {
            if let data = snapShot.value as? [String:AnyObject] {
                username = (data as AnyObject).value(forKey: "username") as? String
                phone = (data as AnyObject).value(forKey: "phone") as? String
                email = (data as AnyObject).value(forKey: "email") as? String
                fcmToken = (data as AnyObject).value(forKey: "fcmToken") as? String
                uid = (data as AnyObject).value(forKey: "uid") as? String
            }
        }
    }
}


