import SwiftUI

enum DesignSystem {

    // MARK: - Colors (from DESIGN.md Mistral palette)

    enum Colors {
        static let primary = Color(hex: "#fa520f")
        static let primaryDeep = Color(hex: "#cc3a05")

        static let sunshine300 = Color(hex: "#ffd06a")
        static let sunshine500 = Color(hex: "#ffb83e")
        static let sunshine700 = Color(hex: "#ffa110")
        static let sunshine800 = Color(hex: "#ff8105")
        static let sunshine900 = Color(hex: "#ff8a00")
        static let yellowSaturated = Color(hex: "#ffd900")

        static let cream = Color(hex: "#fff8e0")
        static let creamLight = Color(hex: "#fffaeb")
        static let creamDeeper = Color(hex: "#fff0c2")
        static let beigeDeep = Color(hex: "#e6d5a8")

        static let ink = Color(hex: "#1f1f1f")
        static let inkTint = Color(hex: "#3d3d3d")
        static let charcoal = Color(hex: "#2c2c2c")
        static let slate = Color(hex: "#4a4a4a")
        static let steel = Color(hex: "#6a6a6a")
        static let stone = Color(hex: "#8a8a8a")
        static let muted = Color(hex: "#a8a8a8")

        static let hairline = Color(hex: "#e5e5e5")
        static let hairlineSoft = Color(hex: "#ededed")
        static let hairlineStrong = Color(hex: "#c7c7c7")

        static let canvas = Color(hex: "#ffffff")
        static let surface = Color(hex: "#fafafa")
        static let surfaceCode = Color(hex: "#1c1c1e")

        static let sunsetGradient = LinearGradient(
            colors: [primary, sunshine700, sunshine500, yellowSaturated, cream],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Typography

    enum Typography {
        static func heroDisplay() -> Font {
            .system(size: 40, weight: .regular, design: .serif)
        }
        static func displayLg() -> Font {
            .system(size: 32, weight: .regular, design: .serif)
        }
        static func heading1() -> Font {
            .system(size: 28, weight: .regular, design: .serif)
        }
        static func heading2() -> Font {
            .system(size: 22, weight: .medium)
        }
        static func heading3() -> Font {
            .system(size: 20, weight: .medium)
        }
        static func heading4() -> Font {
            .system(size: 18, weight: .medium)
        }
        static func subtitle() -> Font {
            .system(size: 16, weight: .regular)
        }
        static func bodyMd() -> Font {
            .system(size: 15, weight: .regular)
        }
        static func bodyMdMedium() -> Font {
            .system(size: 15, weight: .medium)
        }
        static func bodySm() -> Font {
            .system(size: 13, weight: .regular)
        }
        static func bodySmMedium() -> Font {
            .system(size: 13, weight: .medium)
        }
        static func caption() -> Font {
            .system(size: 12, weight: .regular)
        }
        static func captionBold() -> Font {
            .system(size: 12, weight: .semibold)
        }
        static func micro() -> Font {
            .system(size: 11, weight: .medium)
        }
        static func buttonMd() -> Font {
            .system(size: 14, weight: .medium)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let section: CGFloat = 64
    }

    // MARK: - Radius

    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let full: CGFloat = 9999
    }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
