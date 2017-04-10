//
//  NameTableViewCell.swift
//  NewChatApp
//
//  Created by nicholaslee on 10/04/2017.
//  Copyright © 2017 nicholaslee. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var phoneNumberLabel: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
