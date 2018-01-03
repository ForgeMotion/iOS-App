//
//  UtilityMethods.swift
//  Swing-Forge-Settings
//
//  Created by Julian Bryant on 1/10/16.
//  Copyright © 2016 TMConsult. All rights reserved.
//

import UIKit

class UtilityMethods: NSObject {
    class func showAlertInView(_ title:String, message:String, presentingViewController:UIViewController?){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        //self.presentViewController(alert, animated: true){}
        
        if let receivedViewController = presentingViewController {
            receivedViewController.present(alert, animated: false, completion: nil)
        } else {
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(alert, animated: true){}
        }
    }
}
