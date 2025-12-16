import SwiftUI

struct RepsPickerView: View {
    @Binding var reps: Int
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReps: Int

    init(reps: Binding<Int>) {
        self._reps = reps
        _selectedReps = State(initialValue: reps.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Repetitions", selection: $selectedReps) {
                    ForEach(1...20, id: \.self) { rep in
                        Text("\(rep)")
                            .tag(rep)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                .padding(.top, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    Image("Background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .offset(x: -500)
                    AppColors.tan.opacity(0.85)
                }
                .ignoresSafeArea()
            }
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
