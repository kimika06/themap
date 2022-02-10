//
//  LocationTableViewCell.swift
//  OntheMap2
//
//  Created by Mac on 11/7/21.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
