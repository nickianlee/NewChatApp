//
//  NameListViewController.swift
//
//
//  Created by nicholaslee on 07/04/2017.
//
//

import UIKit
import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTableView: UITableView!
    
    var ref: FIRDatabaseReference!
    
    var friends : [Friend] = []
    
    var lastId : Int = 201701
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        nameTableView.delegate = self
        
        nameTableView.dataSource = self
        
//        loadData()
        
        listenToFirebase()
      
        
    }
    
    func loadData() {
        
        ref.child("friend").observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot = " , snapshot)
            
            guard let value = snapshot.value as? NSDictionary
                
                else {return}
            
            // TO UTILISE WHEN THE ADD BUTTON IMPLEMENTED LATER ON //
            
            for (id, info) in value {
                if let friendInfo = info as? NSDictionary {
                    self.addFriendToArray(id: id, friendInfo: friendInfo)
                }
            }
            
            self.nameTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addFriendToArray(id : Any, friendInfo : NSDictionary) {
        if let phoneNumber = friendInfo["phoneNumber"] as? String,
            let name = friendInfo["name"] as? String,
            
            let friendId = id as? String,
            
            let currentFriendId = Int (friendId) {
            
            let newFriend = Friend(anId: currentFriendId, aName: name, aPhoneNumber: phoneNumber)
            self.friends.append(newFriend)
        }
    }
    
    func listenToFirebase () {
        
        ref.child("friend").observe(.childAdded, with: { (snapshot) in
            print("Added : ", snapshot)
            
            guard let info = snapshot.value as? NSDictionary
                else {return}
            
            self.addFriendToArray(id: snapshot.key, friendInfo: info)
            
            self.friends.sort(by: { (friend1, friend2) -> Bool in
                return friend1.id < friend2.id
            })
            
            if let lastFriend = self.friends.last {
                self.lastId = lastFriend.id
            }
            
            self.nameTableView.reloadData()
//            let index = IndexPath(item: self.friends.count - 1, section: 0)
//            self.nameTableView.insertRows(at: [index], with: .left)
            
        })
        ref.child("friend").observe(.childChanged, with: { (snapshot) in
            print("Changed : ", snapshot)
        })
        ref.child("friend").observe(.childMoved, with: { (snapshot) in
            print("Moved : ", snapshot)
        })
        ref.child("friend").observe(.childRemoved, with: { (snapshot) in
            print("Removed : ", snapshot)
            
            guard let deletedId = Int(snapshot.key)
                else {return}
            
            if let deletedIndex = self.friends.index(where: { std -> Bool in return std.id == deletedId
            })  {
                self.friends.remove(at: deletedIndex)
                let indexPath = IndexPath(row: deletedIndex, section: 0)
                self.nameTableView.deleteRows(at: [indexPath], with: .right)
            }
            
        })
    }
    
    
    @IBAction func logoutButtonTap(_ sender: Any) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            
            if let logInVC = storyboard?.instantiateViewController(withIdentifier: "AuthNavigationController") {
                
                present (logInVC, animated: true, completion: nil)
            }
            
        } catch let signOutError as NSError {
            print("Error signing out : %@", signOutError)
        }
        
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexpath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell") as? NameTableViewCell
            else { return UITableViewCell () }
        
        let currentFriend = friends[indexpath.row]
        cell.nameLabel.text = currentFriend.name
        
        
        cell.phoneNumberLabel.text = "\(currentFriend.phoneNumber)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentStoryboard = UIStoryboard(name: "Main",bundle: Bundle.main)
        if let targetViewController = currentStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            targetViewController.senderId = ""
            targetViewController.senderDisplayName = ""
            
//present(targetViewController, animated: true, completion: nil)
          navigationController?.pushViewController(targetViewController, animated: true)
//            targetViewController.hidesBottomBarWhenPushed = true
        }
    }
}

//extension ViewController: ChatViewControllerDelegate {
//    func didCancel() {
//        dismiss(animated: true, completion: nil)
//    }
//}
