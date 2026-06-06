import SwiftUI

// MARK: - Primary Button

struct CuratedButton: View {
    let title: String
    let style: Style
    let action: () -> Void

    enum Style {
        case primary, cream, dark, secondary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.buttonMd())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .stroke(borderColor, lineWidth: hasBorder ? 1 : 0)
                )
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .cream: return DesignSystem.Colors.ink
        case .dark: return .white
        case .secondary: return DesignSystem.Colors.ink
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return DesignSystem.Colors.primary
        case .cream: return DesignSystem.Colors.cream
        case .dark: return DesignSystem.Colors.ink
        case .secondary: return .clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .dark: return .clear
        case .cream: return DesignSystem.Colors.beigeDeep
        case .secondary: return DesignSystem.Colors.hairlineStrong
        }
    }

    private var hasBorder: Bool {
        style == .cream || style == .secondary
    }
}

// MARK: - Card

struct CuratedCard<Content: View>: View {
    let style: Style
    @ViewBuilder let content: () -> Content

    enum Style {
        case base, cream, feature
    }

    var body: some View {
        content()
            .padding(style == .base ? DesignSystem.Spacing.xl : DesignSystem.Spacing.xxl)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(borderColor, lineWidth: 1)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case .base, .feature: return DesignSystem.Colors.canvas
        case .cream: return DesignSystem.Colors.cream
        }
    }

    private var borderColor: Color {
        switch style {
        case .base, .feature: return DesignSystem.Colors.hairlineSoft
        case .cream: return DesignSystem.Colors.beigeDeep
        }
    }
}

// MARK: - Badge

struct CuratedBadge: View {
    let text: String
    let style: Style

    enum Style {
        case orange, cream, dark
    }

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.captionBold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch style {
        case .orange, .dark: return .white
        case .cream: return DesignSystem.Colors.ink
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .orange: return DesignSystem.Colors.primary
        case .cream: return DesignSystem.Colors.creamDeeper
        case .dark: return DesignSystem.Colors.ink
        }
    }
}

// MARK: - Sunset Stripe

struct SunsetStripe: View {
    var body: some View {
        Rectangle()
            .fill(DesignSystem.Colors.sunsetGradient)
            .frame(height: 6)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.heading3())
                .foregroundColor(DesignSystem.Colors.ink)
            if let subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.bodySm())
                    .foregroundColor(DesignSystem.Colors.steel)
            }
        }
    }
}
