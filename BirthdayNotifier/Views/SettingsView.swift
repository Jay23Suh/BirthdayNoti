import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var apiKey = MessageGenerator.shared.apiKey
    @State private var showKey = false
    @State private var saved = false
    @State private var testFired = false
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

                Divider()

                // Test notification
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notifications")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Button(action: {
                        sendTestNotification()
                        testFired = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { testFired = false }
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: testFired ? "checkmark" : "bell")
                                .font(.system(size: 11))
                            Text(testFired ? "Sent — check in 5s" : "Send test notification")
                                .font(.system(size: 11))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(testFired ? .green : .primary)
                    .disabled(testFired)
                    .animation(.easeInOut(duration: 0.2), value: testFired)
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

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Birthday"
        content.body = "🎂 2 birthdays today: Jay, Sarah"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: "birthday-test", content: content, trigger: trigger)
        )
    }
}
