//
//  CalculatorBrain.swift
//  CalculatorSwift
//
//  Created by Michael Griebling on 5Feb2015.
//  Copyright (c) 2015 Solinst Canada. All rights reserved.
//

import Foundation

class CalculatorBrain {
	
	private enum Op: Printable {
		case Operand(Double)
		case UnaryOperation(String, Double -> Double, (Double -> String?)?)
		case BinaryOperation(String, (Double, Double) -> Double, Int, ((Double, Double) -> String?)?)
		case Constant(String)
		case VarOperand(String)
		
		var description: String {
			get {
				switch self {
				case .Operand(let operand):
					return "\(operand)"
				case .UnaryOperation(let symbol, _, _):
					return symbol
				case .BinaryOperation(let symbol, _, _, _):
					return symbol
				case .Constant(let symbol):
					return symbol
				case .VarOperand(let varString):
					return varString
				}
			}
		}
		
		var precedence: Int {
			get {
				switch self {
				case .BinaryOperation(let op, _, let precedence, _):
					return precedence
				default:
					return Int.max   // default (highest) precedence for most things
				}
				
			}
		}
	}
	
	private var opStack = [Op]()
	private var knownOps = [String: Op]()
	var variableValues = [String: Double]()
	private var constantValues = [String: Double]()
	
	var description : String {
		var (result, remainder, _) = describe(opStack)
		if let ans = result {
			var total = ans
			while remainder.count > 0 {
				(result, remainder, _) = describe(remainder)
				if let ans2 = result {
					total = ans2 + "," + total
				}
			}
			return total + "="
		}
		return " "
	}
	
