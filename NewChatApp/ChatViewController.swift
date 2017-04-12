//
//  ChatViewController.swift
//  TestChallenge
//
//  Created by nicholaslee on 07/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit
import Photos
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SwiftGifOrigin
import JSQMessagesViewController

//protocol ChatViewControllerDelegate {
//    func didCancel()
//}

class ChatViewController: JSQMessagesViewController {
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
//    var delegate: ChatViewControllerDelegate?
    var messages = [JSQMessage]()
    private var messageRef: FIRDatabaseReference!
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var usersTypingQuery: FIRDatabaseQuery?
    private lazy var userIsTypingRef: FIRDatabaseReference = self.messageRef.child("typingIndicator").child(self.senderId)
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://newchatapp-ee88e.appspot.com/")
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var updateMessageRefHandle: FIRDatabaseHandle?
    
  
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
        
        
        messageRef = FIRDatabase.database().reference().child("messages")
        usersTypingQuery = self.messageRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue:true)
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
        
        
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updateMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
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
    
    //adding photos
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem){
        messages.append(message)
            
            if(mediaItem.image == nil){
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    
    }
    
    
    //fetching photo
    private func fetchImageDataAtURL(_ photoURL: String , forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
    
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        storageRef.data(withMaxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            storageRef.metadata(completion: {(metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                if (metadata?.contentType == "image/gif") {
                
                    mediaItem.image = UIImage.gif(data: data!)   //  TODO and NEED's a CHECK!
                }else {
                
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else{
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        
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
                
            }else if let id = messageData["senderId"] as String!,       //to double check
                let photoURL = messageData["photoURL"] as String!{
                
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    
                    if photoURL.hasPrefix("gs://"){
                    
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
                
                self.updateMessageRefHandle = self.messageRef.observe(.childChanged, with: { (snapshot) in
                    let key = snapshot.key
                    let messageData = snapshot.value as? Dictionary<String, String> // 1
                    
                    if let photoURL = messageData?["photoURL"] as String? { // 2
                        // The photo has been updated.
                        if let mediaItem = self.photoMessageMap[key] { // 3
                            self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                        }
                    }
                })
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
    
    //MARK - setting photo storage / storage in general
    private let imageURLNotSetKey = "NOTSET"
    func sendPhotoMessage() -> String? {
        
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = ["photoURL": imageURLNotSetKey, "senderId": senderId,]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
        
    }
    
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String){
        
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
        
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
        if let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell {
            let message = messages[indexPath.item]
            
            if !message.isMediaMessage {
                if message.senderId == senderId {
                    cell.textView.textColor = UIColor.white
                }else {
                    cell.textView.textColor = UIColor.black
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
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
    
    
    //Mark imagePicker
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
}
// MARK - imagePicker delegate

extension ChatViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL{
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options:nil)
            let asset = assets.firstObject
            
            if let key = sendPhotoMessage(){
                
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    let path = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    self.storageRef.child(path).putFile(imageFileURL! , metadata: nil) { (metadata, error) in
                        
                        if let error = error {
                            
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        }else {
            
            let image  = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if let key = sendPhotoMessage(){
                
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                
                let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metada , error) in
                    if let error = error{
                        print("error uploading photo: \(error)")
                        return
                    }
                    self.setImageURL(self.storageRef.child((metadata.path)!).description, forPhotoMessageWithKey: key)
                }
                
            }
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion:nil)
        }
    }

}
