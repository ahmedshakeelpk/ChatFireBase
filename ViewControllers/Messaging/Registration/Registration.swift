//
//  Registration.swift
//  Chat
//
//  Created by Apple on 10/05/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FlagPhoneNumber
import FirebaseDatabase

let defaults = UserDefaults.standard
var refFireBase = Database.database().reference()
//MARK:- Firebase DataBase
let PrivateChatDB = refFireBase.child("PrivateChat")
let GroupsDB = refFireBase.child("Groupss")
let MessagesDB = refFireBase.child("Messages")
let ChatDB = refFireBase.child("Chat")
let UserDB = refFireBase.child("Users")
let ParticipantsDB = refFireBase.child("Participants")

let PRIVATECHAT = "PRIVATECHAT"
let SOURCECODE = "IOS"
let TEXT = "TEXT"

class Registration: UIViewController {
    @IBOutlet weak var andicator: UIActivityIndicatorView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPhone: FPNTextField!
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnRegistration: UIButton!
    @IBAction func btnRegistration(_ sender: Any) {
    //Without verification
//        Auth.auth().createUser(withEmail: "abc@gmail.com", password: "123456", completion: {
//            (authResult, error) in
//        })
        
//        Auth.auth().signIn(withEmail: "abc@gmail.com", password: "123456", completion: {
//            (authResult, error) in
//            guard let userID = Auth.auth().currentUser?.uid else {
//                return }
//        UserDefaults.standard.setValue(userID, forKey: "uid")
//        })
        funSendPhoneAuth()
    }
    
    var phonenumber = String()
    var countryCode = String()
    var countryName = String()
    var GlobalFireBaseverficationID = String()

    
    override func viewDidLoad() {
        if defaults.value(forKey: "autologin") as? Bool ?? false {
            funPushToDashboard()
        }
        super.viewDidLoad()
        DispatchQueue.main.async{
            //MARK:- Defaults selected country
            self.txtPhone.setFlag(key: FPNOBJCCountryKey.PK)
        }
        // Do any additional setup after loading the view.
    }
    
    func funRegistration() {
        if txtUserName.text == "" {
            
        }
        else if txtPhone.text == "" {
            
        }
        else if txtEmail.text == "" {
            
        }
        else {
            funRegister()
        }
    }
    
