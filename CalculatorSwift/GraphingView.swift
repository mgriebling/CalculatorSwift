//
//  GraphingView.swift
//  CalculatorSwift
//
//  Created by Michael Griebling on 19Feb2015.
//  Copyright (c) 2015 Solinst Canada. All rights reserved.
//

import UIKit

@IBDesignable class GraphingView: UIView {
	
	@IBInspectable var scale : CGFloat = 1.0 {
		didSet {
			scale = max(scale, 0.0)
			setNeedsDisplay()
		}
	}
	
	var origin = CGPointZero
	
	private var axis = AxesDrawer(contentScaleFactor: 1.0)
	
    override func draw(_ rect: CGRect) {
        axis.contentScaleFactor = self.contentScaleFactor
        axis.drawAxesInRect(rect, origin: self.origin, pointsPerUnit: self.scale)
    }
	
}
