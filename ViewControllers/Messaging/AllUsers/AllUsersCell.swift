//
//  AllUsersCell.swift
//  Chat
//
//  Created by Apple on 10/05/2021.
//

import UIKit
import FirebaseDatabase

class AllUsersCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    var userModel: AllUsers.UserModel! {
        didSet {
            lblUserName.text = userModel.username
            lblPhoneNumber.text = userModel.phone
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
