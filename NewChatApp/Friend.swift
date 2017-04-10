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
    var phoneNumber : Int16
    
    init () {
        
        id = 0
        name = ""
        phoneNumber = 0
        
    }
    init (anId : Int, aName : String, aPhoneNumber : Int16) {
        
        id = anId
        name = aName
        phoneNumber = aPhoneNumber
        
    }
}
