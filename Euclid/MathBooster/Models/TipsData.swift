import Foundation

// MARK: - Data Structures

struct TipCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String // matches app's color naming
    let tips: [Tip]
}

struct Tip: Identifiable {
    let id = UUID()
    let title: String
    let level: TipLevel
    let explanation: String
    let examples: [TipExample]
}

enum TipLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }
}

struct TipExample {
    let problem: String
    let steps: [String]
    let result: String
}

// MARK: - All Tips Content

struct TipsData {

    static let creditText = "Advanced techniques (cross-multiplication, cross-division, square root estimation) adapted from worldmentalcalculation.com by Daniel Timms."
    static let creditURL = URL(string: "https://worldmentalcalculation.com")!

    static let categories: [TipCategory] = [
        additionCategory,
        subtractionCategory,
        multiplicationCategory,
        divisionCategory,
        bonusCategory,
        trainingCategory
    ]

    // MARK: - Addition

    static let additionCategory = TipCategory(
        name: "Addition",
        icon: "plus.circle.fill",
        color: "indigo",
        tips: [
            Tip(
                title: "Left-to-Right Addition",
                level: .beginner,
                explanation: "Instead of adding from the units digit like on paper, work left to right — the way you naturally read numbers. This lets you think the answer progressively.",
                examples: [
                    TipExample(
                        problem: "347 + 218",
                        steps: [
                            "300 + 200 = 500",
                            "40 + 10 = 50 → running total: 550",
                            "7 + 8 = 15 → 550 + 15"
                        ],
                        result: "565"
                    )
                ]
            ),
            Tip(
                title: "Round and Compensate",
                level: .beginner,
                explanation: "Round one number up to something easy, add, then subtract the difference. Works best when a number ends in 7, 8, 9 or 1, 2, 3.",
                examples: [
                    TipExample(
                        problem: "67 + 38",
                        steps: [
                            "Round 38 up to 40",
                            "67 + 40 = 107",
                            "Subtract the 2 you added: 107 − 2"
                        ],
                        result: "105"
                    ),
                    TipExample(
                        problem: "456 + 297",
                        steps: [
                            "Round 297 up to 300",
                            "456 + 300 = 756",
                            "Subtract 3: 756 − 3"
                        ],
                        result: "753"
                    )
                ]
            ),
            Tip(
                title: "Grouping to Make 10s",
                level: .beginner,
                explanation: "When adding several numbers, look for pairs that make 10 (or 100) and group them first.",
                examples: [
                    TipExample(
                        problem: "7 + 4 + 6 + 3 + 8 + 2",
                        steps: [
                            "Spot the pairs: (7+3), (4+6), (8+2)",
                            "10 + 10 + 10"
                        ],
                        result: "30"
                    ),
                    TipExample(
                        problem: "25 + 47 + 75 + 53",
                        steps: [
                            "(25 + 75) + (47 + 53)",
                            "100 + 100"
                        ],
                        result: "200"
                    )
                ]
            ),
            Tip(
                title: "Break and Bridge",
                level: .intermediate,
                explanation: "Break the second number into parts that bridge through a round number. Use part of it to reach the nearest hundred, then add the rest.",
                examples: [
                    TipExample(
                        problem: "86 + 37",
                        steps: [
                            "86 + 14 = 100 (use 14 of the 37)",
                            "37 − 14 = 23 remaining",
                            "100 + 23"
                        ],
                        result: "123"
                    ),
                    TipExample(
                        problem: "748 + 176",
                        steps: [
                            "748 + 52 = 800",
                            "176 − 52 = 124 remaining",
                            "800 + 124"
                        ],
                        result: "924"
                    )
                ]
            ),
            Tip(
                title: "Column-by-Column (Large Numbers)",
                level: .intermediate,
                explanation: "For multi-digit additions, add each place value separately from left to right, carrying mentally as you go.",
                examples: [
                    TipExample(
                        problem: "4,837 + 2,694",
                        steps: [
                            "Thousands: 4 + 2 = 6 → 6,000",
                            "Hundreds: 8 + 6 = 14 → +1,400 → 7,400",
                            "Tens: 3 + 9 = 12 → +120 → 7,520",
                            "Units: 7 + 4 = 11 → +11"
                        ],
                        result: "7,531"
                    )
                ]
            )
        ]
    )

