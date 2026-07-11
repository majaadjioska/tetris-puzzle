import Foundation
import SwiftUI

struct ScoreEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let score: Int
    let date: Date

    init(id: UUID = UUID(), score: Int, date: Date = Date()) {
        self.id = id
        self.score = score
        self.date = date
    }
}

final class ScoreStore: ObservableObject {
    private static let storageKey = "jadeku.scores.v1"
    private let calendar: Calendar

    @Published private(set) var scores: [ScoreEntry] = []

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        load()
    }

    func add(score: Int, date: Date = Date()) {
        guard score > 0 else { return }
        scores.append(ScoreEntry(score: score, date: date))
        save()
    }

    func clearAll() {
        scores = []
        save()
    }

    var topAllTime: [ScoreEntry] {
        top(scores, limit: 5)
    }

    var topThisWeek: [ScoreEntry] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())
        else { return [] }
        let filtered = scores.filter { weekInterval.contains($0.date) }
        return top(filtered, limit: 5)
    }

    var topToday: [ScoreEntry] {
        guard
            let dayInterval = calendar.dateInterval(of: .day, for: Date())
        else { return [] }
        let filtered = scores.filter { dayInterval.contains($0.date) }
        return top(filtered, limit: 5)
    }

    var bestEverScore: Int { scores.map(\.score).max() ?? 0 }

    private func top(_ list: [ScoreEntry], limit: Int) -> [ScoreEntry] {
        Array(list.sorted { $0.score > $1.score }.prefix(limit))
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.storageKey),
            let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else { return }
        scores = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(scores) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
