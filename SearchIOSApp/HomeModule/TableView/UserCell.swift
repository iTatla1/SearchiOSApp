//
//  UserCell.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    func configure(viewModel: CellViewModel) {
        nameLabel.text = viewModel.name
        typeLabel.text = viewModel.type
        userImage.kf.setImage(with: viewModel.avatar, placeholder: UIImage(named: ""), options: [
            .transition(.fade(1))
        ])
    }

}