    // MARK: - Subtraction

    static let subtractionCategory = TipCategory(
        name: "Subtraction",
        icon: "minus.circle.fill",
        color: "indigo",
        tips: [
            Tip(
                title: "Round and Compensate",
                level: .beginner,
                explanation: "Round the number you're subtracting to something easy, then add back the difference.",
                examples: [
                    TipExample(
                        problem: "83 − 47",
                        steps: [
                            "Round 47 up to 50",
                            "83 − 50 = 33",
                            "Add back the 3"
                        ],
                        result: "36"
                    ),
                    TipExample(
                        problem: "612 − 398",
                        steps: [
                            "Round 398 up to 400",
                            "612 − 400 = 212",
                            "Add back 2"
                        ],
                        result: "214"
                    )
                ]
            ),
            Tip(
                title: "Thinking Addition",
                level: .beginner,
                explanation: "Instead of subtracting, ask: \"What do I add to the smaller number to reach the bigger one?\" Count up in easy steps.",
                examples: [
                    TipExample(
                        problem: "83 − 47",
                        steps: [
                            "Think: 47 + ? = 83",
                            "47 + 3 = 50",
                            "50 + 30 = 80",
                            "80 + 3 = 83",
                            "Total added: 3 + 30 + 3"
                        ],
                        result: "36"
                    )
                ]
            ),
            Tip(
                title: "Left-to-Right Subtraction",
                level: .intermediate,
                explanation: "Subtract from the largest place value first. When a digit subtraction goes negative, subtract 1 from the running total and add 10 to compensate — like borrowing, but in your head.",
                examples: [
                    TipExample(
                        problem: "742 − 258",
                        steps: [
                            "700 − 200 = 500",
                            "40 − 50 = −10 → adjust to 490",
                            "2 − 8 = −6 → adjust to 484"
                        ],
                        result: "484"
                    )
                ]
            ),
            Tip(
                title: "Equal Additions (Balancing)",
                level: .intermediate,
                explanation: "Add the same amount to both numbers so the subtraction becomes easier. The difference stays the same.",
                examples: [
                    TipExample(
                        problem: "534 − 278",
                        steps: [
                            "Add 2 to both numbers",
                            "536 − 280",
                            "Much easier to compute"
                        ],
                        result: "256"
                    )
                ]
            ),
            Tip(
                title: "9s Complement (Powers of 10)",
                level: .intermediate,
                explanation: "To subtract from 1000, 10000, etc.: subtract each digit from 9, except the last digit which you subtract from 10. No borrowing needed.",
                examples: [
                    TipExample(
                        problem: "1000 − 637",
                        steps: [
                            "9 − 6 = 3",
                            "9 − 3 = 6",
                            "10 − 7 = 3"
                        ],
                        result: "363"
                    ),
                    TipExample(
                        problem: "10000 − 4528",
                        steps: [
                            "9 − 4 = 5",
                            "9 − 5 = 4",
                            "9 − 2 = 7",
                            "10 − 8 = 2"
                        ],
                        result: "5,472"
                    )
                ]
            )
        ]
    )

    // MARK: - Multiplication

