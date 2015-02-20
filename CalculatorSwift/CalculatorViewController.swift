//
//  ViewController.swift
//  CalculatorSwift
//
//  Created by Michael Griebling on 3Feb2015.
//  Copyright (c) 2015 Solinst Canada. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

	@IBOutlet weak var display: UILabel!
	@IBOutlet weak var stackDisplay: UILabel!
	
	private var brain = CalculatorBrain()	// calculator model
	private var inMiddleOfNumberEntry = false
	
	var displayValue : Double? {
		get {
			return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
		}
		set {
			if let disp = newValue {
				display.text = "\(disp)"
			} else {
				display.text = brain.evaluateAndReportErrors()
			}
			inMiddleOfNumberEntry = false
			stackDisplay.text = brain.description
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

	@IBAction func calculate(sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let operation = sender.currentTitle {
			displayValue = brain.performOperation(operation)
		}
	}
	
	@IBAction func backspace() {
		if inMiddleOfNumberEntry && countElements(display.text!) > 1 {
			display.text = dropLast(display.text!)
		} else {
			if var number = brain.popStack() {
				displayValue = number
				inMiddleOfNumberEntry = true
			} else {
				displayValue = brain.evaluate()
			}
		}
	}
	
	@IBAction func addVariable(sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let variable = sender.currentTitle {
			displayValue = brain.pushOperand(variable)
		}
	}
	
	@IBAction func setVariable(sender: UIButton) {
		var varName = sender.currentTitle!
		inMiddleOfNumberEntry = false
		brain.variableValues[dropFirst(varName)] = displayValue
		displayValue = brain.evaluate()
	}
	
	@IBAction func addConstant(sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let constant = sender.currentTitle {
			displayValue = brain.pushConstant(constant)
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
			displayValue = brain.performOperation("±")
		}
	}
	
	@IBAction func enterKeyPressed() {
		inMiddleOfNumberEntry = false
		displayValue = brain.pushOperand(displayValue!)
	}
	
	@IBAction func clearState() {
		inMiddleOfNumberEntry = false
		brain = CalculatorBrain()
		display.text = "0"
		stackDisplay.text = brain.description
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let pvc = segue.destinationViewController as? GraphingViewController {
			if let identifier = segue.identifier {
				switch identifier {
					case "showPlot": break
					default: break
				}
			}
		}
	}
	
}

