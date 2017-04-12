//
//  LogInViewController.swift
//  NewChatApp
//
//  Created by nicholaslee on 11/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            
            print("Another User Already Logged In")
            
            self.directToMainNaviController()
        }
    }
    
    @IBAction func logInButtonTapped(_ sender: Any) {
    
        guard let email = emailTextField.text,
        let password = passwordTextField.text
            else {return}
        
        if email == "" || password == "" {
            
            print("User Input Error : Email or Password Cannot Be Empty")
            return
        }
    
        FIRAuth.auth()?.signIn(withEmail: email, password: password)
        {
            (user, error) in
            
            if let err = error {
                
                print("Sign In Error : \(err.localizedDescription)")
            }
            
            guard let user = user
                else {
                    
                    print("User Error")
                    return
            }
            
            print("User Succesfully Logged In")
            print("email : \(user.email)")
            print("uid : \(user.uid)")
            
            self.directToMainNaviController()
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        if let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") {
            
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    func directToMainNaviController () {
        
        if let mainNaviC = storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") {
            
            present(mainNaviC, animated: true, completion: nil)
        }
    }

}

