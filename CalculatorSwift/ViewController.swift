//
//  ViewController.swift
//  CalculatorSwift
//
//  Created by Michael Griebling on 3Feb2015.
//  Copyright (c) 2015 Solinst Canada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var display: UILabel!

	@IBOutlet weak var stackDisplay: UILabel!
	
	var stack : [Double] = []
	var inMiddleOfNumberEntry = false
	var decimalEntered = false

	@IBAction func addDigit(sender: UIButton) {
		let digit = sender.titleLabel!.text!
		
		// check if "0" in display needs to be cleared
		if !inMiddleOfNumberEntry { display.text! = "" }
		inMiddleOfNumberEntry = true
		
		// check for valid floating point number construction
		if digit == "." {
			if decimalEntered {return} // ignore two or more decimals
			decimalEntered = true
		}

		display.text! += digit
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		clearState(UIButton())
	}

	@IBAction func calculate(sender: UIButton) {

	}
	
	func displayStack () {
		if stack.isEmpty {stackDisplay.text! = "Stack: Empty"}
		else {stackDisplay.text! = "Stack: \(stack)"}
	}
	
	func enterNumberOnStack (number : NSNumber?) {
		if number != nil {stack.append(number!.doubleValue)}
		inMiddleOfNumberEntry = false
		decimalEntered = false
		displayStack()
	}
	
	@IBAction func enterKeyPressed(sender: UIButton) {
		let number = NSNumberFormatter().numberFromString(display.text!)
		enterNumberOnStack(number)
	}
	
	@IBAction func addConstant(sender: UIButton) {
		let digit = sender.titleLabel!.text!
		
		// enter any number already in the display
		if inMiddleOfNumberEntry {enterKeyPressed(sender)}
		
		// display the constant
		addDigit(sender)
		
		// put the constant on the stack
		switch digit {
		case "π" : enterNumberOnStack(NSNumber(double: M_PI))
		default : break
		}
	}
	
	@IBAction func clearState(sender: UIButton) {
		display.text! = "0"
		inMiddleOfNumberEntry = false
		decimalEntered = false
		stack = []
		displayStack()
	}
}

