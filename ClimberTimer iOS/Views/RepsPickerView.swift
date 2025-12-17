import SwiftUI

struct RepsPickerView: View {
    @Binding var reps: Int
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReps: Int
    private let itemHeight: CGFloat = 44
    private let visibleItems = 5

    init(reps: Binding<Int>) {
        self._reps = reps
        _selectedReps = State(initialValue: reps.wrappedValue)
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

                Text("Repetitions")
                    .font(.custom("AvenirNextCondensed-Bold", size: 20))
                    .foregroundStyle(AppColors.darkBrown)

                Spacer()

                Button {
                    reps = selectedReps
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

            SilentWheelPicker(selection: $selectedReps, items: Array(1...20), cornerStyle: .all)
                .frame(width: 100, height: itemHeight * CGFloat(visibleItems))
                .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.tan)
    }
}