    static let multiplicationCategory = TipCategory(
        name: "Multiplication",
        icon: "multiply.circle.fill",
        color: "indigo",
        tips: [
            Tip(
                title: "Break Apart",
                level: .beginner,
                explanation: "Split one number into easy parts (tens and units) and multiply each separately, then add.",
                examples: [
                    TipExample(
                        problem: "24 × 7",
                        steps: [
                            "20 × 7 = 140",
                            "4 × 7 = 28",
                            "140 + 28"
                        ],
                        result: "168"
                    ),
                    TipExample(
                        problem: "53 × 6",
                        steps: [
                            "50 × 6 = 300",
                            "3 × 6 = 18",
                            "300 + 18"
                        ],
                        result: "318"
                    )
                ]
            ),
            Tip(
                title: "Multiply by 9, 99, 999…",
                level: .beginner,
                explanation: "Multiply by the next power of 10, then subtract once.",
                examples: [
                    TipExample(
                        problem: "46 × 9",
                        steps: [
                            "46 × 10 = 460",
                            "460 − 46"
                        ],
                        result: "414"
                    ),
                    TipExample(
                        problem: "34 × 99",
                        steps: [
                            "34 × 100 = 3,400",
                            "3,400 − 34"
                        ],
                        result: "3,366"
                    )
                ]
            ),
            Tip(
                title: "Doubling and Halving",
                level: .beginner,
                explanation: "If one number is even, halve it and double the other. Repeat until one factor is trivial.",
                examples: [
                    TipExample(
                        problem: "48 × 5",
                        steps: [
                            "Halve 48 → 24, double 5 → 10",
                            "24 × 10"
                        ],
                        result: "240"
                    ),
                    TipExample(
                        problem: "16 × 35",
                        steps: [
                            "8 × 70",
                            "4 × 140",
                            "2 × 280",
                            "1 × 560"
                        ],
                        result: "560"
                    )
                ]
            ),
            Tip(
                title: "Shortcuts: ×5, ×25, ×50, ×125",
                level: .beginner,
                explanation: "Turn multiplication into division by using powers of 10:\n×5 = ×10 ÷ 2\n×25 = ×100 ÷ 4\n×50 = ×100 ÷ 2\n×125 = ×1000 ÷ 8",
                examples: [
                    TipExample(
                        problem: "48 × 25",
                        steps: [
                            "48 × 100 = 4,800",
                            "4,800 ÷ 4"
                        ],
                        result: "1,200"
                    )
                ]
            ),
            Tip(
                title: "Squaring Numbers Ending in 5",
                level: .intermediate,
                explanation: "Multiply the tens digit by (tens digit + 1), then append 25.",
                examples: [
                    TipExample(
                        problem: "35²",
                        steps: [
                            "3 × 4 = 12",
                            "Append 25"
                        ],
                        result: "1,225"
                    ),
                    TipExample(
                        problem: "85²",
                        steps: [
                            "8 × 9 = 72",
                            "Append 25"
                        ],
                        result: "7,225"
                    )
                ]
            ),
            Tip(
                title: "Squaring Numbers Near 50",
                level: .intermediate,
                explanation: "Find the distance from 50. Add that distance to 25 for the hundreds part, then square the distance for the last two digits (always two digits).",
                examples: [
                    TipExample(
                        problem: "53²",
                        steps: [
                            "Distance from 50: +3",
                            "25 + 3 = 28 (hundreds)",
                            "3² = 09 (two digits)"
                        ],
                        result: "2,809"
                    ),
                    TipExample(
                        problem: "47²",
                        steps: [
                            "Distance from 50: −3",
                            "25 − 3 = 22",
                            "3² = 09"
                        ],
                        result: "2,209"
                    )
                ]
            ),
            Tip(
                title: "Multiplying Near 100",
                level: .intermediate,
                explanation: "For two numbers close to 100: find each distance from 100, add one number to the other's distance for the left part, multiply the two distances for the right part (two digits).",
                examples: [
                    TipExample(
                        problem: "97 × 94",
                        steps: [
                            "Distances: −3 and −6",
                            "97 − 6 = 91 (left part)",
                            "3 × 6 = 18 (right part)"
                        ],
                        result: "9,118"
                    ),
                    TipExample(
                        problem: "103 × 107",
                        steps: [
                            "Distances: +3 and +7",
                            "103 + 7 = 110",
                            "3 × 7 = 21"
                        ],
                        result: "11,021"
                    )
                ]
            ),
            Tip(
                title: "Anchor Method (Difference of Squares)",
                level: .intermediate,
                explanation: "When two numbers are close together, pick their midpoint as an anchor. Use the identity: (a−b)(a+b) = a² − b²",
                examples: [
                    TipExample(
                        problem: "23 × 27",
                        steps: [
                            "Anchor: 25 (midpoint)",
                            "23 = 25 − 2, 27 = 25 + 2",
                            "25² − 2² = 625 − 4"
                        ],
                        result: "621"
                    )
                ]
            ),
            Tip(
                title: "Cross-Multiplication",
                level: .advanced,
                explanation: "The method used by competition calculators for large numbers. You build the answer one digit at a time. For each position, multiply all digit pairs whose place values add up to that position, sum them, write the units digit, carry the rest.\n\nYou only need single-digit times tables (up to 9×9).",
                examples: [
                    TipExample(
                        problem: "473 × 826",
                        steps: [
                            "Pos 1 (units): 3×6 = 18 → write 8, carry 1",
                            "Pos 2 (tens): 1 + 7×6 + 3×2 = 49 → write 9, carry 4",
                            "Pos 3 (hundreds): 4 + 4×6 + 7×2 + 3×8 = 66 → write 6, carry 6",
                            "Pos 4 (thousands): 6 + 4×2 + 7×8 = 70 → write 0, carry 7",
                            "Pos 5: 7 + 4×8 = 39 → write 9, carry 3",
                            "Pos 6: write 3"
                        ],
                        result: "390,698"
                    )
                ]
            )
        ]
    )

