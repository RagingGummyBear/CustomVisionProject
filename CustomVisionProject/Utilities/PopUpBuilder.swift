//
//  PopUpBuilder.swift
//  CustomVisionProject
//
//  Created by Seavus on 5/20/19.
//  Copyright © 2019 Seavus. All rights reserved.
//

import UIKit
import PopupDialog
import PromiseKit

class PopUpBuilder {
    func okSimplePopup(title:String, message: String) -> PopupDialog {
        let popup = PopupDialog(title: title, message: message)
        let okButton = DefaultButton(title: "OK", height: 45, dismissOnTap: true, action: nil)
        popup.addButton(okButton)
        return popup
    }
    
    func areYouSurePopup(title:String, message: String, action: @escaping PopupDialogButton.PopupDialogButtonAction) -> PopupDialog {
        let popup = PopupDialog(title: title, message: message)
        let yesButton = DestructiveButton(title: "Yes", height: 45, dismissOnTap: true, action: action)
        let cancelButton = CancelButton(title: "Cancel", height: 45, dismissOnTap: true, action: nil)
        popup.addButtons([yesButton, cancelButton])
        return popup
    }
    
    func likeThankPopup() -> PopupDialog {
        
        let title = "Thanks for the support!🤩🤩"
        let message = "Thank you for the feedback and support!😍😍"
        
        let thankButton = DefaultButton(title: "OK", height: 45, dismissOnTap: true, action: nil)
        
        let popup = PopupDialog(title: title, message: message)
        popup.addButton(thankButton)
        
        return popup
    }

}
