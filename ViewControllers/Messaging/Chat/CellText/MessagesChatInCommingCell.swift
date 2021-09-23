//
//  MessagesChatInCommingCell.swift
//  talkPHR
//
//  Created by Shakeel Ahmed on 4/7/21.
//

import UIKit

class MessagesChatInCommingCell: UITableViewCell {

    @IBOutlet weak var bgvBubbleColor: UIView!
    @IBOutlet weak var bgvTextMessage: UIView!
    @IBOutlet weak var bgvName: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!

    override func awakeFromNib() {
        bgvBubbleColor.backgroundColor = .clrChatInComing
        bgvName.backgroundColor = .clrChatInComing
        bgvName.setCircle()
        bgvBubbleColor.setRadiusViewChat()
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
