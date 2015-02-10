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
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double, Int)
		case Constant(String)
		case VarOperand(String)
		
		var description: String {
			get {
				switch self {
				case .Operand(let operand):
					return "\(operand)"
				case .UnaryOperation(let symbol, _):
					return symbol
				case .BinaryOperation(let symbol, _, _):
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
				case .BinaryOperation(let op, _, let precedence):
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
			case .UnaryOperation(let operation, _):
				let value = describe(remainingOps)
				if let operand = value.result {
					let ops = operation == "±" ? "−" : operation // substitue "-" for "±"
					return (ops + "(" + operand + ")", value.remainingOps, op.precedence)
				}
			case .BinaryOperation(let operation, _, let precedence):
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
	
	init () {
		func learnOp (op: Op) {
			knownOps[op.description] = op
		}
		
		learnOp(Op.BinaryOperation("×", *, 20))
		learnOp(Op.BinaryOperation("+", +, 10))
		learnOp(Op.BinaryOperation("−", {$1 - $0}, 10))
		learnOp(Op.BinaryOperation("÷", {$1 / $0}, 20))
		learnOp(Op.UnaryOperation("√", sqrt))
		learnOp(Op.UnaryOperation("±", {0 - $0}))
		learnOp(Op.UnaryOperation("sin", sin))
		learnOp(Op.UnaryOperation("cos", cos))
		
		constantValues["π"] = M_PI
	}
	
	private func evaluate (ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand, remainingOps)
			case .UnaryOperation(_, let operation):
				let operandEvaluation = evaluate(remainingOps)
				if let operand = operandEvaluation.result {
					return (operation(operand), operandEvaluation.remainingOps)
				}
			case .BinaryOperation(_, let operation, _):
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
		let (result, remainder) = evaluate(opStack)
		println("\(opStack) = \(result) with \(remainder) left over")
		return result
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
