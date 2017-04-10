//
//  Friend.swift
//  TestChallenge
//
//  Created by Stolen on 07/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class Friend {
    
    var id : Int
    var name : String
    var phoneNumber : String
    
    init () {
        
        id = 0
        name = ""
        phoneNumber = ""
        
    }
    init (anId : Int, aName : String, aPhoneNumber : String) {
        
        id = anId
        name = aName
        phoneNumber = aPhoneNumber
        
    }
}
