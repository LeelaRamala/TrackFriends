//
//  TFBannerView.swift
//  TrackFriends
//
//  Copyright © 2017 Toms. All rights reserved.
//

import UIKit

class TFBannerView: UIView {
    
    init(withFrame frame: CGRect, message: String) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 110.0 / 255.0, green: 223.0 / 255.0, blue: 241.0 / 255.0, alpha: 0.8)
        
        let messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.preferredMaxLayoutWidth = self.bounds.width
        messageLabel.font = UIFont.systemFont(ofSize: 12.0)
        
        self.addSubview(messageLabel)
        messageLabel.text = message
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
