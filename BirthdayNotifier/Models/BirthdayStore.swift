import Foundation
import Contacts

class BirthdayStore: ObservableObject {
    @Published var birthdays: [Birthday] = []

    private var manualBirthdays: [Birthday] = []
    private var contactsBirthdays: [Birthday] = []

    private let storeURL: URL = {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("BirthdayNotifier", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("birthdays.json")
    }()

    init() {
        loadManual()
        fetchContacts()
        merge()
    }

    /// Re-evaluates today/upcoming sections and re-sorts against the current date.
    /// Call this whenever the popover is about to be shown — the view is created once
    /// at launch and only re-renders when `birthdays` changes, so without this the
    /// "today" state can go stale while the app sits open across a day boundary.
    func refresh() {
        merge()
    }

    func add(_ birthday: Birthday) {
        manualBirthdays.append(birthday)
        saveManual()
        merge()
    }

    func delete(_ birthday: Birthday) {
        manualBirthdays.removeAll { $0.id == birthday.id }
        saveManual()
        merge()
    }

    private func merge() {
        let all = (contactsBirthdays + manualBirthdays)
            .sorted { $0.daysUntilNextBirthday < $1.daysUntilNextBirthday }
        birthdays = all
        NotificationScheduler.shared.scheduleAll(for: all)
    }

    private func saveManual() {
        guard let data = try? JSONEncoder().encode(manualBirthdays) else { return }
        try? data.write(to: storeURL)
    }

    private func loadManual() {
        guard let data = try? Data(contentsOf: storeURL),
              let loaded = try? JSONDecoder().decode([Birthday].self, from: data) else { return }
        manualBirthdays = loaded
    }

    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { [weak self] granted, _ in
            guard let self, granted else { return }

            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactBirthdayKey
            ] as [CNKeyDescriptor]

            let request = CNContactFetchRequest(keysToFetch: keys)
            var fetched: [Birthday] = []

            try? store.enumerateContacts(with: request) { contact, _ in
                guard let bday = contact.birthday,
                      let month = bday.month,
                      let day = bday.day else { return }

                let name = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                guard !name.isEmpty else { return }

                fetched.append(Birthday(
                    id: UUID(),
                    name: name,
                    month: month,
                    day: day,
                    year: bday.year,
                    source: .contacts
                ))
            }

            DispatchQueue.main.async {
                self.contactsBirthdays = fetched
                self.merge()
            }
        }
    }
}
