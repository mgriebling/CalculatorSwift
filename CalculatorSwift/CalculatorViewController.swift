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
            return NumberFormatter().number(from: display.text!)?.doubleValue
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

	@IBAction func addDigit(_ sender: UIButton) {
		let digit = sender.currentTitle!
		
		// check for valid floating point number construction
        if digit == "." && display.text!.firstIndex(of: ".") != nil {
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

	@IBAction func calculate(_ sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let operation = sender.currentTitle {
			displayValue = brain.performOperation(operation)
		}
	}
	
	@IBAction func backspace() {
        if inMiddleOfNumberEntry && display.text!.count > 1 {
            display.text = String(display.text!.dropLast())
		} else {
            if let number = brain.popStack() {
				displayValue = number
				inMiddleOfNumberEntry = true
			} else {
				displayValue = brain.evaluate()
			}
		}
	}
	
	@IBAction func addVariable(_ sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let variable = sender.currentTitle {
			displayValue = brain.pushOperand(variable)
		}
	}
	
	@IBAction func setVariable(_ sender: UIButton) {
        let varName = sender.currentTitle!
		inMiddleOfNumberEntry = false
        brain.variableValues[String(varName.dropFirst())] = displayValue
		displayValue = brain.evaluate()
	}
	
	@IBAction func addConstant(_ sender: UIButton) {
		if inMiddleOfNumberEntry {enterKeyPressed()}
		if let constant = sender.currentTitle {
			displayValue = brain.pushConstant(constant)
		}
	}
	
	@IBAction func negate() {
		if inMiddleOfNumberEntry {
			if display.text!.hasPrefix("-") {
                display.text = String(display.text!.dropFirst())
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GraphingViewController {
            if let identifier = segue.identifier {
                switch identifier {
                    case "showPlot": break
                    default: break
                }
            }
        }
    }
	
}

