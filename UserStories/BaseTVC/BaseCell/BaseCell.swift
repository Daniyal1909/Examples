//
//  BaseCell.swift
//  MyTester
//
//  Created by Деветов Даниял on 10/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    @IBOutlet private weak var img: UIImageView!
    @IBOutlet private weak var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel?
    @IBOutlet private weak var closureImage: UIImageView?
    @IBOutlet private weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    func setConfigurations(with model: BaseCellModel) {
        titleLabel.text = model.title
        topSpaceConstraint.constant = CGFloat(model.topSpace)
        bottomSpaceConstraint.constant = CGFloat(model.bottomSpace)
        self.selectionStyle = .none
        if !model.isActive {
            self.contentView.backgroundColor = UIColor(rgb: 0x9AA782)
        }
        if self.reuseIdentifier == "withImage" || self.reuseIdentifier == "withTwoLabels" {
            img.image = model.image
            closureImage?.image = model.rightImage
        }
        secondLabel?.text = model.secondTitle
    }
    
    override func prepareForReuse() {
        if self.closureImage?.image == UIImage(named: "ic_checkBoxChecked") {
            self.closureImage?.image = UIImage(named: "ic_checkBox")
        }
    }
    
    func setRightImageChecked(_ isChecked: Bool) {
        if self.closureImage?.image == UIImage(named: "ic_checkBox") {
            if isChecked {
                self.closureImage?.image = UIImage(named: "ic_checkBoxChecked")
            }
        }
    }
}
