import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var apiKey = MessageGenerator.shared.apiKey
    @State private var showKey = false
    @State private var saved = false
    @Environment(\.dismiss) private var dismiss

    private var hasExistingKey: Bool { !MessageGenerator.shared.apiKey.isEmpty }
    private var maskedKey: String {
        let key = MessageGenerator.shared.apiKey
        guard key.count > 8 else { return key.isEmpty ? "" : "••••••••" }
        return String(key.prefix(6)) + "••••" + String(key.suffix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
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

            VStack(alignment: .leading, spacing: 16) {
                // API Key section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("OpenRouter API Key")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        if hasExistingKey {
                            Label("Saved", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.green)
                        }
                    }

                    HStack(spacing: 6) {
                        Group {
                            if showKey {
                                TextField("sk-or-v1-...", text: $apiKey)
                            } else {
                                SecureField("sk-or-v1-...", text: $apiKey)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))

                        Button(action: { showKey.toggle() }) {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    if hasExistingKey && !showKey {
                        Text(maskedKey)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }

                    Text("Get a free key at openrouter.ai")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)

            Divider()

            // Save / Cancel
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: {
                    MessageGenerator.shared.apiKey = apiKey.trimmingCharacters(in: .whitespaces)
                    withAnimation { saved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                }) {
                    HStack(spacing: 4) {
                        if saved { Image(systemName: "checkmark") }
                        Text(saved ? "Saved!" : "Save")
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .tint(saved ? .green : .pink)
                .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty)
                .animation(.easeInOut(duration: 0.2), value: saved)
            }
            .padding(16)
        }
        .frame(width: 300)
    }
}
