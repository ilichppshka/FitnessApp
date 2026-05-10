import Foundation

actor CSVExporter {
    private let fileManager: FileManager
    private let now: @Sendable () -> Date

    init(
        fileManager: FileManager = .default,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.fileManager = fileManager
        self.now = now
    }

    func export(history: [WorkoutSessionDTO]) throws -> URL {
        let csv = render(history: history)
        let url = fileManager.temporaryDirectory
            .appendingPathComponent(filename(at: now()))
        guard let data = csv.data(using: .utf8) else {
            throw AppError.persistence("CSV encoding failed")
        }
        try data.write(to: url, options: .atomic)
        return url
    }

    func render(history: [WorkoutSessionDTO]) -> String {
        var lines: [String] = ["Date,Session,Exercise,Set,Weight,Reps,Tonnage"]
        let dateFormatter = ISO8601DateFormatter()
        for session in history {
            for set in session.sets {
                let row = [
                    dateFormatter.string(from: set.loggedAt),
                    session.id.uuidString,
                    set.exerciseName,
                    String(set.setNumber),
                    String(set.weight),
                    String(set.reps),
                    String(set.tonnage)
                ]
                lines.append(row.map(Self.escape).joined(separator: ","))
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private func filename(at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "fitnesapp-export-\(formatter.string(from: date)).csv"
    }

    private static func escape(_ field: String) -> String {
        let needsQuoting = field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r")
        guard needsQuoting else { return field }
        let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
