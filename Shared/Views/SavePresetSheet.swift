import SwiftUI

struct SavePresetSheet: View {
    @State private var viewModel = SavePresetSheetViewModel()
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter a name for your preset")
                    .font(.custom("AvenirNext-Regular", size: 17))
                    .foregroundStyle(AppColors.granite)

                TextField("Preset Name", text: $viewModel.presetName)
                    .font(.custom("AvenirNext-Medium", size: 17))
                    #if os(iOS)
                    .textFieldStyle(.roundedBorder)
                    #endif
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Save Preset")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(AppColors.granite)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(viewModel.presetName)
                    }
                    .disabled(!viewModel.canSave)
                    .foregroundStyle(viewModel.canSave ? AppColors.woodlandGreen : AppColors.granite.opacity(0.5))
                }
            }
            .background(AppColors.chalk)
        }
        #if os(iOS)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
        #endif
    }
}
