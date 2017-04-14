//
//  SignUpViewController.swift
//  NewChatApp
//
//  Created by nicholaslee on 11/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var ref : FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text,
        let password = passwordTextField.text,
        let confirmPassword = confirmPasswordTextField.text
            else {return}
        
        if email == "" || password == "" {
            
            print("Email Or Password Cannot Be Empty")
            return
        }
        
        if password != confirmPassword {
            
            print("Password Does Not Match")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password)
        {
            (user, error) in
            
            if let err = error {
                
                print("Sign Up Error : \(err.localizedDescription)")
                return
            }
            guard let user = user
                else {
                    
                print("User Not Found Error")
                    return
            }
            
            print("New User Created")
            print("Email : \(user.email)")
            print("uid : \(user.uid)")
            
            let dict : [String : Any] = ["Email" : "\(user.email)", "UID" : "\(user.uid)"]
            self.ref.child("friend").child(user.uid).setValue(dict)
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
            
           let _ = self.navigationController?.popViewController(animated: true)
    }
    
}

