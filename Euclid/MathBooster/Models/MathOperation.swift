import Foundation

/// Every math operation the app supports. Each is independently toggleable by the user.
enum MathOperation: String, CaseIterable, Codable, Identifiable {
    case addition
    case subtraction
    case multiplication
    case division
    case square
    case squareRoot
    case exponent
    case percentage
    case fraction
    case mixedOperations

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .addition:         return "+"
        case .subtraction:      return "-"
        case .multiplication:   return "x"
        case .division:         return "/"
        case .square:           return "x^2"
        case .squareRoot:       return "sqrt"
        case .exponent:         return "x^n"
        case .percentage:       return "%"
        case .fraction:         return "a/b"
        case .mixedOperations:  return "mix"
        }
    }

    var displayName: String {
        switch self {
        case .addition:         return "Addition"
        case .subtraction:      return "Subtraction"
        case .multiplication:   return "Multiplication"
        case .division:         return "Division"
        case .square:           return "Square"
        case .squareRoot:       return "Square Root"
        case .exponent:         return "Exponent"
        case .percentage:       return "Percentage"
        case .fraction:         return "Fraction"
        case .mixedOperations:  return "Mixed"
        }
    }

    var iconName: String {
        switch self {
        case .addition:         return "plus"
        case .subtraction:      return "minus"
        case .multiplication:   return "multiply"
        case .division:         return "divide"
        case .square:           return "number.square"
        case .squareRoot:       return "x.squareroot"
        case .exponent:         return "chevron.up.2"
        case .percentage:       return "percent"
        case .fraction:         return "rectangle.split.1x2"
        case .mixedOperations:  return "shuffle"
        }
    }

    /// The default operations enabled for new users.
    static var defaults: [MathOperation] {
        [.addition, .subtraction, .multiplication, .division]
    }
}
