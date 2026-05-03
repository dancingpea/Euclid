import Foundation

/// Generates math problems sized to a `Difficulty`.
///
/// Most operations sample operands from `difficulty.operandRange` and reject any
/// candidate whose `abs(answer)` exceeds `difficulty.resultCap`. This keeps each
/// tier's promise: Easy answers stay ≤ 100, Medium ≤ 1,000, Hard ≤ 99,999.
///
/// A few operations don't fit that mold and are bounded directly:
///   - **Subtraction** is operand-bounded (the result is naturally smaller than the operands).
///   - **Percentage** uses a per-tier list of round bases × clean percentages.
///   - **Fraction** uses per-tier denominator caps (results are always near 0–2).
struct ProblemGenerator {

    // MARK: - Anti-repeat state

    private var recentProblems: [String] = []
    private let maxRecent = 5

    /// Maximum rejection-sampling retries before giving up and returning a safe fallback.
    private let maxRetries = 50

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

        // Resolve `mixedOperations` into the four basics + any other selected ops.
        let resolvedOps: [MathOperation]
        if ops.contains(.mixedOperations) {
            let basics: [MathOperation] = [.addition, .subtraction, .multiplication, .division]
            let others = ops.filter { $0 != .mixedOperations }
            resolvedOps = Array(Set(basics + others))
        } else {
            resolvedOps = ops
        }

        // Resolve adaptive → concrete fixed tier so the generator can read both
        // operandRange and resultCap from a single source of truth.
        let resolved = difficultyEngine.resolvedDifficulty(for: difficulty)

        // Try up to 20 times to avoid an immediate repeat of a recent problem text.
        for _ in 0..<20 {
            let op = resolvedOps.randomElement()!
            let problem = createProblem(
                operation: op,
                difficulty: resolved,
                decimalsEnabled: decimalsEnabled,
                negativesEnabled: negativesEnabled
            )
            if !recentProblems.contains(problem.text) {
                trackProblem(problem.text)
                return problem
            }
        }

