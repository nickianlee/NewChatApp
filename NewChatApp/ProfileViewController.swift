//
//  ProfileViewController.swift
//  NewChatApp
//
//  Created by nicholaslee on 12/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView()
        
        
        _tableView.frame = self.view.frame
        
        
        _tableView.register(ProfileCell.cellNib, forCellReuseIdentifier: ProfileCell.cellIdentifier)
        
        _tableView.dataSource = self
        _tableView.delegate = self
        
        _tableView.estimatedRowHeight = 82.0
        _tableView.rowHeight = UITableViewAutomaticDimension
        
        return _tableView
        
    }()
    
    var dummyArray :[[String:Any]] = [["name":"Nick"],
                                      ["name":"Sergio"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachTableView()
        // Do any additional setup after loading the view.
    }
    
    func attachTableView(){
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        
    }
}

extension ProfileViewController: UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCell.cellIdentifier) as?
            ProfileCell else { return UITableViewCell()}
        
        let dictionary = dummyArray[indexPath.row]
        
        
        let name = dictionary["name"] as? String
        cell.labelProfileName.text = name
        
        return cell
    }
    
}



