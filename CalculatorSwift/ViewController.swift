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
	
	var stack = [Double]()		// value stack
	var entries = [String]()	// used for history entries
	
	var inMiddleOfNumberEntry = false
	var numberFormatter = NSNumberFormatter()
	
	var displayValue : Double? {
		get {
			if let number = numberFormatter.numberFromString(display.text!) {
				return number.doubleValue
			} else {
				return nil
			}
		}
		set {
			if newValue == nil {
				display.text = ""
			} else {
				display.text = "\(newValue!)"
			}
			inMiddleOfNumberEntry = false
		}
	}

	@IBAction func addDigit(sender: UIButton) {
		let digit = sender.currentTitle!
		
		// check for valid floating point number construction
		if digit == "." && display.text!.rangeOfString(".") != nil {
			return // ignore two or more decimals
		}
		
		// check if "0" in display needs to be cleared
		if !inMiddleOfNumberEntry {
			display.text = digit
			inMiddleOfNumberEntry = true
		} else {
			display.text! += digit
		}
	}
	
	func addEqual () {
		if let position = find(entries, "=") {
			// remove any existing "="s
			removeAtIndex(&entries, position)
		}
		entries.append("=")
	}
	
	func performOperation (op : (Double, Double) -> Double) {
		if stack.count >= 2 {
			displayValue = op(stack.removeLast(), stack.removeLast())
			addEqual()
			enterKeyPressed()
		}
	}
	
	func performOperation (op : Double -> Double) {
		if stack.count >= 1 {
			displayValue = op(stack.removeLast())
			addEqual()
			enterKeyPressed()
		}
	}
	
	func pushConstant (const: Double) {
		displayValue = const
		addEqual()
		enterKeyPressed()
	}

	@IBAction func calculate(sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		
		if let operation = sender.currentTitle {
			entries.append(operation)
			switch operation {
			case "+"	: performOperation({$0 + $1})
			case "−"	: performOperation({$1 - $0})
			case "×"	: performOperation({$0 * $1})
			case "÷"	: performOperation({$1 / $0})
			case "√"	: performOperation(sqrt)
			case "sin"	: performOperation(sin)
			case "cos"	: performOperation(cos)
			case "π"	: pushConstant(M_PI)
			default		: break
			}
		}
	}
	
	@IBAction func backspace() {
		if inMiddleOfNumberEntry {
			if countElements(display.text!) > 1 {
				display.text = dropLast(display.text!)
			} else {
				display.text = "0"
				inMiddleOfNumberEntry = false
			}
		}
	}
	
	@IBAction func negate() {
		if inMiddleOfNumberEntry {
			if display.text!.hasPrefix("-") {
				display.text = dropFirst(display.text!)
			} else {
				display.text = "-" + display.text!
			}
		} else {
			entries.append("±")
			performOperation({-$0})
		}
		println("stack = \(stack)")
		stackDisplay.text = "History: \(entries)"
	}
	
	@IBAction func enterKeyPressed() {
		inMiddleOfNumberEntry = false
		if displayValue != nil {
			stack.append(displayValue!)
			entries.append("\(displayValue!)")
		}
		println("stack = \(stack)")
		stackDisplay.text = "History: \(entries)"
	}
	
	@IBAction func clearState() {
		display.text = "0"
		stack = [Double]()
		entries = [String]()
		println("stack = \(stack)")
		stackDisplay.text = "History: \(entries)"
	}
}

