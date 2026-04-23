import SwiftUI

struct AddBirthdayView: View {
    let onAdd: (Birthday) -> Void

    @State private var name = ""
    @State private var month = Calendar.current.component(.month, from: Date())
    @State private var day = Calendar.current.component(.day, from: Date())
    @State private var yearString = ""
    @State private var includeYear = false
    @Environment(\.dismiss) private var dismiss

    private let months = Calendar.current.monthSymbols
    private var daysInMonth: Int {
        let comps = DateComponents(year: 2000, month: month)
        guard let date = Calendar.current.date(from: comps) else { return 31 }
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 31
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Add Birthday")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                // Name field
                VStack(alignment: .leading, spacing: 5) {
                    fieldLabel("Name")
                    TextField("e.g. Jay Suh", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                // Date pickers
                VStack(alignment: .leading, spacing: 5) {
                    fieldLabel("Birthday")
                    HStack(spacing: 8) {
                        Picker("Month", selection: $month) {
                            ForEach(1...12, id: \.self) { m in
                                Text(months[m - 1]).tag(m)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)

                        Picker("Day", selection: $day) {
                            ForEach(1...daysInMonth, id: \.self) { d in
                                Text(String(d)).tag(d)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 64)
                        .onChange(of: daysInMonth) { newMax in
                            if day > newMax { day = newMax }
                        }
                    }
                }

                // Year toggle + field
                VStack(alignment: .leading, spacing: 5) {
                    Toggle(isOn: $includeYear) {
                        fieldLabel("Include birth year")
                    }
                    .toggleStyle(.checkbox)

                    if includeYear {
                        TextField("e.g. 1995", text: $yearString)
                            .textFieldStyle(.roundedBorder)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .animation(.easeInOut(duration: 0.15), value: includeYear)
            }
            .padding(16)

            Divider()

            // Actions
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Add Birthday") {
                    let birthday = Birthday(
                        id: UUID(),
                        name: name.trimmingCharacters(in: .whitespaces),
                        month: month,
                        day: day,
                        year: includeYear ? Int(yearString) : nil,
                        source: .manual
                    )
                    onAdd(birthday)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(16)
        }
        .frame(width: 300)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
    }
}
