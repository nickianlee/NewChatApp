//
//  ChatViewController.swift
//  TestChallenge
//
//  Created by nicholaslee on 07/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import JSQMessagesViewController



//var friendName: Friend?{
//didSet{
//    title = friendName?.name
//}
//}



class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    private var messageRef: FIRDatabaseReference!
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var usersTypingQuery: FIRDatabaseQuery?
    private lazy var userIsTypingRef: FIRDatabaseReference = self.messageRef.child("typingIndicator").child(self.senderId)
    private var localTyping = false
    var isTyping: Bool{
        get{
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.senderId = FIRAuth.currentUser?.uid
        messageRef = FIRDatabase.database().reference().child("messages")
        usersTypingQuery = self.messageRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue:true)
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
        
    }
    
    //MARK private func
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage{
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
    }
    
    private func addMessage(withId id: String, name:String, text: String){
        if let message = JSQMessage(senderId: id, displayName: name, text: text){
            messages.append(message)
        }
    }
    
    private func observeMessages(){
        
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: {(snapshot) -> Void in
            
            let messageInfo = snapshot.value as! Dictionary<String, Any>
            guard let messageData = messageInfo as? [String:String] else {
                return
            }
            
            if let id = messageData["senderId"] as String!,
                let name = messageData["senderName"] as String!,
                let text = messageData["text"] as String!, text.characters.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                
                self.finishReceivingMessage()
                
            }else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    private func observeTyping() {
        
        let typingIndicatorRef = messageRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        
        usersTypingQuery?.observe(.value) { (data:FIRDataSnapshot) in
            if data.childrenCount == 1 && self.isTyping{
                return
            }
        
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
            
        }
    }
    
    
    //MARK override func
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath:IndexPath!) -> JSQMessageData!{
        return messages[indexPath.item]
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ coolectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId{
            return outgoingBubbleImageView
        }else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.white
            
        }else {
            cell.textView.textColor = UIColor.black
        }
        return cell
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        isTyping = false
    }
    
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
