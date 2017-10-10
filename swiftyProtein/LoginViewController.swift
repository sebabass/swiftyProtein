//
//  LoginViewController.swift
//  swiftyProtein
//
//  Created by sebastien pariaud on 10/02/2017.
//  Copyright © 2017 sebastien pariaud. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var connectButton: UIButton!
    
    func alert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title  + " 😡", message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: buttonTitle, style: .default)
            {
                action in alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.layer.cornerRadius = 5
        connectButton.layer.borderWidth = 1
        let authenticationContext = LAContext()
        var error:NSError?
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            connectButton.isHidden = true
            self.alert(title: "No biometric sensor has been detected !", message: (error?.localizedDescription)!, buttonTitle: "Retry")
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func LoginTouchID(_ sender: UIButton) {
        let authenticationContext = LAContext()
        authenticationContext.localizedFallbackTitle = ""
        var error:NSError?
        
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.connectButton.isHidden = true
            self.alert(title: "No biometric sensor has been detected !", message: (error?.localizedDescription)!, buttonTitle: "Retry")
            return
        }
    
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only awesome people are allowed",
            reply: { [unowned self] (success, error) -> Void in
                DispatchQueue.main.async {
                    if( success ) {
                        self.navigateToAuthenticatedViewController()
                    }else {
                        if let error = error {
                            self.alert(title: "Wait !", message: (error.localizedDescription), buttonTitle: "Cancel")
                        }
                    }
                }
        })
    }

    func navigateToAuthenticatedViewController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationView") as! UINavigationController
        self.present(nextViewController, animated:true, completion:nil)
    }
}

