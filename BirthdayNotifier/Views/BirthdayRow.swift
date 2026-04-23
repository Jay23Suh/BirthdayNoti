import SwiftUI

struct BirthdayRow: View {
    let birthday: Birthday
    let messageState: MessageState?
    let onGenerate: (() -> Void)?
    let onCopy: (() -> Void)?
    let onDelete: (() -> Void)?

    @State private var copied = false

    private var initials: String {
        birthday.name.split(separator: " ").prefix(2)
            .compactMap(\.first).map(String.init).joined().uppercased()
    }

    private var avatarColor: Color {
        let palette: [Color] = [.pink, .purple, .indigo, .blue, .teal, .green, .orange, .red]
        return palette[abs(birthday.name.hashValue) % palette.count]
    }

    private var daysLabel: String {
        switch birthday.daysUntilNextBirthday {
        case 0: return "Today"
        case 1: return "Tomorrow"
        case let d: return "in \(d)d"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                // Avatar
                ZStack {
                    Circle().fill(avatarColor.opacity(0.15))
                    Text(initials.isEmpty ? "?" : initials)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(avatarColor)
                }
                .frame(width: 32, height: 32)

                // Name + date
                VStack(alignment: .leading, spacing: 2) {
                    Text(birthday.name)
                        .font(.system(size: 13, weight: birthday.isToday ? .semibold : .regular))
                        .foregroundStyle(.primary)

                    HStack(spacing: 3) {
                        Text(birthday.displayDate)
                        if let age = birthday.age {
                            Text("·")
                            Text("turns \(age + 1)")
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                }

                Spacer()

                // Right side badges + delete
                HStack(spacing: 6) {
                    if birthday.source == .contacts {
                        Image(systemName: "person.circle")
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                    }

                    Text(daysLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(birthday.isToday ? .white : .secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            birthday.isToday ? AnyShapeStyle(Color.pink) : AnyShapeStyle(.quaternary),
                            in: Capsule()
                        )
                        .animation(.easeInOut(duration: 0.2), value: birthday.isToday)

                    if let onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Message area — only for today's birthdays
            if let onGenerate {
                Group {
                    switch messageState {
                    case .none:
                        Button(action: onGenerate) {
                            Label("Write message", systemImage: "sparkles")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.pink)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .padding(.leading, 42)

                    case .loading:
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.mini)
                            Text("Writing…")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                        .padding(.leading, 42)

                    case .ready(let text):
                        VStack(alignment: .leading, spacing: 8) {
                            Text(text)
                                .font(.system(size: 12))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

                            HStack(spacing: 10) {
                                Button(action: {
                                    onCopy?()
                                    withAnimation(.spring(response: 0.2)) { copied = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation { copied = false }
                                    }
                                }) {
                                    Label(
                                        copied ? "Copied!" : "Copy",
                                        systemImage: copied ? "checkmark" : "doc.on.doc"
                                    )
                                    .font(.system(size: 11, weight: .medium))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(copied ? .green : .pink)
                                .controlSize(.small)
                                .animation(.easeInOut(duration: 0.2), value: copied)

                                Button(action: onGenerate) {
                                    Label("Regenerate", systemImage: "arrow.clockwise")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.leading, 42)

                    case .failed(let error):
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 11))
                            Text(error)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Retry", action: onGenerate)
                                .font(.system(size: 11))
                                .buttonStyle(.plain)
                                .foregroundStyle(.pink)
                        }
                        .padding(.top, 8)
                        .padding(.leading, 42)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 6)
    }
}
