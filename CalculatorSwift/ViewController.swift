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
	
	func performOperation (op : (arg1 : Double, arg2 : Double) -> Double) {
		if stack.count >= 2 {
			let number1 = stack.removeLast()
			let number2 = stack.removeLast()
			enterNumberOnStack(op(arg1: number1, arg2: number2))
		}
	}
	
	func performOperation (op : (arg : Double) -> Double) {
		if stack.count >= 1 {
			let number = stack.removeLast()
			enterNumberOnStack(op(arg: number))
		}
	}

	@IBAction func calculate(sender: UIButton) {
		let operation = sender.titleLabel!.text!
		if inMiddleOfNumberEntry {enterKeyPressed(UIButton())}
		switch operation {
			case "+" : performOperation({$0 + $1})
			case "−" : performOperation({$1 - $0})
			case "×" : performOperation({$0 * $1})
			case "÷" : performOperation({$1 / $0})
			case "sin" : performOperation({sin($0)})
			case "cos" : performOperation({cos($0)})
			case "π" : enterNumberOnStack(M_PI)
			default : break
		}
		if stack.last != nil {display.text! = "\(stack.last!)"}
	}
	
	func displayStack () {
		if stack.isEmpty {stackDisplay.text! = "Stack: Empty"}
		else {stackDisplay.text! = "Stack: \(stack)"}
	}
	
	func enterNumberOnStack (number : Double) {
		stack.append(number)
		inMiddleOfNumberEntry = false
		decimalEntered = false
		displayStack()
	}
	
	@IBAction func enterKeyPressed(sender: UIButton) {
		let number = NSNumberFormatter().numberFromString(display.text!)?.doubleValue
		if (number != nil) {enterNumberOnStack(number!)}
	}
	
//	@IBAction func addConstant(sender: UIButton) {
//		let digit = sender.titleLabel!.text!
//		
//		// enter any number already in the display
//		if inMiddleOfNumberEntry {enterKeyPressed(sender)}
//		
//		// display the constant
//		addDigit(sender)
//		
//		// put the constant on the stack
//		switch digit {
//						default : break
//		}
//	}
	
	@IBAction func clearState(sender: UIButton) {
		display.text! = "0"
		inMiddleOfNumberEntry = false
		decimalEntered = false
		stack = []
		displayStack()
	}
}

