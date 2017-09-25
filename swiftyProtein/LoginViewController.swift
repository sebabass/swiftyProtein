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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.layer.cornerRadius = 5
        connectButton.layer.borderWidth = 1
        let authenticationContext = LAContext()
        var error:NSError?
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            connectButton.isHidden = true
            //showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func LoginTouchID(_ sender: UIButton) {
        let authenticationContext = LAContext()
        var error:NSError?
        
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            connectButton.isHidden = true
            //showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
        }
        
        authenticationContext.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only awesome people are allowed",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    self.navigateToAuthenticatedViewController()
                }else {
                    if let error = error {
                        print(error)
                        //self.showAlertViewAfterEvaluatingPolicyWithMessage(message)
                    }
                }
                
        })
    }

    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        
        showAlertWithTitle(title: "Error", message: "This device does not have a TouchID sensor.")
        
    }
    
    func showAlertWithTitle( title:String, message:String ) {
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async { () -> Void in
            
            self.present(alertVC, animated: true, completion: nil)
            
        }

    }

    func navigateToAuthenticatedViewController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationView") as! UINavigationController
        self.present(nextViewController, animated:true, completion:nil)
    }
}

