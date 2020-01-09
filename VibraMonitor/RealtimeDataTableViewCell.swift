//
//  RealtimeDataTableViewCell.swift
//  VibraMonitor
//
//  Created by nguyen nhat minh phuong on 8/26/19.
//  Copyright © 2019 nguyen nhat minh phuong. All rights reserved.
//

import UIKit

class RealtimeDataTableViewCell: UITableViewCell {

    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
