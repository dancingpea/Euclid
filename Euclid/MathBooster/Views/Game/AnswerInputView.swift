import SwiftUI

struct AnswerInputView: View {
    var viewModel: GameViewModel
    let settings: UserSettings

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 10) {
            // Number grid: 1-9
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...9, id: \.self) { digit in
                    NumberButton(label: "\(digit)") {
                        viewModel.appendDigit("\(digit)")
                    }
                }
            }

            // Bottom row: special keys
            LazyVGrid(columns: columns, spacing: 10) {
                // Negative toggle (if enabled)
                if settings.negativesEnabled {
                    NumberButton(label: "+/-", variant: .secondary) {
                        viewModel.appendDigit("-")
                    }
                } else {
                    NumberButton(label: ".", variant: .secondary) {
                        viewModel.appendDigit(".")
                    }
                }

                // Zero
                NumberButton(label: "0") {
                    viewModel.appendDigit("0")
                }

                // Delete
                NumberButton(label: "Del", variant: .secondary) {
                    viewModel.deleteLastDigit()
                }
            }

            // Extra row if both negatives and decimals are enabled
            if settings.negativesEnabled && settings.decimalsEnabled {
                HStack(spacing: 12) {
                    NumberButton(label: ".", variant: .secondary) {
                        viewModel.appendDigit(".")
                    }
                }
                .frame(maxWidth: .infinity)
            } else if !settings.negativesEnabled && settings.decimalsEnabled {
                // Decimal already shown in place of +/-
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
