//
//  BluetoothListCell.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import UIKit

class BluetoothListCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
