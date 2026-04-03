import Foundation

/// Generates math problems based on user settings.
/// Includes anti-repeat logic, proper difficulty ranges for all operations,
/// decimal support, negative support, and higher exponents.
struct ProblemGenerator {

    // MARK: - Anti-repeat state

    /// Keep the last few problem texts to avoid immediate repeats.
    private var recentProblems: [String] = []
    private let maxRecent = 5

    // MARK: - Public API

    /// Generate a single problem for the given settings.
    mutating func generate(
        operations: [MathOperation],
        difficulty: Difficulty,
        difficultyEngine: DifficultyEngine,
        decimalsEnabled: Bool,
        negativesEnabled: Bool
    ) -> Problem {
        let ops = operations.isEmpty ? MathOperation.defaults : operations

        // Handle mixedOperations: pick from all basic operations
        let resolvedOps: [MathOperation]
        if ops.contains(.mixedOperations) {
            let basics: [MathOperation] = [.addition, .subtraction, .multiplication, .division]
            let others = ops.filter { $0 != .mixedOperations }
            resolvedOps = Array(Set(basics + others))
        } else {
            resolvedOps = ops
        }

        // Try up to 20 times to avoid repeating a recent problem
        for _ in 0..<20 {
            let op = resolvedOps.randomElement()!
            let range = difficultyEngine.operandRange(for: difficulty)
            let problem = createProblem(
                operation: op,
                range: range,
                decimalsEnabled: decimalsEnabled,
                negativesEnabled: negativesEnabled
            )
            if !recentProblems.contains(problem.text) {
                trackProblem(problem.text)
                return problem
            }
        }

        // Fallback: return the last generated problem anyway
        let op = resolvedOps.randomElement()!
        let range = difficultyEngine.operandRange(for: difficulty)
        let problem = createProblem(
            operation: op,
            range: range,
            decimalsEnabled: decimalsEnabled,
            negativesEnabled: negativesEnabled
        )
        trackProblem(problem.text)
        return problem
    }

    // MARK: - Problem creation per operation

    private func createProblem(
        operation: MathOperation,
        range: (min: Int, max: Int),
        decimalsEnabled: Bool,
        negativesEnabled: Bool
    ) -> Problem {
        switch operation {
        case .addition:
            return makeArithmetic(op: "+", operation: .addition, range: range, negativesEnabled: negativesEnabled)
        case .subtraction:
            return makeSubtraction(range: range, negativesEnabled: negativesEnabled)
        case .multiplication:
            return makeMultiplication(range: range, negativesEnabled: negativesEnabled)
        case .division:
            return makeDivision(range: range, decimalsEnabled: decimalsEnabled, negativesEnabled: negativesEnabled)
        case .square:
            return makeSquare(range: range, negativesEnabled: negativesEnabled)
        case .squareRoot:
            return makeSquareRoot(range: range)
        case .exponent:
            return makeExponent(range: range, negativesEnabled: negativesEnabled)
        case .percentage:
            return makePercentage(range: range)
        case .fraction:
            return makeFraction(range: range)
        case .mixedOperations:
            // Should not reach here — resolved above
            return makeArithmetic(op: "+", operation: .addition, range: range, negativesEnabled: negativesEnabled)
        }
    }

    // MARK: - Specific generators

    private func makeArithmetic(
        op: String,
        operation: MathOperation,
        range: (min: Int, max: Int),
        negativesEnabled: Bool
    ) -> Problem {
        let a = randomInt(in: range)
        let b = randomInt(in: range)
        let signA = negativesEnabled && Bool.random() ? -1 : 1
        let signB = negativesEnabled && Bool.random() ? -1 : 1
        let sa = a * signA
        let sb = b * signB
        let finalAnswer = Double(sa + sb)
        let text = "\(sa) + \(sb)"
        return buildProblem(text: text, answer: finalAnswer, operation: operation)
    }

    private func makeSubtraction(
        range: (min: Int, max: Int),
        negativesEnabled: Bool
    ) -> Problem {
        var a = randomInt(in: range)
        var b = randomInt(in: range)
        // Ensure a >= b unless negatives are enabled
        if !negativesEnabled && a < b { swap(&a, &b) }
        let answer = Double(a - b)
        let text = "\(a) - \(b)"
        return buildProblem(text: text, answer: answer, operation: .subtraction)
    }

    private func makeMultiplication(
        range: (min: Int, max: Int),
        negativesEnabled: Bool
    ) -> Problem {
        // Scale down one operand for larger ranges so answers stay reasonable
        let a: Int
        let b: Int
        if range.max > 100 {
            a = randomInt(in: range)
            b = Int.random(in: 2...12)
        } else {
            a = randomInt(in: range)
            b = randomInt(in: (max(range.min, 2), min(range.max, 100)))
        }
        let signA = negativesEnabled && Bool.random() ? -1 : 1
        let signB = negativesEnabled && Bool.random() ? -1 : 1
        let sa = a * signA
        let sb = b * signB
        let answer = Double(sa * sb)
        let text = "\(sa) x \(sb)"
        return buildProblem(text: text, answer: answer, operation: .multiplication)
    }

