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
        NavigationStack {
            VStack(spacing: 0) {
                SilentWheelPicker(selection: $selectedReps, items: Array(1...20))
                    .frame(width: 100, height: itemHeight * CGFloat(visibleItems))
                    .padding(.top, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("AvenirNext-Regular", size: 17))
                    .foregroundStyle(AppColors.granite)
                }
                ToolbarItem(placement: .principal) {
                    Text("Repetitions")
                        .font(.custom("AvenirNextCondensed-Bold", size: 20))
                        .foregroundStyle(AppColors.darkBrown)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        reps = selectedReps
                        dismiss()
                    }
                    .font(.custom("AvenirNext-DemiBold", size: 17))
                    .foregroundStyle(AppColors.granite)
                }
            }
        }
    }
}