	private func describe (ops: [Op]) -> (result: String?, remainingOps: [Op], precedence: Int) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand.description, remainingOps, op.precedence)
			case .UnaryOperation(let operation, _, _):
				let value = describe(remainingOps)
				if let operand = value.result {
					let ops = operation == "±" ? "−" : operation // substitue "-" for "±"
					return (ops + "(" + operand + ")", value.remainingOps, op.precedence)
				}
			case .BinaryOperation(let operation, _, let precedence, _):
				let op1Evaluation = describe(remainingOps)
				if let operand1 = op1Evaluation.result {
					var result = operand1
					if op1Evaluation.precedence < precedence {
						// add braces around lower precedence expressions
						result = "(" + result + ")"
					}
					result = operation + result
					let op2Evaluation = describe(op1Evaluation.remainingOps)
					if let operand2 = op2Evaluation.result {
						if op2Evaluation.precedence < precedence {
							result = "(" + operand2 + ")" + result
						} else {
							result = operand2 + result
						}
					} else {
						result = "?" + result
					}
					return (result, op2Evaluation.remainingOps, precedence)
				}
			case .Constant(let constant):
				return (constant, remainingOps, op.precedence)
			case .VarOperand(let variable):
				return (variable, remainingOps, op.precedence)
			}
		}
		return (nil, ops, 0)
	}
	
	private func divisionChecks (arg1: Double, arg2: Double) -> String? {
		if arg1.isZero { return "Division by zero" }
		return nil
	}
	
	private func squareRootChecks (arg: Double) -> String? {
		if arg < 0 { return "Negative square root" }
		return nil
	}
	
	init () {
		func learnOp (op: Op) {
			knownOps[op.description] = op
		}
		
		learnOp(Op.BinaryOperation("×", *, 20, nil))
		learnOp(Op.BinaryOperation("+", +, 10, nil))
		learnOp(Op.BinaryOperation("−", {$1 - $0}, 10, nil))
		learnOp(Op.BinaryOperation("÷", {$1 / $0}, 20, divisionChecks))
		learnOp(Op.UnaryOperation("√", sqrt, squareRootChecks))
		learnOp(Op.UnaryOperation("±", {0 - $0}, nil))
		learnOp(Op.UnaryOperation("sin", sin, nil))
		learnOp(Op.UnaryOperation("cos", cos, nil))
		
		constantValues["π"] = M_PI
	}
	
	private func evaluate (ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand, remainingOps)
			case .UnaryOperation(_, let operation, _):
				let operandEvaluation = evaluate(remainingOps)
				if let operand = operandEvaluation.result {
					return (operation(operand), operandEvaluation.remainingOps)
				}
			case .BinaryOperation(_, let operation, _, _):
				let op1Evaluation = evaluate(remainingOps)
				if let operand1 = op1Evaluation.result {
					let op2Evaluation = evaluate(op1Evaluation.remainingOps)
					if let operand2 = op2Evaluation.result {
						return (operation(operand1, operand2), op2Evaluation.remainingOps)
					}
				}
			case .Constant(let constant):
				if let varValue = constantValues[constant] {
					return (varValue, remainingOps)
				}
			case .VarOperand(let variable):
				if let varValue = variableValues[variable] {
					return (varValue, remainingOps)
				}
			}
		}
		return (nil, ops)
	}
	
	func evaluate() -> Double? {
	//	let (result, remainder) = evaluate(opStack)
		let (result, error, remainder) = evaluateAndReportErrors(opStack)

		if error != nil {
			println("Error = " + error!)
			return nil;
		} else {
			println("\(opStack) = \(result) with \(remainder) left over")
		}
		return result
	}
	
	private func evaluateAndReportErrors(ops: [Op]) -> (result: Double?, error: String?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand, nil, remainingOps)
			case .UnaryOperation(let opName, let operation, let errorFunction):
				let operandEvaluation = evaluateAndReportErrors(remainingOps)
				if let operand = operandEvaluation.result {
					var outError : String? = nil
					if let error = operandEvaluation.error {
						outError = error
					} else if let error2 = errorFunction?(operand) {
						outError = error2
					}
					return (operation(operand), outError, operandEvaluation.remainingOps)
				} else {
					return (0, "Insufficient arguments for " + opName, operandEvaluation.remainingOps)
				}
			case .BinaryOperation(let opName, let operation, _, let errorFunction):
				let op1Evaluation = evaluateAndReportErrors(remainingOps)
				if let operand1 = op1Evaluation.result {
					let op2Evaluation = evaluateAndReportErrors(op1Evaluation.remainingOps)
					if let operand2 = op2Evaluation.result {
						var outError : String? = nil
						if let error = op2Evaluation.error {
							outError = error
						} else if let error2 = errorFunction?(operand1, operand2) {
							outError = error2
						}
						return (operation(operand1, operand2), outError, op2Evaluation.remainingOps)
					} else {
						return (0, "Too few operands for " + opName, op2Evaluation.remainingOps)
					}
				} else {
					return (0, "Too few operands for " + opName, op1Evaluation.remainingOps)
				}
			case .Constant(let constant):
				if let varValue = constantValues[constant] {
					return (varValue, nil, remainingOps)
				} else {
					return (0, "Undefined constant " + constant, remainingOps)
				}
			case .VarOperand(let variable):
				if let varValue = variableValues[variable] {
					return (varValue, nil, remainingOps)
				} else {
					return (0, "Undefined variable " + variable, remainingOps)
				}
			}
		}
		return (nil, nil, ops)
	}
	
	func evaluateAndReportErrors() -> String? {
		if opStack.isEmpty { return "Nothing to evaluate" }
		let (_, error, _) = evaluateAndReportErrors(opStack)
		return error
	}
	
	func pushOperand(operand: Double) -> Double? {
		opStack.append(Op.Operand(operand))
		return evaluate()
	}
	
	func pushOperand(operand: String) -> Double? {
		opStack.append(Op.VarOperand(operand))
		return evaluate()
	}
	
	func pushConstant(name: String) -> Double? {
		opStack.append(Op.Constant(name))
		return evaluate()
	}
	
	func popStack () -> Double? {
		if opStack.count == 0 {return nil}
		let op = opStack.removeLast()
		switch op {
		case .Operand(let val): return val
		default: return nil
		}
	}
	
	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] {
			opStack.append(operation)
		}
		return evaluate()
	}
}

