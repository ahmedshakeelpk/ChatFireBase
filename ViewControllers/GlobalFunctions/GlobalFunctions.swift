//
//  GlobalFunctions.swift
//  Chat
//
//  Created by Apple on 12/05/2021.
//
import UIKit
import Foundation

//MARK:- Show Toast Like Android
func showToast(message : String, viewcontroller: UIViewController) {
    let toastLabel = UILabel()
    labelunlimitedtext(label: toastLabel)
    toastLabel.text = message
    toastLabel.sizeToFit()
    toastLabel.frame = CGRect(x: toastLabel.frame.origin.x, y: toastLabel.frame.origin.y, width: toastLabel.frame.size.width + 40, height: toastLabel.frame.size.height + 40)
    toastLabel.center = viewcontroller.view.center
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
    
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = toastLabel.frame.size.height / 2;
    toastLabel.clipsToBounds  =  true
    //viewcontroller.view.addSubview(toastLabel)
    UIView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseOut, animations: {
        toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
    UIApplication.shared.keyWindow!.addSubview(toastLabel)
}
//MARK:- Unlimited text to label
public func labelunlimitedtext(label :UILabel)
{
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 9
}
