//
//  Inbox.swift
//  Chat
//
//  Created by Apple on 08/05/2021.
//

import UIKit
import FirebaseDatabase

var UserPhoneNumber = defaults.value(forKey: "phone") as! String
var USERUID = defaults.value(forKey: "uid") as! String


class Inbox: UIViewController {
    @IBOutlet weak var andicator: UIActivityIndicatorView!

    @IBOutlet weak var tablev: UITableView!
    
    var chatModel = [Chat.ChatDBModel]() {
        didSet {
            tablev.reloadData()
        }
    }
    override func viewDidLoad() {
        setUIDesign()
        funSetting()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func setUIDesign() {
        self.title = UserPhoneNumber
        tablev.tableFooterView = UIView()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(funTappedAddUser))
    }
    func funSetting() {
        tablev.register(UINib(nibName: "InboxCell", bundle: nil), forCellReuseIdentifier: "InboxCell")
        funFetchChatFromServer()
    }
    //MARK:- Retreive Messages from db and add observer When This screen run first time
    func funFetchChatFromServer() {
        //MarK;- If user message and already in inbox
         ChatDB.child(USERUID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    if snapShot.count > 0 {
                        var tempModel = [Chat.ChatDBModel]()
                        for snap in snapShot {
                            tempModel.append(Chat.ChatDBModel(snapShot: snap))
                            self.receiveExistingUserMessage(userUID: snap.key)
                        }
                        self.chatModel = tempModel
                    }
                    else {
                        
                    }
                    //MARK:- This observer is use for if other use is typing or recording or send message then we will change the values of inbox
                }
                self.receiveNewUserMessages()
        })
    }
    
    //MARK:- New Message Receive when user alredy exist in inbox
    func receiveExistingUserMessage(userUID: String) {
        var totalCount = 0
        ChatDB.child(USERUID).child(userUID).observe(.value) { (snapshot) in
            totalCount += 1
            if totalCount >= self.chatModel.count { }
            else { return() }
            
            if let indexOf = self.chatModel.firstIndex(where: { $0.key == userUID}) {
                let tempObject = Chat.ChatDBModel(snapShot: snapshot)
                self.chatModel.remove(at: indexOf)
                self.chatModel.insert(tempObject, at: 0)
            }}
    }
    
    //MARK:- New Message Receive when the user is not in Inbox Screen
    func receiveNewUserMessages() {
        var totalCount = 0
        ChatDB.child(USERUID).observe(.childAdded) { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                totalCount += 1
                if totalCount > self.chatModel.count { }
                else { return() }
                if snapShot.count > 0 {
                    let tempObject = Chat.ChatDBModel(snapShot: snapshot)
                    self.chatModel.insert(tempObject, at: 0)
                    self.receiveExistingUserMessage(userUID: snapshot.key)
                }
            }
        }
    }
    
    @objc func funTappedAddUser() {
        let vc = UIStoryboard(name: "Messaging", bundle: nil).instantiateViewController(identifier: "AllUsers") as! AllUsers
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
 
extension Inbox: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablev.dequeueReusableCell(withIdentifier: "InboxCell") as! InboxCell
        cell.lblUserName.text = chatModel[indexPath.row].otherUserPhoneNumber
        cell.lblPhoneNumber.text = chatModel[indexPath.row].lastMessage 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Messaging", bundle: nil).instantiateViewController(identifier: "Chat") as! Chat
        vc.toUserUID = chatModel[indexPath.row].otherUserId
        vc.toUserPhoneNumber = chatModel[indexPath.row].otherUserPhoneNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
