//
//  TFBannerView.swift
//  TrackFriends
//
//  Created by Ramala Srinivasulu, Leela on 5/13/17.
//  Copyright © 2017 Toms. All rights reserved.
//

import UIKit

class TFBannerView: UIView {
    
    init(withFrame frame: CGRect, message: String) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightBlueColor()
        
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 13.0)
        messageLabel.text = message
        
        self.addSubview(messageLabel)
        messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        self.layoutIfNeeded()
        
        let height = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
