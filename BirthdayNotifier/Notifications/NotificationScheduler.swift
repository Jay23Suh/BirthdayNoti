import UserNotifications
import Foundation

class NotificationScheduler {
    static let shared = NotificationScheduler()
    private init() {}

    func scheduleAll(for birthdays: [Birthday]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // Group by month/day so multiple birthdays on same day become one notification
        var groups: [String: [Birthday]] = [:]
        for b in birthdays {
            let key = "\(b.month)-\(b.day)"
            groups[key, default: []].append(b)
        }

        for (_, group) in groups {
            guard let first = group.first else { continue }

            let body: String
            if group.count == 1 {
                if let age = first.age {
                    body = "\(first.name) turns \(age + 1) today!"
                } else {
                    body = "\(first.name)'s birthday is today!"
                }
            } else {
                let names = group.map(\.name).joined(separator: ", ")
                body = "\(group.count) birthdays today: \(names)"
            }

            let content = UNMutableNotificationContent()
            content.title = "Birthday"
            content.body = body
            content.sound = .default

            var dateComps = DateComponents()
            dateComps.month = first.month
            dateComps.day = first.day
            dateComps.hour = 0
            dateComps.minute = 0
            dateComps.second = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
            let request = UNNotificationRequest(
                identifier: "birthday-\(first.month)-\(first.day)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
}
