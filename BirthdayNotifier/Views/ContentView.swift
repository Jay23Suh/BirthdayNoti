import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: BirthdayStore
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var messageStates: [UUID: MessageState] = [:]

    var todaysBirthdays: [Birthday] {
        store.birthdays.filter(\.isToday)
    }

    var upcomingBirthdays: [Birthday] {
        store.birthdays.filter { !$0.isToday }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "birthday.cake")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.pink)
                    Text("Birthdays")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                HStack(spacing: 2) {
                    IconButton(symbol: "arrow.clockwise") { store.fetchContacts() }
                        .help("Sync from Contacts")
                    IconButton(symbol: "gearshape") { showSettings = true }
                    IconButton(symbol: "plus") { showAdd = true }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(.background)

            Divider()

            if store.birthdays.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        if !todaysBirthdays.isEmpty {
                            Section {
                                ForEach(todaysBirthdays) { b in
                                    BirthdayRow(
                                        birthday: b,
                                        messageState: messageStates[b.id],
                                        onGenerate: { generateMessage(for: b) },
                                        onCopy: { copyMessage(for: b) },
                                        onDelete: b.source == .manual ? { store.delete(b) } : nil
                                    )
                                    .padding(.horizontal, 14)
                                    .background(Color.pink.opacity(0.04))

                                    if b.id != todaysBirthdays.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            } header: {
                                sectionHeader("Today")
                            }
                        }

                        if !upcomingBirthdays.isEmpty {
                            Section {
                                ForEach(upcomingBirthdays) { b in
                                    BirthdayRow(
                                        birthday: b,
                                        messageState: nil,
                                        onGenerate: nil,
                                        onCopy: nil,
                                        onDelete: b.source == .manual ? { store.delete(b) } : nil
                                    )
                                    .padding(.horizontal, 14)

                                    if b.id != upcomingBirthdays.last?.id {
                                        Divider().padding(.leading, 56)
                                    }
                                }
                            } header: {
                                sectionHeader("Upcoming")
                            }
                        }
                    }
                }
            }

            Divider()

            // Footer
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
        }
        .frame(width: 300, height: 420)
        .onAppear { messageStates = [:] }
        .sheet(isPresented: $showAdd) {
            AddBirthdayView { birthday in store.add(birthday) }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.background)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "birthday.cake")
                .font(.system(size: 32))
                .foregroundStyle(.pink.opacity(0.6))
            Text("No birthdays yet")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
            Text("Tap + to add one, or sync\nyour Contacts with ↺")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func generateMessage(for birthday: Birthday) {
        messageStates[birthday.id] = .loading
        Task {
            do {
                let text = try await MessageGenerator.shared.generate(for: birthday)
                withAnimation { messageStates[birthday.id] = .ready(text) }
            } catch {
                withAnimation { messageStates[birthday.id] = .failed(error.localizedDescription) }
            }
        }
    }

    private func copyMessage(for birthday: Birthday) {
        if case .ready(let text) = messageStates[birthday.id] {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        }
    }
}

private struct IconButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