    // MARK: - Division

    static let divisionCategory = TipCategory(
        name: "Division",
        icon: "divide.circle.fill",
        color: "indigo",
        tips: [
            Tip(
                title: "Related Multiplication",
                level: .beginner,
                explanation: "Reframe division as multiplication: \"How many times does X fit into Y?\" Build up using easy multiples.",
                examples: [
                    TipExample(
                        problem: "156 ÷ 12",
                        steps: [
                            "12 × 10 = 120",
                            "12 × 3 = 36",
                            "120 + 36 = 156 ✓",
                            "10 + 3"
                        ],
                        result: "13"
                    )
                ]
            ),
            Tip(
                title: "Halving Chains",
                level: .beginner,
                explanation: "To divide by 4, halve twice. To divide by 8, halve three times.",
                examples: [
                    TipExample(
                        problem: "248 ÷ 4",
                        steps: [
                            "248 ÷ 2 = 124",
                            "124 ÷ 2"
                        ],
                        result: "62"
                    ),
                    TipExample(
                        problem: "720 ÷ 8",
                        steps: [
                            "720 ÷ 2 = 360",
                            "360 ÷ 2 = 180",
                            "180 ÷ 2"
                        ],
                        result: "90"
                    )
                ]
            ),
            Tip(
                title: "Shortcuts: ÷5, ÷25, ÷50",
                level: .beginner,
                explanation: "Turn division into multiplication:\n÷5 = ÷10 × 2\n÷25 = ÷100 × 4\n÷50 = ÷100 × 2",
                examples: [
                    TipExample(
                        problem: "435 ÷ 5",
                        steps: [
                            "435 ÷ 10 = 43.5",
                            "43.5 × 2"
                        ],
                        result: "87"
                    ),
                    TipExample(
                        problem: "1,300 ÷ 25",
                        steps: [
                            "1,300 ÷ 100 = 13",
                            "13 × 4"
                        ],
                        result: "52"
                    )
                ]
            ),
            Tip(
                title: "Chunking (Partial Quotients)",
                level: .intermediate,
                explanation: "Subtract easy multiples of the divisor and count how many you removed. Great for larger divisions.",
                examples: [
                    TipExample(
                        problem: "936 ÷ 36",
                        steps: [
                            "36 × 20 = 720",
                            "936 − 720 = 216",
                            "36 × 6 = 216",
                            "216 − 216 = 0",
                            "20 + 6"
                        ],
                        result: "26"
                    )
                ]
            ),
            Tip(
                title: "Simplify First",
                level: .intermediate,
                explanation: "If both numbers share a common factor, divide both by it first to work with smaller numbers.",
                examples: [
                    TipExample(
                        problem: "270 ÷ 45",
                        steps: [
                            "Both divisible by 9",
                            "30 ÷ 5"
                        ],
                        result: "6"
                    ),
                    TipExample(
                        problem: "840 ÷ 35",
                        steps: [
                            "Both divisible by 7",
                            "120 ÷ 5"
                        ],
                        result: "24"
                    )
                ]
            ),
            Tip(
                title: "Estimation by Friendly Numbers",
                level: .intermediate,
                explanation: "Replace the divisor with a nearby round number to get a quick estimate, then adjust. Since you used a bigger divisor, the real answer is slightly larger (and vice versa).",
                examples: [
                    TipExample(
                        problem: "4,590 ÷ 47",
                        steps: [
                            "47 ≈ 50",
                            "4,590 ÷ 50 = 91.8",
                            "47 < 50, so real answer is a bit larger",
                            "Check: 47 × 97 = 4,559 (close)"
                        ],
                        result: "≈ 97.7"
                    )
                ]
            ),
            Tip(
                title: "Cross-Division",
                level: .advanced,
                explanation: "The competition method for dividing by multi-digit numbers. Use the first 2 digits of the divisor as your \"working divisor,\" then apply corrections for the remaining digits at each step.\n\nThis minimizes working memory — you only track one remainder at a time.",
                examples: [
                    TipExample(
                        problem: "1,829 ÷ 7.6543",
                        steps: [
                            "Working divisor: 76, correction digits: 5, 4, 3",
                            "Step 1: 182 ÷ 76 → 2 (rem 30) → 309 − (5×2) = 299",
                            "Step 2: 299 ÷ 76 → 3 (rem 71) → 710 − (5×3) − (4×2) = 687",
                            "Step 3: 687 ÷ 76 → 8, continue pattern…"
                        ],
                        result: "238.95…"
                    )
                ]
            )
        ]
    )

