import SwiftUI

struct SavePresetSheet: View {
    @State private var presetName = ""
    let onSave: (String) -> Void
    let onCancel: () -> Void

    private var canSave: Bool {
        !presetName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Enter a name for your preset")
                    .font(.custom("AvenirNext-Regular", size: 17))
                    .foregroundStyle(AppColors.granite)

                TextField("Preset Name", text: $presetName)
                    .font(.custom("AvenirNext-Medium", size: 17))
                    .foregroundStyle(AppColors.granite)
                    #if os(iOS)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(AppColors.warmWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.tan, lineWidth: 1)
                    )
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
                        onSave(presetName)
                    }
                    .disabled(!canSave)
                    .foregroundStyle(canSave ? AppColors.woodlandGreen : AppColors.granite.opacity(0.5))
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
