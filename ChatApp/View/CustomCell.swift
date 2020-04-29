//
//  CustomCell.swift
//  ChatApp
//
//  Created by 山本ののか on 2020/04/27.
//  Copyright © 2020 Nonoka Yamamoto. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
