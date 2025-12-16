import SwiftUI

struct DurationPickerView: View {
    @Binding var duration: TimeInterval
    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0

    let title: String

    init(title: String, duration: Binding<TimeInterval>) {
        self.title = title
        self._duration = duration

        let totalSeconds = Int(duration.wrappedValue)
        _hours = State(initialValue: totalSeconds / 3600)
        _minutes = State(initialValue: (totalSeconds % 3600) / 60)
        _seconds = State(initialValue: totalSeconds % 60)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Hours
                    VStack(spacing: 4) {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text("hours")
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                    }

                    // Minutes
                    VStack(spacing: 4) {
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)")
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text("min")
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                    }

                    // Seconds
                    VStack(spacing: 4) {
                        Picker("Seconds", selection: $seconds) {
                            ForEach(0..<60, id: \.self) { second in
                                Text("\(second)")
                                    .tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text("sec")
                            .font(.custom("AvenirNext-Regular", size: 13))
                            .foregroundStyle(AppColors.granite.opacity(0.7))
                    }
                }
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
                    Text(title)
                        .font(.custom("AvenirNextCondensed-Bold", size: 20))
                        .foregroundStyle(AppColors.darkBrown)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        duration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                        dismiss()
                    }
                    .font(.custom("AvenirNext-DemiBold", size: 17))
                    .foregroundStyle(AppColors.granite)
                }
            }
        }
    }
}
