import SwiftUI

/// App color palette - climbing-themed colors
public enum AppColors {
    // MARK: - Primary Colors

    /// Light Brown (Sandstone) - #C4A484
    public static let sandstone = Color(red: 196/255, green: 164/255, blue: 132/255)

    /// Woodland Green - #4A5D23
    public static let woodlandGreen = Color(red: 74/255, green: 93/255, blue: 35/255)

    // MARK: - Supporting Colors

    /// Deep Brown (Granite) - #5C4033
    public static let granite = Color(red: 92/255, green: 64/255, blue: 51/255)

    /// Cream (Chalk) - #F5F1EB
    public static let chalk = Color(red: 245/255, green: 241/255, blue: 235/255)

    /// Warm White - #FDFCFA
    public static let warmWhite = Color(red: 253/255, green: 252/255, blue: 250/255)

    /// Tan (darker than chalk, lighter than sandstone) - #D4C4B0
    public static let tan = Color(red: 212/255, green: 196/255, blue: 176/255)

    /// Dark Brown (very dark, for headings) - #3D2B1F
    public static let darkBrown = Color(red: 61/255, green: 43/255, blue: 31/255)

    // MARK: - Accent Colors

    /// Rust Orange - #B85C38
    public static let rust = Color(red: 184/255, green: 92/255, blue: 56/255)

    /// Slate Blue - #6B7B8C
    public static let slate = Color(red: 107/255, green: 123/255, blue: 140/255)

    // MARK: - Functional Colors

    /// Success - #5E8B4C
    public static let success = Color(red: 94/255, green: 139/255, blue: 76/255)

    /// Warning - #D4A03D
    public static let warning = Color(red: 212/255, green: 160/255, blue: 61/255)

    /// Error - #C45B4A
    public static let error = Color(red: 196/255, green: 91/255, blue: 74/255)

    // MARK: - Timer Phase Colors

    /// Countdown phase - uses rust orange
    public static let countdown = rust

    /// Work phase - uses woodland green
    public static let work = woodlandGreen

    /// Rest phase - uses slate blue
    public static let rest = slate

    /// Finished phase - uses granite
    public static let finished = granite
}
