import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Spacer()

                Text("Settings")
                    .font(.custom("AvenirNextCondensed-Bold", size: 20))
                    .foregroundStyle(AppColors.darkBrown)

                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
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

            Rectangle()
                .fill(AppColors.granite.opacity(0.3))
                .frame(height: 1)

            List {
                Section {
                    Toggle("Sound", isOn: $viewModel.audioEnabled)
                        .font(.custom("AvenirNext-Regular", size: 21))
                        .tint(AppColors.woodlandGreen)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColors.granite.opacity(0.3))
                                .frame(height: 1)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    Toggle("Visual", isOn: $viewModel.visualEnabled)
                        .font(.custom("AvenirNext-Regular", size: 21))
                        .tint(AppColors.woodlandGreen)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColors.granite.opacity(0.3))
                                .frame(height: 1)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    Toggle("Vibrate", isOn: $viewModel.hapticsEnabled)
                        .font(.custom("AvenirNext-Regular", size: 21))
                        .tint(AppColors.woodlandGreen)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColors.granite.opacity(0.3))
                                .frame(height: 1)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                } header: {
                    Text("Feedback")
                        .font(.custom("AvenirNext-DemiBold", size: 17))
                        .foregroundStyle(AppColors.granite.opacity(0.8))
                }
                .foregroundStyle(AppColors.granite)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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
        .tint(AppColors.granite)
    }
}
