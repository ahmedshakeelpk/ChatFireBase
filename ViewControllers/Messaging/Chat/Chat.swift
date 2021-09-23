//
//  Chat.swift
//  Chat
//
//  Created by Apple on 10/05/2021.
//

import UIKit
import GrowingTextView
import FirebaseDatabase

extension Chat: GrowingTextViewDelegate {
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type a message"
            textView.textColor = UIColor.lightGray
        }
    }
}
class Chat: UIViewController {
    @IBOutlet weak var andicator: UIActivityIndicatorView!
    @IBOutlet weak var tablev: UITableView!
    @IBOutlet weak var txtvBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var txtvMsg: GrowingTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBAction func btnSend(_ sender: Any) {
        messagetext = txtvMsg.text!
        txtvMsg.text = nil
        if chatGroupID == "" {
            funCreateNewChat(completion: {
                success in
                print("New Message Send")
            })
        }
        else {
            if messagetext != "" {
                self.sendMessage()
            }
        }
    }
    
    let objGroupsDBM = GroupsDBModel()
    let objMessageDBM = MessagesDBModel(snapShot: DataSnapshot())
    let objChatDBM = ChatDBModel(snapShot: DataSnapshot())
    var toUserUID = String()
    var toUserPhoneNumber = String()
    var fromUserUID = defaults.value(forKey: "uid") as! String
    var chatGroupID = String()
    var messagetext = String()
    var USERUniqueID = defaults.value(forKey: "phone") as! String
    var autocreatedid = String()
    var chatDBModel: [ChatDBModel]? {
        didSet {
            self.tablev.reloadData() {
                //self.funReceiveMessage()
                let indexPath = IndexPath(row: (self.chatDBModel?.count ?? 1) - 1, section: 0)
                self.scrolltobottom(indexpath: indexPath)
                self.andicator.stopAnimating()
            }
        }
    }
    
    var messagesDBModel: [MessagesDBModel]? {
        didSet {
            self.tablev.reloadData() {
                //self.funReceiveMessage()
                let indexPath = IndexPath(row: (self.messagesDBModel?.count ?? 1) - 1, section: 0)
                self.scrolltobottom(indexpath: indexPath)
                self.andicator.stopAnimating()
            }
        }
    }
    


    override func viewDidLoad() {
        setUIDesign()
        funSetting()
        super.viewDidLoad()
        
        
        
//        funCreateNewChat(completion: {
//            success in
//            
//        })
        // Do any additional setup after loading the view.
    }
    
    func setUIDesign() {
        self.title = toUserPhoneNumber
        tablev.tableFooterView = UIView()
        txtvMsg.text = "Type a message"
        txtvMsg.textColor = UIColor.lightGray
    }
    
    func funSetting() {
        tablev.register(UINib(nibName: "MessagesChatInCommingCell", bundle: nil), forCellReuseIdentifier: "MessagesChatInCommingCell")
        tablev.register(UINib(nibName: "MessagesChatOutGoingCell", bundle: nil), forCellReuseIdentifier: "MessagesChatOutGoingCell")
        txtvMsg.delegate = self
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        if chatGroupID == "" {
            retreivePrivateChatGroupId()
        }
        else {
            retreiveMessages()
        }
    }
    
