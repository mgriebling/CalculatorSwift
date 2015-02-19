//
//  GraphingView.swift
//  CalculatorSwift
//
//  Created by Michael Griebling on 19Feb2015.
//  Copyright (c) 2015 Solinst Canada. All rights reserved.
//

import UIKit

@IBDesignable class GraphingView: UIView {
	
	@IBInspectable var scale : CGFloat = 1.0
	
	var axis = AxesDrawer(contentScaleFactor: 1.0)
	
	override func drawRect(rect: CGRect) {
		axis.drawAxesInRect(rect, origin: CGPointZero, pointsPerUnit: 1)
	}
	
}
