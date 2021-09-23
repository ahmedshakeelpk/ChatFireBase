//
//  InboxCell.swift
//  Chat
//
//  Created by Apple on 08/05/2021.
//

import UIKit

class InboxCell: UITableViewCell {

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
