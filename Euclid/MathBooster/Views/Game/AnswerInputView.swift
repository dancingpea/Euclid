import SwiftUI

struct AnswerInputView: View {
    var viewModel: GameViewModel
    let settings: UserSettings

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 10) {
            // Two-field fraction input (above the numpad), shown only for fraction modes
            // that ask for a fraction answer.
            if isFractionMode {
                fractionFieldStack
            }

            // Number grid: 1-9
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...9, id: \.self) { digit in
                    NumberButton(label: "\(digit)") {
                        viewModel.appendDigit("\(digit)")
                    }
                }
            }

            // Bottom row: special key + 0 + Del
            LazyVGrid(columns: columns, spacing: 10) {
                bottomRowSpecialKey
                NumberButton(label: "0") { viewModel.appendDigit("0") }
                NumberButton(label: "Del", variant: .secondary) { viewModel.deleteLastDigit() }
            }

            // Extra row for non-fraction problems with both negatives + decimals enabled.
            if !isFractionMode && settings.negativesEnabled && settings.decimalsEnabled {
                HStack(spacing: 12) {
                    NumberButton(label: ".", variant: .secondary) {
                        viewModel.appendDigit(".")
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Submit button
            Button {
                viewModel.submitAnswer(settings: settings)
            } label: {
                Text("Submit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.indigo, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Mode helpers

    private var isFractionMode: Bool {
        guard let problem = viewModel.currentProblem else { return false }
        if case .twoFieldFraction = problem.inputKind { return true }
        return false
    }

    /// True for fraction Mode 4 (calculation), where the user may leave the
    /// denominator empty and answer with a single decimal/percentage.
    private var allowEmptyDenominator: Bool {
        guard let problem = viewModel.currentProblem,
              case .twoFieldFraction(let allow) = problem.inputKind else { return false }
        return allow
    }

    @ViewBuilder
    private var bottomRowSpecialKey: some View {
        if isFractionMode {
            // Decimal point is useful only in Mode 4 (where the answer can be a
            // single decimal like 0.75 or a percentage like 75 in the numerator field).
            if allowEmptyDenominator {
                NumberButton(label: ".", variant: .secondary) {
                    viewModel.appendDigit(".")
                }
            } else {
                Color.clear.frame(height: 52)
            }
        } else if settings.negativesEnabled {
            NumberButton(label: "+/-", variant: .secondary) {
                viewModel.appendDigit("-")
            }
        } else {
            NumberButton(label: ".", variant: .secondary) {
                viewModel.appendDigit(".")
            }
        }
    }

    // MARK: - Fraction fields

    @ViewBuilder
    private var fractionFieldStack: some View {
        if case .fraction(let num, let den, let active) = viewModel.userInput {
            VStack(spacing: 6) {
                FractionFieldButton(
                    label: num.isEmpty ? "Numerator" : num,
                    isActive: active == .numerator,
                    isPlaceholder: num.isEmpty
                ) {
                    viewModel.setActiveField(.numerator)
                }

                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 30)

                FractionFieldButton(
                    label: den.isEmpty
                        ? (allowEmptyDenominator ? "Denominator (optional)" : "Denominator")
                        : den,
                    isActive: active == .denominator,
                    isPlaceholder: den.isEmpty
                ) {
                    viewModel.setActiveField(.denominator)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 6)
        }
    }
}

// MARK: - Number Button

struct NumberButton: View {
    let label: String
    var variant: Variant = .primary
    let action: () -> Void

    enum Variant {
        case primary, secondary
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    variant == .primary
                        ? Color(.systemGray5)
                        : Color(.systemGray4),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Fraction Field Button

struct FractionFieldButton: View {
    let label: String
    let isActive: Bool
    let isPlaceholder: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title3.bold())
                .foregroundStyle(isPlaceholder ? .secondary : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Color(.systemGray6),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive ? .indigo : .clear, lineWidth: 2)
                }
        }
    }
}
