//
//  SegmentSelectedBackground.swift
//  Tracin Buddy
//
//  Created by Trabajo on 21/10/21.
//  Copyright © 2021 Trabajo. All rights reserved.
//

import UIKit

class SegmentSelectedBackground: UIView {

    lazy var backgroundShape:CAShapeLayer = {
        let layer:CAShapeLayer = CAShapeLayer()
        self.layer.addSublayer(layer)
        self.layer.isOpaque = false
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundShape.frame = self.bounds
        
        let insetRect = self.bounds.inset(by: UIEdgeInsets(top: 2, left: 2,
                                                           bottom: 2, right: 2))
        let path = UIBezierPath.init(roundedRect: insetRect, cornerRadius: 6.0)
        backgroundShape.path = path.cgPath
    }

}