    //Mark:- if you already have send any message to receiver then group id will find
    func retreivePrivateChatGroupId(){
        //Firebase Fetch Query
        //MARK:- How to get a single valuee by key and again in this node get another single value
        PrivateChatDB.child(fromUserUID)
            .child(toUserUID)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.childrenCount > 0 {
                    if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapShot {
                            self.andicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                            if let gid = snap.value as? String {
                                if self.chatGroupID == "" {
                                    self.chatGroupID = gid
                                    self.retreiveMessages()
                                    DispatchQueue.main.async {
                                        
//                                        self.funUserActivityStatus()
                                    }
                                }
                            }
                            break
                        }
                    }
                }
            })
    }
    
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            txtvBottomConstraints.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    func funCreateNewChat(completion: @escaping (_ key: String?) -> Void) {
        autocreatedid = MessagesDB.childByAutoId().key!
        let timespam = Date().currentTimeMillis()!
        var dicmsg = [String: Any]()
        let fromdic = [autocreatedid : [
            "\(objMessageDBM.fromUserId)":"\(fromUserUID)",
            "\(objMessageDBM.message)":messagetext,
            
            "\(objMessageDBM.messageType)":TEXT,
            "\(objMessageDBM.phoneNumber)":USERUniqueID,
            "\(objMessageDBM.timeStamp)": timespam,
            "\(objMessageDBM.source)":SOURCECODE]]
        
        let todic = [autocreatedid : [
            "\(objMessageDBM.fromUserId)":"\(fromUserUID)",
            "\(objMessageDBM.message)":messagetext,
            "\(objMessageDBM.messageType)":TEXT,
            "\(objMessageDBM.phoneNumber)":USERUniqueID,
            "\(objMessageDBM.timeStamp)": timespam,
            "\(objMessageDBM.source)":SOURCECODE]]
        
        dicmsg = [fromUserUID: fromdic, toUserUID: todic]
        
        //MARK:- Create new groupid and send message
        createNewPrivateChatGroupId(){ key in
            self.andicator.stopAnimating()
            guard let key = key else {
                showToast(message: "Error Occured try again!", viewcontroller: self)
                return }
            if self.chatGroupID == "" {
                showToast(message: key, viewcontroller: self)
            }
            else {
                MessagesDB.child(key)
                    .setValue(dicmsg, withCompletionBlock: { error, snapshot in
                        print(snapshot)
                        
                        if error != nil {
                            showToast(message: (error?.localizedDescription)!, viewcontroller: self)
                        }
                        else {
                            self.txtvMsg.text = ""
                            // obj.showToast(message: "Message send successfully.", viewcontroller: self)
                        }
                        completion("")
                    })
            }
        }
    }
    
    //MARK:- if you have send first message to receiver and no Private Chat Group Id Exist
    func createNewPrivateChatGroupId(completion: @escaping (_ key: String?) -> Void) {
        //MARK:- Add new group
        let timespam = Date().currentTimeMillis()!
        let dicGroup = [
            "\(objGroupsDBM.groupCreatedAt)" : timespam,
            "\(objGroupsDBM.groupCreatedBy)" : timespam,
            "\(objGroupsDBM.groupDescription)" : "",
            "\(objGroupsDBM.groupImage)" : "",
            "\(objGroupsDBM.groupName)" : "\(self.fromUserUID),\(self.toUserUID)",
            "\(objGroupsDBM.groupType)" : PRIVATECHAT,
            "\(objGroupsDBM.groupUpdated)" : timespam,
            "\(objGroupsDBM.source)":SOURCECODE] as [String : Any]
        
        GroupsDB.childByAutoId()
            .setValue(dicGroup ,withCompletionBlock: {
                error, snapshot in
                print(snapshot)
                if error != nil {
                    completion(error?.localizedDescription)
                }
                else {
                    //MARK:- From
                    let fromdic =  [self.toUserUID:
                        ["groupId": "\(String(describing: snapshot.key!))"]]
                    
                    let todic =  [self.fromUserUID:
                        ["groupId": "\(String(describing: snapshot.key!))"]]
                    
                    //MARK:- Add data in Private Chat with Group id
                    PrivateChatDB.child(self.fromUserUID)
                        .updateChildValues(fromdic,withCompletionBlock: {
                            error, ref in
                            if error != nil {
                                completion(error?.localizedDescription)
                            }
                            else {
                                PrivateChatDB.child(self.toUserUID)
                                    .updateChildValues(todic, withCompletionBlock: {
                                        
                                        error, ref in
                                        if error != nil {
                                            completion(error?.localizedDescription)
                                        }
                                        else {
                                            self.createChat(key: snapshot.key!, ifupdate: "0", completion: {
                                                response in
                                                if response != "success" {
                                                    completion(response)
                                                }
                                                else {
                                                    //MARK:- Observer on Gouped ID Messageses
                                                    if self.chatGroupID == "" {
                                                        //MARK:- From
                                                        self.chatGroupID = snapshot.key!
                                                        self.retreiveMessages()
//                                                        self.funUserActivityStatus()
                                                    }
                                                    completion(snapshot.key)
                                                }
                                            })
                                        }
                                    })
                            }})
                }
                //MARK:-v1- From and 2- To both
                //            self.PrivateChatDB.child(self.fromuid).child(self.touid).setValue(dicgroupId)
                //            self.PrivateChatDB.child(self.touid).child(self.fromuid).setValue(dicgroupId)
            })
    }
    
    func createChat(key: String,ifupdate: String, completion: @escaping (_ key: String?) -> Void) {
        
        let timespam = Date().currentTimeMillis()!

        let dicGroupFrom = [
                "\(objChatDBM.createdAt)" : timespam,
                "\(objChatDBM.groupType)" : PRIVATECHAT,
                "\(objChatDBM.lastMessage)" : self.messagetext,
                "\(objChatDBM.lastMessageId)" : self.autocreatedid,
                "\(objChatDBM.lastMessageTime)" : timespam,
                
                "\(objChatDBM.lastMessageUserId)" : self.fromUserUID,
                "\(objChatDBM.messageStatus)"  : "",
                "\(objChatDBM.otherUserId)" : self.toUserUID,
                "\(objChatDBM.userName)" : USERUniqueID,
                "\(objChatDBM.otherUserPhoneNumber)" : toUserPhoneNumber,
                "\(objChatDBM.source)":SOURCECODE] as [String : Any]
            let dicGroupTo = [
                "\(objChatDBM.createdAt)" : timespam,
                "\(objChatDBM.groupType)" : PRIVATECHAT,
                "\(objChatDBM.lastMessage)" : self.messagetext,
                "\(objChatDBM.lastMessageId)" : self.autocreatedid,
                "\(objChatDBM.lastMessageTime)" : timespam,
                "\(objChatDBM.lastMessageUserId)" : self.fromUserUID,
                "\(objChatDBM.messageStatus)" : "",
                "\(objChatDBM.otherUserId)" : self.fromUserUID,
                "\(objChatDBM.userName)" : USERUniqueID,
                "\(objChatDBM.otherUserPhoneNumber)" : USERUniqueID,
                "\(objChatDBM.source)":SOURCECODE] as [String : Any]
            
            ChatDB.child(self.fromUserUID)
                .child(key)
                .updateChildValues(dicGroupFrom, withCompletionBlock: {
                    error, snapshot in
                    if error != nil {
                        completion(error?.localizedDescription)
                    }
                    else {
                        ChatDB.child(self.toUserUID)
                            .child(key)
                            .updateChildValues(dicGroupTo)
                        completion("success")
                        DispatchQueue.main.async{
                            
                        }
                    }
                })
        
    }
    
    
    //MARK:- Function table view scroll to bottom
    func scrolltobottom(indexpath: IndexPath) {
        if indexpath.row < 0 {
            return
        }
        DispatchQueue.main.async {
            self.tablev.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0); //values
            self.tablev.scrollToRow(at: indexpath, at: .bottom, animated: true)
            DispatchQueue.main.async{
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    self.tablev.isHidden = false
                }
            }
        }
    }
    func retreiveMessages(){
        MessagesDB.child(chatGroupID)
        .child(fromUserUID)
            .queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                self.andicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    if snapShot.count > 0 {
                        //self.andicator.startAnimating()
                        print(snapShot)
                        //MARK:- WHEN I USE THIS DATADIC  sortting issue occur
                        let datadic = (snapshot.value as! NSDictionary).allValues as NSArray
                        if datadic.count > 0 {
                            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                                var tempMessagesDBModel = [MessagesDBModel]()
                                for snap in snapShot{
                                    if let _ = snap.value as? [String:AnyObject]{
                                        tempMessagesDBModel.append(MessagesDBModel(snapShot: snap))
                                    }
                                }
                                self.messagesDBModel = tempMessagesDBModel
                                // print(self.arrMsg)
                                self.funReceiveNewMessage()
                            }
                        }
                    }
                }
        })
    }
    
    func funReceiveNewMessage() {
        var tempcount = 0
        MessagesDB.child(chatGroupID)
            .child(fromUserUID)
            .observe(.childAdded) { (snapshot : DataSnapshot) in
                self.andicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                tempcount = tempcount + 1
                if tempcount > self.messagesDBModel?.count ?? 0 { }
                else { return() }
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    if snapShot.count > 0 {
                        self.messagesDBModel?.append(MessagesDBModel(snapShot: snapshot))
                    }
                }
        }
    }
    func sendMessage() {
        //andicator.startAnimating()
        autocreatedid = MessagesDB.childByAutoId().key!
        if chatGroupID.isEmpty == true {
            funCreateNewChat(completion: {
                response in
               
            })
            return()
        }
        else {
            //Message send
            let timespam = Date().currentTimeMillis()!
            //print(timespam)
            MessagesDB.child(self.chatGroupID).child(self.fromUserUID)
                .child(self.autocreatedid).setValue([
                "\(objMessageDBM.fromUserId)" :"\(self.fromUserUID)",
                "\(objMessageDBM.message)" :messagetext,
                "\(objMessageDBM.messageStatus)" :"",
                "\(objMessageDBM.messageType)" :TEXT,
                "\(objMessageDBM.phoneNumber)" : USERUniqueID,
                "\(objMessageDBM.timeStamp)" : timespam,
                "\(objMessageDBM.source)" :SOURCECODE], withCompletionBlock: {
                error, ref in
                    if error == nil {
                        MessagesDB.child(self.chatGroupID).child(self.toUserUID)
                            .child(self.autocreatedid).setValue([
                                                                    "\(self.objMessageDBM.fromUserId)" :"\(self.fromUserUID)",
                                                                    "\(self.objMessageDBM.message)" :self.messagetext,
                                                                    "\(self.objMessageDBM.messageStatus)" :"",
                                                                    "\(self.objMessageDBM.messageType)" :TEXT,
                                                                    "\(self.objMessageDBM.phoneNumber)" : self.USERUniqueID,
                                                                    "\(self.objMessageDBM.timeStamp)" : timespam,
                                                                    "\(self.objMessageDBM.source)" :SOURCECODE] as [String : Any], withCompletionBlock: {
                                error, ref in
                                self.andicator.stopAnimating()
                                if error == nil {
                                    // self.isdeliver(messageStatus: SENT)
                                    //MARK:- Uncomment the upper line for testing the unSeenCount
                                    //obj.showToast(message: "Message send successfully.", viewcontroller: self)
                                    
//                                    let parameters :Parameters = [
//                                        "title":"1 new message",
//                                        "body":self.messagetext,
//                                        "sound":"default",
//                                        //"groupId":self.groupId,
//                                        "groupType":self.groupType,
//                                        "messageId":ref.key!,
//                                        "action":"newMessage",
//                                        "messageType":msgtype,
//                                        "firebaseId":self.fromuid,
//                                        //"to":self.touid,
//                                        "groupFireBaseId":self.groupId,
//                                        "froma":USERUniqueID,
//                                        "profilePic":defaults.value(forKey: "userimage") as? String ?? "",
//                                        "message":self.messagetext,
//                                        "mutable_content": true] as [String: AnyObject]
                                    DispatchQueue.main.async{
                                       // obj.SendPushNotification(toToken: self.receivertokenLocalClass, title: "1 new message", body: self.messagetext, data: parameters )
                                    }
                                }
                        })

                    }
                })
            
            
            self.createChat(key: chatGroupID, ifupdate: "1", completion: {
                response in
                self.andicator.stopAnimating()
                if response == "success" {
                    
                }
                else {
                    //MARK:- From
                    showToast(message: response!, viewcontroller: self)
                }
            })
        }
    }
}





extension Chat: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDBModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messagesDBModel?[indexPath.row].fromUserId == fromUserUID {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessagesChatOutGoingCell.self)) as! MessagesChatOutGoingCell
            cell.lblMessage.text = messagesDBModel?[indexPath.row].message
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MessagesChatInCommingCell.self)) as! MessagesChatInCommingCell
//            cell.lblMessage.text = "A quick brown fox jumps over the lazy dog. A quick brown fox jumps over the lazy dog. A quick brown fox jumps over the lazy dog."
            cell.lblMessage.text = messagesDBModel?[indexPath.row].message
            return cell
        }
    }
}


