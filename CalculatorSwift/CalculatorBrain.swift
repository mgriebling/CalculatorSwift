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
		case BinaryOperation(String, (Double, Double) -> Double)
		case Constant(String)
		case VarOperand(String)
		
		var description: String {
			get {
				switch self {
				case .Operand(let operand):
					return "\(operand)"
				case .UnaryOperation(let symbol, _):
					return symbol
				case .BinaryOperation(let symbol, _):
					return symbol
				case .Constant(let symbol):
					return symbol
				case .VarOperand(let varString):
					return varString
				}
			}
		}
	}
	
	private var opStack = [Op]()
	private var knownOps = [String: Op]()
	var variableValues = [String: Double]()
	private var constantValues = [String: Double]()
	
	private func removeBraces (s: String) -> String {
		if s.hasPrefix("(") && s.hasSuffix(")") {
			var str = s;
			removeLast(&str)
			return dropFirst(str)
		}
		return s
	}
	
	var description : String {
		
		var (result, remainder) = describe(opStack)
		if let ans = result {
			var total = removeBraces(ans)
			while remainder.count > 0 {
				(result, remainder) = describe(remainder)
				if let ans2 = result {
					total += "," + removeBraces(ans2)
				}
			}
			return total + "="
		}
		return " "
	}
	
	private func describe (ops: [Op]) -> (result: String?, remainingOps: [Op]) {
		if !ops.isEmpty {
			var remainingOps = ops
			let op = remainingOps.removeLast()
			switch op {
			case .Operand(let operand):
				return (operand.description, remainingOps)
			case .UnaryOperation(let operation, _):
				let value = describe(remainingOps)
				if let operand = value.result {
					let op = operation == "±" ? "−" : operation // substitue "-" for "±"
					return (op + "(" + removeBraces(operand) + ")", value.remainingOps)
				}
			case .BinaryOperation(let operation, _):
				let op1Evaluation = describe(remainingOps)
				if let operand1 = op1Evaluation.result {
					var result = operation + operand1
					let op2Evaluation = describe(op1Evaluation.remainingOps)
					if let operand2 = op2Evaluation.result {
						result = operand2 + result
					} else {
						result = "?" + result
					}
					result = "(" + removeBraces(result) + ")"
					return (result, op2Evaluation.remainingOps)
				}
			case .Constant(let constant):
				return (constant, remainingOps)
			case .VarOperand(let variable):
				return (variable, remainingOps)
			}
		}
		return (nil, ops)
	}
	
	init () {
		func learnOp (op: Op) {
			knownOps[op.description] = op
		}
		
		learnOp(Op.BinaryOperation("×", *))
		learnOp(Op.BinaryOperation("+", +))
		learnOp(Op.BinaryOperation("−"){$1 - $0})
		learnOp(Op.BinaryOperation("÷"){$1 / $0})
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
			case .BinaryOperation(_, let operation):
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
	
	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] {
			opStack.append(operation)
		}
		return evaluate()
	}
}
