import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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
                        .font(.custom("AvenirNext-Regular", size: 15))
                        .foregroundStyle(AppColors.granite.opacity(0.7))
                }
                .foregroundStyle(AppColors.granite)
            }
            .listStyle(.plain)
            .padding(.top, 8)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(AppColors.granite.opacity(0.3))
                    .frame(height: 1)
            }
            .scrollContentBackground(.hidden)
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.custom("AvenirNextCondensed-Bold", size: 20))
                        .foregroundStyle(AppColors.darkBrown)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.granite)
                }
            }
            .tint(AppColors.granite)
        }
        .tint(AppColors.granite)
    }
}
