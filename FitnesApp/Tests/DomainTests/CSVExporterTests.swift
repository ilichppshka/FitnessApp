@testable import FitnesApp
import Foundation
import Testing

struct CSVExporterTests {
    private func session(
        id: UUID = UUID(),
        sets: [WorkoutSetDTO]
    ) -> WorkoutSessionDTO {
        WorkoutSessionDTO(
            id: id,
            planName: nil,
            startedAt: Date(timeIntervalSince1970: 1_000_000),
            finishedAt: Date(timeIntervalSince1970: 1_003_600),
            totalTonnage: sets.reduce(0) { $0 + $1.tonnage },
            sets: sets
        )
    }

    private func set(
        exerciseName: String = "Bench Press",
        setNumber: Int = 1,
        weight: Double = 60,
        reps: Int = 10,
        tonnage: Double = 600,
        loggedAt: Date = Date(timeIntervalSince1970: 1_000_500)
    ) -> WorkoutSetDTO {
        WorkoutSetDTO(
            id: UUID(),
            exerciseID: UUID(),
            exerciseName: exerciseName,
            setNumber: setNumber,
            weight: weight,
            reps: reps,
            tonnage: tonnage,
            loggedAt: loggedAt
        )
    }

    @Test
    func renderEmptyHistoryReturnsHeaderOnly() async throws {
        let exporter = CSVExporter()

        let csv = await exporter.render(history: [])

        #expect(csv == "Date,Session,Exercise,Set,Weight,Reps,Tonnage\n")
    }

    @Test
    func renderProducesRowPerSet() async throws {
        let exporter = CSVExporter()
        let history = [
            session(sets: [
                set(setNumber: 1, weight: 60, reps: 10, tonnage: 600),
                set(setNumber: 2, weight: 65, reps: 8, tonnage: 520)
            ])
        ]

        let csv = await exporter.render(history: history)

        let lines = csv.split(separator: "\n")
        #expect(lines.count == 3)
        #expect(lines[1].contains("Bench Press"))
        #expect(lines[1].contains(",1,60.0,10,600.0"))
        #expect(lines[2].contains(",2,65.0,8,520.0"))
    }

    @Test
    func renderEscapesCommasInExerciseName() async throws {
        let exporter = CSVExporter()
        let history = [session(sets: [set(exerciseName: "Тяга, нижний блок")])]

        let csv = await exporter.render(history: history)

        #expect(csv.contains("\"Тяга, нижний блок\""))
    }

    @Test
    func renderEscapesQuotesByDoubling() async throws {
        let exporter = CSVExporter()
        let history = [session(sets: [set(exerciseName: "Push \"Press\"")])]

        let csv = await exporter.render(history: history)

        #expect(csv.contains("\"Push \"\"Press\"\"\""))
    }

    @Test
    func renderEscapesNewlinesInsideField() async throws {
        let exporter = CSVExporter()
        let history = [session(sets: [set(exerciseName: "Squat\nback")])]

        let csv = await exporter.render(history: history)

        #expect(csv.contains("\"Squat\nback\""))
    }

    @Test
    func renderUsesISO8601ForLoggedAt() async throws {
        let exporter = CSVExporter()
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let expected = ISO8601DateFormatter().string(from: date)
        let history = [session(sets: [set(loggedAt: date)])]

        let csv = await exporter.render(history: history)

        #expect(csv.contains(expected))
    }

    @Test
    func exportWritesFileToTemporaryDirectory() async throws {
        let exporter = CSVExporter()
        let history = [session(sets: [set()])]

        let url = try await exporter.export(history: history)
        defer { try? FileManager.default.removeItem(at: url) }

        let written = try String(contentsOf: url, encoding: .utf8)
        let rendered = await exporter.render(history: history)
        #expect(written == rendered)
        #expect(url.lastPathComponent.hasPrefix("fitnesapp-export-"))
        #expect(url.pathExtension == "csv")
    }

    @Test
    func exportFilenameUsesProvidedTimestamp() async throws {
        let fixed = Date(timeIntervalSince1970: 1_705_000_000) // 2024-01-11 19:06:40 UTC
        let exporter = CSVExporter(now: { fixed })

        let url = try await exporter.export(history: [])
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.lastPathComponent == "fitnesapp-export-20240111-190640.csv")
    }
}
