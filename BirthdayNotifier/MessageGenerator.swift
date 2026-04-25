import Foundation

enum MessageState {
    case loading
    case ready(String)
    case failed(String)
}

class MessageGenerator {
    static let shared = MessageGenerator()
    private init() {}

    private let apiKeyKey = "openrouter_api_key"

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: apiKeyKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: apiKeyKey) }
    }

    func generate(for birthday: Birthday) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GeneratorError.noApiKey
        }

        let userMessage: String
        if let age = birthday.age {
            userMessage = "Write a birthday message for \(birthday.name) who turns \(age + 1) today."
        } else {
            userMessage = "Write a birthday message for \(birthday.name) whose birthday is today."
        }

        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("com.jaysuh.BirthdayNotifier", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("BirthdayNotifier", forHTTPHeaderField: "X-Title")

        let body: [String: Any] = [
            "model": "openai/gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You write short birthday messages. When given a name, immediately output a warm 2-3 sentence message with an inspirational quote woven in naturally. Draw quotes from a wide range of thinkers, writers, athletes, scientists, philosophers, comedians, or musicians — vary the source every time and avoid overused quotes from Maya Angelou, Helen Keller, or Dr. Seuss. Never ask for more information. Never start with 'Happy Birthday'. Output only the message, nothing else."
                ],
                ["role": "user", "content": userMessage]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw GeneratorError.apiError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GeneratorError.parseError
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum GeneratorError: LocalizedError {
        case noApiKey, apiError, parseError

        var errorDescription: String? {
            switch self {
            case .noApiKey: return "No API key set — tap ⚙ to add one."
            case .apiError: return "API request failed. Check your key."
            case .parseError: return "Couldn't read the response."
            }
        }
    }
}
