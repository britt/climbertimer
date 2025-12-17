import SwiftUI

struct DurationPickerView: View {
    @Binding var duration: TimeInterval
    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    let title: String
    private let itemHeight: CGFloat = 44
    private let visibleItems = 5

    init(title: String, duration: Binding<TimeInterval>) {
        self.title = title
        self._duration = duration

        let totalSeconds = Int(duration.wrappedValue)
        _hours = State(initialValue: totalSeconds / 3600)
        _minutes = State(initialValue: (totalSeconds % 3600) / 60)
        _seconds = State(initialValue: totalSeconds % 60)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.custom("AvenirNext-Regular", size: 17))
                        .foregroundStyle(AppColors.granite)
                }

                Spacer()

                Text(title)
                    .font(.custom("AvenirNextCondensed-Bold", size: 20))
                    .foregroundStyle(AppColors.darkBrown)

                Spacer()

                Button {
                    duration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.custom("AvenirNext-DemiBold", size: 17))
                        .foregroundStyle(AppColors.granite)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Picker content
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    SilentWheelPicker(selection: $hours, items: Array(0..<24), cornerStyle: .left)
                        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

                    SilentWheelPicker(selection: $minutes, items: Array(0..<60), cornerStyle: .none)
                        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))

                    SilentWheelPicker(selection: $seconds, items: Array(0..<60), cornerStyle: .right)
                        .frame(width: 80, height: itemHeight * CGFloat(visibleItems))
                }

                Rectangle()
                    .fill(AppColors.granite.opacity(0.3))
                    .frame(width: 240, height: 1)
                    .padding(.top, 8)

                HStack(spacing: 0) {
                    Text("hours")
                        .frame(width: 80)
                    Text("min")
                        .frame(width: 80)
                    Text("sec")
                        .frame(width: 80)
                }
                .font(.custom("AvenirNext-DemiBold", size: 15))
                .foregroundStyle(AppColors.granite)
                .padding(.top, 8)
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum PickerCornerStyle {
    case all
    case left
    case right
    case none
}

struct SilentWheelPicker: View {
    @Binding var selection: Int
    let items: [Int]
    var cornerStyle: PickerCornerStyle = .all

    private let itemHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 8
    @State private var scrollPosition: Int?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // Top padding
                    Color.clear.frame(height: geometry.size.height / 2 - itemHeight / 2)

                    ForEach(items, id: \.self) { item in
                        Text("\(item)")
                            .font(.custom("AvenirNext-Medium", size: 22))
                            .foregroundStyle(AppColors.granite)
                            .frame(height: itemHeight)
                            .frame(maxWidth: .infinity)
                            .id(item)
                    }

                    // Bottom padding
                    Color.clear.frame(height: geometry.size.height / 2 - itemHeight / 2)
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .scrollTargetBehavior(.viewAligned)
            .onAppear {
                scrollPosition = selection
            }
            .onChange(of: scrollPosition) { _, newValue in
                if let newValue {
                    selection = newValue
                }
            }
            .onChange(of: selection) { _, newValue in
                if scrollPosition != newValue {
                    scrollPosition = newValue
                }
            }
            .overlay {
                // Selection indicator
                selectionIndicator
                    .frame(height: itemHeight)
                    .allowsHitTesting(false)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        switch cornerStyle {
        case .all:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.granite.opacity(0.15))
        case .left:
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
            .fill(AppColors.granite.opacity(0.15))
        case .right:
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: cornerRadius
            )
            .fill(AppColors.granite.opacity(0.15))
        case .none:
            Rectangle()
                .fill(AppColors.granite.opacity(0.15))
        }
    }
}
