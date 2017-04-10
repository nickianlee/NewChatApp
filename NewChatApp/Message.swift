//
//  Message.swift
//  NewChatApp
//
//  Created by nicholaslee on 10/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import Foundation


class Message {

    var id: Int
    var text : String
    
    init() {
    
    id = 0
    text = ""
    
    
    }
    
    init (anId: Int, aText: String){
    
    id = anId
    text = aText
        
    }

}








