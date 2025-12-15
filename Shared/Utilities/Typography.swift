import SwiftUI

/// App typography system
public enum Typography {
    // MARK: - Large Titles (Avenir Next Condensed)

    public static let largeTitle = Font.custom("AvenirNextCondensed-Bold", size: 34)
    public static let title = Font.custom("AvenirNextCondensed-DemiBold", size: 28)
    public static let title2 = Font.custom("AvenirNextCondensed-DemiBold", size: 22)
    public static let title3 = Font.custom("AvenirNextCondensed-DemiBold", size: 20)

    // MARK: - Section Headers (Avenir Next Condensed)

    public static let sectionHeader = Font.custom("AvenirNextCondensed-DemiBold", size: 17)
    public static let headline = Font.custom("AvenirNextCondensed-DemiBold", size: 17)

    // MARK: - Body Text (Avenir Next)

    public static let body = Font.custom("AvenirNext-Regular", size: 17)
    public static let callout = Font.custom("AvenirNext-Regular", size: 16)
    public static let subheadline = Font.custom("AvenirNext-Regular", size: 15)

    // MARK: - Stats/Grades (Menlo)

    public static let timer = Font.custom("Menlo-Bold", size: 96)
    public static let timerSmall = Font.custom("Menlo-Bold", size: 48)
    public static let stat = Font.custom("Menlo-Bold", size: 28)
    public static let statSmall = Font.custom("Menlo-Bold", size: 20)

    // MARK: - Captions (Avenir Next)

    public static let caption = Font.custom("AvenirNext-Regular", size: 12)
    public static let caption2 = Font.custom("AvenirNext-Regular", size: 11)

    // MARK: - Buttons

    public static let buttonLarge = Font.custom("AvenirNextCondensed-Bold", size: 22)
    public static let button = Font.custom("AvenirNext-DemiBold", size: 17)
}
