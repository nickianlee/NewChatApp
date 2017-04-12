//
//  ProfileCell.swift
//  
//
//  Created by nicholaslee on 12/04/2017.
//
//

import UIKit

class ProfileCell: UITableViewCell {

    static let cellIdentifier = "ProfileCell"
    static let cellNib = UINib(nibName: ProfileCell.cellIdentifier, bundle: Bundle.main)
    
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var labelProfileName: UILabel!
    
    @IBOutlet weak var labelProfileStatus: UILabel!
    
    @IBOutlet weak var labelProfilePhoneNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
