//
//  RoundedShadowButton.swift
//  Vision-app-dev
//
//  Created by juger rash on 13.09.19.
//  Copyright © 2019 juger rash. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