    func funPushToDashboard() {
        let vc = UIStoryboard(name: "Messaging", bundle: nil).instantiateViewController(identifier: "Inbox") as! Inbox
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func funRegister() {
        guard let userID = Auth.auth().currentUser?.uid else {
            
            return }
        self.andicator.startAnimating()
        UserDB.child(userID).setValue([
            "username" : self.txtUserName.text! as String,
            "phone" : phonenumber,
            "email" : "\(self.txtEmail.text!)" as String,
            "fcmToken" : "",
            "uid":userID]
            
            as [String :Any],withCompletionBlock: {
                error, ref in
                self.andicator.stopAnimating()
                if error == nil {
                    ///// Save user Location
                    defaults.setValue(self.txtUserName.text!, forKey: "username")
                    defaults.setValue(self.phonenumber, forKey: "phone")
                    defaults.setValue(self.txtEmail.text!, forKey: "email")
                    defaults.setValue("", forKey: "fcmToken")
                    defaults.setValue(userID, forKey: "uid")
                    defaults.setValue(true, forKey: "autologin")
                    self.funPushToDashboard()
                }
                else
                {
                    showAlert(title: "Error", message: error.debugDescription, viewController: self)
                }
        })
    }

    
    func funSendPhoneAuth() {
        countryName = self.txtPhone.countryRepository.locale.regionCode ?? ""
        countryCode = self.txtPhone.selectedCountry!.phoneCode
        phonenumber = "\(txtPhone.selectedCountry!.phoneCode)\(txtPhone.text!)"
        phonenumber = phonenumber.replacingOccurrences(of: " ", with: "")
        phonenumber = phonenumber.replacingOccurrences(of: "+", with: "")
    //        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileInfo") as! ProfileInfo
//        vc.phonenumber = "\(self.  .text!)"
//        self.navigationController?.pushViewController(vc, animated: true)
//       return
        self.andicator.startAnimating()
        PhoneAuthProvider.provider().verifyPhoneNumber(("+"+phonenumber), uiDelegate: nil){ (verificationID, error) in
            self.andicator.stopAnimating()
            if error != nil {
                showAlert(title: "Alert!", message: (error?.localizedDescription)!, viewController: self)
                
                
                return
            }
            else{
                self.GlobalFireBaseverficationID = verificationID!
                self.showVerificationPassword()
            }
        }
    }
    
    func funConfirmPassword(code: String) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: GlobalFireBaseverficationID,
            verificationCode: code)
        self.andicator.startAnimating()
        Auth.auth().signIn(with: credential, completion: { (authResult, error) in
            self.andicator.stopAnimating()
            let currentUser = Auth.auth().currentUser
            if error != nil {
                
                showAlert(title: "Alert!", message: (error?.localizedDescription)!, viewController: self)
                return
            }
            else
            {
                self.funRegister()
            }
        })
    }
    
    func showVerificationPassword() {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Verification", message: "Enter Code", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Code Number"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            if textField?.text! != "" {
                self.funConfirmPassword(code: (textField?.text!)!)
            }
            else {
                self.showVerificationPassword()
            }
        }))
        DispatchQueue.main.async {
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
public func showAlert(title: String, message: String, viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default)
    { (action) in
        
    }
    alert.addAction(ok)
    viewController.present(alert, animated: true)
}
extension Date {
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension UIColor {
    static let clrStatusBar = UIColor(hexString: "008CC9")
    static let clrDashboardNavBar = UIColor(hexString: "E5E5EA")
    static let clrDashboardNavBarStatusBar = UIColor(hexString: "446190")
    static let clrLightBlue = UIColor(hexString: "009BDE")
    static let clrDarkBlue = UIColor(hexString: "174886")
    static let clrOrange = UIColor(hexString: "FFA900")
    static let clrLightBlueStatusBar = UIColor(hexString: "008CC9")
    static let clrLightGreen = UIColor(hexString: "36D9B2")
    static let clrLightGreenStatusBar = UIColor(hexString: "5BC5AB")
    static let clrGreen = UIColor(hexString: "00B899")
    static let clrBorderColorTextField = UIColor(hexString: "DADADA")
    static let clrPasswordWeak = UIColor(hexString: "cc7b7b")
    static let clrPasswordMedium = UIColor(hexString: "72c0ff")
    static let clrPasswordStrong = UIColor(hexString: "71c070")
    static let clrPasswordEmpty = UIColor(hexString: "b1b2b2")
    static let clrSelectedCellMessagesInbox = UIColor(hexString: "b1b2b2")
    static let clrMessageInboxSelected = UIColor(hexString: "009bde", alpha: 0.15)
    static let clrChatOutGoing = UIColor(hexString: "00B74A", alpha: 0.15)
    static let clrChatInComing = UIColor(hexString: "009bde", alpha: 0.15)
    static let clrSegmentNormalText = UIColor.white
    static let clrSegmentSelectedText = UIColor(hexString: "3BACE3")
    static let clrInsurenceCellUnSelected = UIColor(hexString: "E8E8E8")
    static let clrInsurenceCellUnSelectedTextColor = UIColor(hexString: "727272")

    convenience init(hexString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIView{
    func setBorderView() {
        self.layer.cornerRadius = CGFloat(8)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clrBorderColorTextField.cgColor
        self.clipsToBounds = true
    }
    func setBorderTextField() {
        self.layer.cornerRadius = CGFloat(8)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clrBorderColorTextField.cgColor
        self.clipsToBounds = true
    }
    
    func setRadiusView() {
        self.layer.cornerRadius = CGFloat(8)
    }
    func setRadiusViewChat() {
        self.layer.cornerRadius = CGFloat(8)
    }
    
    func setCircle() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    //MARK:- Corner Radius of only two side of UIViews
    func setRadiusRoundCorners(corners: UIRectCorner, radius: CGFloat){
        //DispatchQueue is used because if view not set his own layout before this function calling, this will create layout issue
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    
    
    /* Remove Loader */
    func removeLoader(viewController: UIViewController) {
        let child = viewController.children.last
        child?.willMove(toParent: nil)
        child?.view.removeFromSuperview()
        child?.removeFromParent()
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
extension UITableView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}