    private func makeDivision(
        range: (min: Int, max: Int),
        decimalsEnabled: Bool,
        negativesEnabled: Bool
    ) -> Problem {
        if decimalsEnabled {
            // Allow non-clean divisions
            let a = randomInt(in: range)
            let b = Int.random(in: 2...12)
            let answer = (Double(a) / Double(b) * 100).rounded() / 100  // round to 2 decimals
            let text = "\(a) / \(b)"
            return buildProblem(text: text, answer: answer, operation: .division)
        } else {
            // Ensure clean division: pick b and quotient, then a = b * quotient
            let b = Int.random(in: 2...12)
            let quotient = randomInt(in: range)
            let a = b * quotient
            let signA = negativesEnabled && Bool.random() ? -1 : 1
            let answer = Double(a / b * signA)
            let displayA = a * signA
            let text = "\(displayA) / \(b)"
            return buildProblem(text: text, answer: answer, operation: .division)
        }
    }

    private func makeSquare(
        range: (min: Int, max: Int),
        negativesEnabled: Bool
    ) -> Problem {
        // Pick a base whose square fits within the difficulty spirit
        let maxBase: Int
        if range.max <= 100 {
            maxBase = 15
        } else if range.max <= 1000 {
            maxBase = 31
        } else {
            maxBase = 99
        }
        let minBase = max(2, range.min <= 100 ? 2 : 10)
        let base = Int.random(in: minBase...maxBase)
        let sign = negativesEnabled && Bool.random() ? -1 : 1
        let displayBase = base * sign
        let answer = Double(base * base)
        let text = "\(displayBase)^2"
        return buildProblem(text: text, answer: answer, operation: .square)
    }

    private func makeSquareRoot(range: (min: Int, max: Int)) -> Problem {
        // Pick a root whose square fits the range
        let maxRoot: Int
        if range.max <= 100 {
            maxRoot = 10
        } else if range.max <= 1000 {
            maxRoot = 31
        } else {
            maxRoot = 99
        }
        let minRoot = max(2, range.min <= 100 ? 2 : 10)
        let root = Int.random(in: minRoot...maxRoot)
        let perfect = root * root
        let text = "sqrt(\(perfect))"
        return buildProblem(text: text, answer: Double(root), operation: .squareRoot)
    }

    private func makeExponent(
        range: (min: Int, max: Int),
        negativesEnabled: Bool
    ) -> Problem {
        // Support exponents 2 through 5, scaled to difficulty
        let maxBase: Int
        let maxExp: Int
        if range.max <= 100 {
            maxBase = 12
            maxExp = 4
        } else if range.max <= 1000 {
            maxBase = 8
            maxExp = 5
        } else {
            maxBase = 6
            maxExp = 5
        }
        let base = Int.random(in: 2...maxBase)
        let exp = Int.random(in: 2...maxExp)

        // Make sure the result isn't absurdly large
        let result = power(base, exp)
        let answer = Double(result)
        let sign = negativesEnabled && Bool.random() ? -1 : 1
        let displayBase = base * sign
        // For negative bases with even exponents, answer is positive; odd exponents, negative
        let finalAnswer = exp % 2 == 0 ? answer : answer * Double(sign)
        let text = "\(displayBase)^\(exp)"
        return buildProblem(text: text, answer: finalAnswer, operation: .exponent)
    }

    private func makePercentage(range: (min: Int, max: Int)) -> Problem {
        let percentages = [5, 10, 15, 20, 25, 30, 40, 50, 75, 100]
        let pct = percentages.randomElement()!
        let base = randomInt(in: range)
        // Ensure clean answer when possible
        let adjusted = base - (base % (100 / gcd(pct, 100)))
        let finalBase = adjusted == 0 ? base : adjusted
        let answer = Double(finalBase * pct) / 100.0
        let text = "\(pct)% of \(finalBase)"
        return buildProblem(text: text, answer: answer, operation: .percentage)
    }

    private func makeFraction(range: (min: Int, max: Int)) -> Problem {
        // Simple fraction addition: a/b + c/d
        let b = Int.random(in: 2...12)
        let d = Int.random(in: 2...12)
        let a = Int.random(in: 1..<b)
        let c = Int.random(in: 1..<d)
        let numerator = a * d + c * b
        let denominator = b * d
        // Answer as decimal (rounded to 2 places)
        let answer = (Double(numerator) / Double(denominator) * 100).rounded() / 100
        let text = "\(a)/\(b) + \(c)/\(d)"
        return buildProblem(text: text, answer: answer, operation: .fraction)
    }

    // MARK: - Helpers

    private func buildProblem(text: String, answer: Double, operation: MathOperation) -> Problem {
        let isNegative = answer < 0
        let absAnswer = abs(answer)
        let hasDecimals = absAnswer != absAnswer.rounded()
        let intPart = Int(absAnswer)
        let digitCount = intPart == 0 ? 1 : String(intPart).count

        return Problem(
            text: text,
            correctAnswer: answer,
            operation: operation,
            expectedDigitCount: digitCount,
            hasDecimals: hasDecimals,
            isNegative: isNegative
        )
    }

    private func randomInt(in range: (min: Int, max: Int)) -> Int {
        Int.random(in: range.min...range.max)
    }

    private mutating func trackProblem(_ text: String) {
        recentProblems.append(text)
        if recentProblems.count > maxRecent {
            recentProblems.removeFirst()
        }
    }

    private func power(_ base: Int, _ exp: Int) -> Int {
        var result = 1
        for _ in 0..<exp { result *= base }
        return result
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        let a = abs(a)
        let b = abs(b)
        if b == 0 { return a }
        return gcd(b, a % b)
    }
}
