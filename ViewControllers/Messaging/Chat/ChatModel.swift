//
//  ChatModel.swift
//  Chat
//
//  Created by Apple on 12/05/2021.
//

import UIKit
import FirebaseDatabase

extension Chat {
    struct GroupsDBModel {
        let groupCreatedAt = "groupCreatedAt"
        let groupCreatedBy = "groupCreatedBy"
        let groupDescription = "groupDescription"
        let groupImage = "groupImage"
        let groupName = "groupName"
        let groupType = "groupType"
        let groupUpdated  = "groupUpdated"
        let source = "source"
    }
    
    struct ChatDBModel {
        var createdAt = "createdAt"
        var groupType = "groupType"
        var lastMessage = "lastMessage"
        var lastMessageId = "lastMessageId"
        var lastMessageStatus = "lastMessageStatus"
        var lastMessageTime = "lastMessageTime"
        var lastMessageType = "lastMessageType"
        var lastMessageUserId  = "lastMessageUserId"
        var messageStatus = "messageStatus"
        var otherUserId = "otherUserId"
        var otherUserPhoneNumber = "otherUserPhoneNumber"
        var typing = "typing"
        var userName = "userPhoneNumber"
        var unSeenCount = "unSeenCount"
        var source = "source"
        var key = "key"
        
        init(snapShot: DataSnapshot) {
            if let data = snapShot.value as? [String:AnyObject] {
                createdAt = (data as AnyObject).value(forKey: "createdAt") as? String ?? ""
                groupType = (data as AnyObject).value(forKey: "groupType") as? String ?? ""
                lastMessage = (data as AnyObject).value(forKey: "lastMessage") as? String ?? ""
                lastMessageId = (data as AnyObject).value(forKey: "lastMessageId") as? String ?? ""
                lastMessageStatus = (data as AnyObject).value(forKey: "lastMessageStatus") as? String ?? ""
                lastMessageTime = (data as AnyObject).value(forKey: "lastMessageTime") as? String ?? ""
                lastMessageType = (data as AnyObject).value(forKey: "lastMessageType") as? String ?? ""
                messageStatus = (data as AnyObject).value(forKey: "messageStatus") as? String ?? ""
                otherUserId = (data as AnyObject).value(forKey: "otherUserId") as? String ?? ""
                otherUserPhoneNumber = (data as AnyObject).value(forKey: "otherUserPhoneNumber") as? String ?? ""
                userName = (data as AnyObject).value(forKey: "userName") as? String ?? ""
                unSeenCount = (data as AnyObject).value(forKey: "unSeenCount") as? String ?? ""
                source = (data as AnyObject).value(forKey: "source") as? String ?? ""
                key = snapShot.key
            }
        }
    }

    struct MessagesDBModel {
        var fromUserId = "fromUserId"
        var imageThumb = "imageThumb"
        var message = "message"
        var messageImagePath = "messageImagePath"
        var messageStatus = "messageStatus"
        var messageType = "messageType"
        var phoneNumber  = "phoneNumber"
        var timeStamp = "timestamp"
        var messageVideoPath = "messageVideoPath"
        var source = "source"
        
        
        init(snapShot: DataSnapshot) {
            if let data = snapShot.value as? [String:AnyObject] {
                fromUserId = (data as AnyObject).value(forKey: "fromUserId") as? String ?? ""
                imageThumb = (data as AnyObject).value(forKey: "imageThumb") as? String ?? ""
                message = (data as AnyObject).value(forKey: "message") as? String ?? ""
                messageImagePath = (data as AnyObject).value(forKey: "messageImagePath") as? String ?? ""
                messageStatus = (data as AnyObject).value(forKey: "messageStatus") as? String ?? ""
                
                messageType = (data as AnyObject).value(forKey: "messageType") as? String ?? ""
                phoneNumber = (data as AnyObject).value(forKey: "phoneNumber") as? String ?? ""
                timeStamp = (data as AnyObject).value(forKey: "timeStamp") as? String ?? ""
                source = (data as AnyObject).value(forKey: "source") as? String ?? ""
            }
        }
    }
    
}