    // MARK: - Bonus

    static let bonusCategory = TipCategory(
        name: "Square Roots",
        icon: "x.squareroot",
        color: "indigo",
        tips: [
            Tip(
                title: "Newton's Approximation",
                level: .advanced,
                explanation: "Estimate any square root in seconds:\n1. Pick a nearby perfect square as your guess\n2. Find the difference: guess² − target\n3. Divide by 2 × guess\n4. Subtract from your guess\n\nA better initial guess gives dramatically better accuracy — 10× closer guess → 100× closer result.",
                examples: [
                    TipExample(
                        problem: "√59.6",
                        steps: [
                            "Guess: 8 (since 8² = 64)",
                            "Difference: 64 − 59.6 = 4.4",
                            "Correction: 4.4 ÷ 16 = 0.275",
                            "8 − 0.275"
                        ],
                        result: "7.725 (actual: 7.7201…)"
                    )
                ]
            )
        ]
    )

    // MARK: - Training Tips

    static let trainingCategory = TipCategory(
        name: "Training Tips",
        icon: "brain.head.profile",
        color: "indigo",
        tips: [
            Tip(
                title: "Master Your Basics",
                level: .beginner,
                explanation: "Know single-digit additions and times tables (2×2 through 9×9) with instant recall — no hesitation. Everything else builds on this foundation.",
                examples: []
            ),
            Tip(
                title: "Practice Blind",
                level: .beginner,
                explanation: "Train with numbers stored in your mind, not on the page. This builds the working memory that mental math depends on. When you can solve problems without looking at the numbers, you've leveled up.",
                examples: []
            ),
            Tip(
                title: "Accuracy Before Speed",
                level: .beginner,
                explanation: "Speed comes naturally with practice. Rushing creates bad habits that are hard to fix. Focus on getting it right every time, and the pace will follow.",
                examples: []
            ),
            Tip(
                title: "Track Your Progress",
                level: .intermediate,
                explanation: "Time yourself regularly and note your accuracy. When you plateau, change one detail of your method rather than just practicing harder. Use the Stats tab to spot trends.",
                examples: []
            ),
            Tip(
                title: "Train in Short Bursts",
                level: .intermediate,
                explanation: "Mental calculation is cognitively demanding. Train in focused sessions of 15–30 minutes rather than long marathons. Your brain needs rest to consolidate what you've learned.",
                examples: []
            ),
            Tip(
                title: "Stay Fueled",
                level: .intermediate,
                explanation: "Your brain uses significant glucose during intense calculation. Stay hydrated and have a small snack before practice. Short sessions with breaks work better than exhausting ones.",
                examples: []
            )
        ]
    )
}