        // Fallback: return whatever we generated last.
        let op = resolvedOps.randomElement()!
        let problem = createProblem(
            operation: op,
            difficulty: resolved,
            decimalsEnabled: decimalsEnabled,
            negativesEnabled: negativesEnabled
        )
        trackProblem(problem.text)
        return problem
    }

    // MARK: - Dispatch

    private func createProblem(
        operation: MathOperation,
        difficulty: Difficulty,
        decimalsEnabled: Bool,
        negativesEnabled: Bool
    ) -> Problem {
        switch operation {
        case .addition:
            return makeAddition(difficulty: difficulty, negativesEnabled: negativesEnabled)
        case .subtraction:
            return makeSubtraction(difficulty: difficulty, negativesEnabled: negativesEnabled)
        case .multiplication:
            return makeMultiplication(difficulty: difficulty, negativesEnabled: negativesEnabled)
        case .division:
            return makeDivision(difficulty: difficulty, decimalsEnabled: decimalsEnabled, negativesEnabled: negativesEnabled)
        case .square:
            return makeSquare(difficulty: difficulty, negativesEnabled: negativesEnabled)
        case .squareRoot:
            return makeSquareRoot(difficulty: difficulty)
        case .exponent:
            return makeExponent(difficulty: difficulty, negativesEnabled: negativesEnabled)
        case .percentage:
            return makePercentage(difficulty: difficulty)
        case .fraction:
            return makeFraction(difficulty: difficulty)
        case .mixedOperations:
            // Should not reach here — resolved upstream.
            return makeAddition(difficulty: difficulty, negativesEnabled: negativesEnabled)
        }
    }

    // MARK: - Generators

    private func makeAddition(difficulty: Difficulty, negativesEnabled: Bool) -> Problem {
        let range = difficulty.operandRange
        let cap = difficulty.resultCap

        for _ in 0..<maxRetries {
            let a = Int.random(in: range.min...range.max)
            let b = Int.random(in: range.min...range.max)
            let sa = a * (negativesEnabled && Bool.random() ? -1 : 1)
            let sb = b * (negativesEnabled && Bool.random() ? -1 : 1)
            let answer = sa + sb
            if abs(answer) <= cap {
                return buildProblem(text: "\(sa) + \(sb)", answer: Double(answer), operation: .addition)
            }
        }
        // Safe fallback: smallest operands always fit.
        return buildProblem(text: "\(range.min) + \(range.min)", answer: Double(range.min + range.min), operation: .addition)
    }

    private func makeSubtraction(difficulty: Difficulty, negativesEnabled: Bool) -> Problem {
        // Subtraction is operand-bounded: the result of `a - b` with a, b ∈ operandRange
        // is naturally smaller than the operands themselves, so the result cap is satisfied.
        let range = difficulty.operandRange
        var a = Int.random(in: range.min...range.max)
        var b = Int.random(in: range.min...range.max)
        if !negativesEnabled && a < b { swap(&a, &b) }
        let answer = a - b
        return buildProblem(text: "\(a) - \(b)", answer: Double(answer), operation: .subtraction)
    }

    private func makeMultiplication(difficulty: Difficulty, negativesEnabled: Bool) -> Problem {
        let range = difficulty.operandRange
        let cap = difficulty.resultCap

        for _ in 0..<maxRetries {
            let a = Int.random(in: range.min...range.max)
            let b = Int.random(in: range.min...range.max)
            let sa = a * (negativesEnabled && Bool.random() ? -1 : 1)
            let sb = b * (negativesEnabled && Bool.random() ? -1 : 1)
            let product = sa * sb
            if abs(product) <= cap {
                return buildProblem(text: "\(sa) x \(sb)", answer: Double(product), operation: .multiplication)
            }
        }
        // Safe fallback: smallest × smallest.
        let p = range.min * range.min
        return buildProblem(text: "\(range.min) x \(range.min)", answer: Double(p), operation: .multiplication)
    }

    private func makeDivision(
        difficulty: Difficulty,
        decimalsEnabled: Bool,
        negativesEnabled: Bool
    ) -> Problem {
        let range = difficulty.operandRange
        let cap = difficulty.resultCap
        // Divisor pool tracks the operand range but stays in the times-table zone.
        let divisorMax = max(2, min(12, range.max))

        if decimalsEnabled {
            // Allow non-clean divisions; round answer to 2 decimal places.
            for _ in 0..<maxRetries {
                let a = Int.random(in: range.min...range.max)
                let b = Int.random(in: 2...divisorMax)
                let answer = (Double(a) / Double(b) * 100).rounded() / 100
                if abs(answer) <= Double(cap) && abs(a) <= cap {
                    return buildProblem(text: "\(a) / \(b)", answer: answer, operation: .division)
                }
            }
            return buildProblem(text: "\(range.min) / 2", answer: Double(range.min) / 2.0, operation: .division)
        }

        // Clean division: pick divisor + quotient, then dividend = b * quotient.
        // Reject if either dividend or quotient would exceed the cap.
        for _ in 0..<maxRetries {
            let b = Int.random(in: 2...divisorMax)
            let quotient = Int.random(in: range.min...range.max)
            let a = b * quotient
            let sign = negativesEnabled && Bool.random() ? -1 : 1
            let displayA = a * sign
            let answer = quotient * sign
            if abs(answer) <= cap && abs(displayA) <= cap {
                return buildProblem(text: "\(displayA) / \(b)", answer: Double(answer), operation: .division)
            }
        }
        // Fallback: range.min × 2 / 2.
        let safeA = range.min * 2
        return buildProblem(text: "\(safeA) / 2", answer: Double(range.min), operation: .division)
    }

    private func makeSquare(difficulty: Difficulty, negativesEnabled: Bool) -> Problem {
        let range = difficulty.operandRange
        let cap = difficulty.resultCap
        // Bound base by both the operand range and √cap.
        let maxBase = max(2, min(range.max, Int(Double(cap).squareRoot())))
        let minBase = max(2, range.min)
        let upper = max(minBase, maxBase)
        let base = Int.random(in: minBase...upper)
        let sign = negativesEnabled && Bool.random() ? -1 : 1
        let displayBase = base * sign
        // Even power → answer is always positive regardless of base sign.
        let answer = base * base
        return buildProblem(text: "\(displayBase)^2", answer: Double(answer), operation: .square)
    }

    private func makeSquareRoot(difficulty: Difficulty) -> Problem {
        let range = difficulty.operandRange
        let cap = difficulty.resultCap
        // The displayed perfect square is what's bounded by the cap.
        let maxRoot = max(2, min(range.max, Int(Double(cap).squareRoot())))
        let minRoot = max(2, range.min)
        let upper = max(minRoot, maxRoot)
        let root = Int.random(in: minRoot...upper)
        let perfect = root * root
        return buildProblem(text: "sqrt(\(perfect))", answer: Double(root), operation: .squareRoot)
    }

    private func makeExponent(difficulty: Difficulty, negativesEnabled: Bool) -> Problem {
        let cap = difficulty.resultCap

        // Per-tier exponent ceiling. Bases stay in 2...12 across all tiers; the
        // result cap keeps absurd values like 12⁵ out of Easy/Medium.
        let maxExp: Int
        switch difficulty {
        case .range1to10:   maxExp = 2  // squares only at Easy
        case .range1to100:  maxExp = 3
        case .range1to1000: maxExp = 5
        case .adaptive:     maxExp = 2
        }

        for _ in 0..<maxRetries {
            let base = Int.random(in: 2...12)
            let exp = Int.random(in: 2...maxExp)
            let result = power(base, exp)
            if result <= cap {
                let sign = negativesEnabled && Bool.random() ? -1 : 1
                let displayBase = base * sign
                // Even exponents always yield a positive result; odd exponents preserve sign.
                let answer = exp % 2 == 0 ? Double(result) : Double(result) * Double(sign)
                return buildProblem(text: "\(displayBase)^\(exp)", answer: answer, operation: .exponent)
            }
        }
        return buildProblem(text: "2^2", answer: 4, operation: .exponent)
    }

    /// Question forms used by `makePercentage`. Easy uses only `partOfWhole`;
    /// Medium adds `whatPercent`; Hard adds `findWhole`, `increase`, `decrease`.
    private enum PercentForm {
        case partOfWhole   // "25% of 80 = ?"            → answer is the part (20)
        case whatPercent   // "What % of 80 is 20?"      → answer is the percent (25)
        case findWhole     // "20 is 25% of what?"       → answer is the whole (80)
        case increase      // "80 + 15%"                 → answer is base + part (92)
        case decrease      // "80 - 15%"                 → answer is base - part (68)
    }

    private func makePercentage(difficulty: Difficulty) -> Problem {
        // Per-tier vocabulary. Every (pct × base) / 100 combination yields an
        // integer or a half-integer answer (no awkward repeating decimals).
        // 100% has been removed — it's a trivial identity that wastes a turn.
        let percentages: [Int]
        let bases: [Int]
        let specialPairs: [(pct: Int, base: Int)]
        let availableForms: [PercentForm]

        switch difficulty {
        case .range1to10:
            percentages = [10, 20, 25, 50, 75]
            bases = [10, 20, 40, 50, 60, 80, 100]
            specialPairs = []
            availableForms = [.partOfWhole]
        case .range1to100:
            percentages = [5, 10, 15, 20, 25, 30, 40, 50, 75]
            bases = [20, 40, 60, 80, 100, 120, 160, 200, 240, 300, 400, 500, 600, 800]
            specialPairs = []
            availableForms = [.partOfWhole, .whatPercent]
        case .range1to1000, .adaptive:
            percentages = [5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 80, 90]
            bases = [100, 200, 400, 500, 600, 800, 1000, 1200, 1500, 2000, 2500, 3000, 4000, 5000, 8000, 10000]
            // Less-round percentages curated to still produce clean answers.
            specialPairs = [
                (33, 300), (33, 600), (33, 900), (33, 3000),
                (17, 100), (17, 200), (17, 500), (17, 1000),
                (12, 50), (12, 100), (12, 200), (12, 500), (12, 1000),
                (3, 100), (3, 200), (3, 400), (3, 1000)
            ]
            availableForms = [.partOfWhole, .whatPercent, .findWhole, .increase, .decrease]
        }

        // ~20% of Hard percentage problems use the special-pair list for variety.
        let useSpecial = !specialPairs.isEmpty && Int.random(in: 0..<5) == 0
        let pct: Int
        let base: Int
        if useSpecial, let pair = specialPairs.randomElement() {
            pct = pair.pct
            base = pair.base
        } else {
            pct = percentages.randomElement()!
            base = bases.randomElement()!
        }

        let part = Double(pct * base) / 100.0
        let form = availableForms.randomElement()!
        let text: String
        let answer: Double

        switch form {
        case .partOfWhole:
            text = "\(pct)% of \(base)"
            answer = part
        case .whatPercent:
            text = "What % of \(base) is \(part.cleanString)?"
            answer = Double(pct)
        case .findWhole:
            text = "\(part.cleanString) is \(pct)% of what?"
            answer = Double(base)
        case .increase:
            text = "\(base) + \(pct)%"
            answer = Double(base) + part
        case .decrease:
            text = "\(base) - \(pct)%"
            answer = Double(base) - part
        }

        return buildProblem(text: text, answer: answer, operation: .percentage)
    }

    /// Question forms used by `makeFraction`. All four are mixed at every tier;
    /// difficulty is controlled by the denominator cap, not by the operation type.
    private enum FractionForm {
        case add, subtract, multiply, divide
    }

    private func makeFraction(difficulty: Difficulty) -> Problem {
        // Per-tier denominator cap. Fractions are always near 0–2 so the result
        // cap doesn't apply — denominator size is the real difficulty knob.
        let maxDenom: Int
        switch difficulty {
        case .range1to10:              maxDenom = 5
        case .range1to100:             maxDenom = 8
        case .range1to1000, .adaptive: maxDenom = 12
        }

        var b = Int.random(in: 2...maxDenom)
        var d = Int.random(in: 2...maxDenom)
        var a = Int.random(in: 1..<b)
        var c = Int.random(in: 1..<d)

        let forms: [FractionForm] = [.add, .subtract, .multiply, .divide]
        let form = forms.randomElement()!

        let text: String
        let numerator: Int
        let denominator: Int

        switch form {
        case .add:
            numerator = a * d + c * b
            denominator = b * d
            text = "\(a)/\(b) + \(c)/\(d)"
        case .subtract:
            // Swap operands if needed so the result stays non-negative.
            if a * d < c * b {
                swap(&a, &c)
                swap(&b, &d)
            }
            numerator = a * d - c * b
            denominator = b * d
            text = "\(a)/\(b) - \(c)/\(d)"
        case .multiply:
            numerator = a * c
            denominator = b * d
            text = "\(a)/\(b) × \(c)/\(d)"
        case .divide:
            // a/b ÷ c/d = (a × d) / (b × c)
            numerator = a * d
            denominator = b * c
            text = "\(a)/\(b) ÷ \(c)/\(d)"
        }

        let answer = (Double(numerator) / Double(denominator) * 100).rounded() / 100
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
}
