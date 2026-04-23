import Foundation

struct Birthday: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var month: Int
    var day: Int
    var year: Int?
    var source: Source

    enum Source: String, Codable {
        case manual, contacts
    }

    var isToday: Bool {
        let now = Calendar.current.dateComponents([.month, .day], from: Date())
        return now.month == month && now.day == day
    }

    var age: Int? {
        guard let year else { return nil }
        return Calendar.current.component(.year, from: Date()) - year
    }

    var daysUntilNextBirthday: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let currentYear = cal.component(.year, from: today)

        for yearOffset in 0...1 {
            var comps = DateComponents()
            comps.year = currentYear + yearOffset
            comps.month = month
            comps.day = day
            if let date = cal.date(from: comps), date >= today {
                return cal.dateComponents([.day], from: today, to: date).day ?? 0
            }
        }
        return 0
    }

    var displayDate: String {
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        guard let date = Calendar.current.date(from: comps) else { return "\(month)/\(day)" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM d"
        return fmt.string(from: date)
    }
}
