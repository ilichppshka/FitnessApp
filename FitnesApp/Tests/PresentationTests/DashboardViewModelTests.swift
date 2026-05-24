@testable import FitnesApp
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct DashboardViewModelTests {

    private var fixedDate: Date {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal.date(from: DateComponents(year: 2026, month: 4, day: 16, hour: 12))!
    }

    private var testCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "en_US_POSIX")
        return cal
    }

    private func makeVM(
        name: String = "Alex",
        shouldThrow: Bool = false
    ) -> (DashboardViewModel, MockUserRepository) {
        let repo = MockUserRepository()
        if shouldThrow {
            repo.currentError = NSError(domain: "test", code: 1)
        } else {
            repo.currentResult = UserProfile(name: name, bodyWeight: 70, selectedMascotId: "default")
        }
        let vm = DashboardViewModel(
            userRepository: repo,
            calendar: testCalendar,
            now: { fixedDate }
        )
        return (vm, repo)
    }

    @Test
    func loadInitial_populatesUserName_fromRepository() async {
        let (vm, _) = makeVM(name: "Alex")
        await vm.loadInitial()
        #expect(vm.userName == "Alex")
        #expect(!vm.isLoading)
        #expect(vm.errorMessage == nil)
    }

    @Test
    func greeting_containsName_whenNonEmpty() async {
        let (vm, _) = makeVM(name: "Alex")
        await vm.loadInitial()
        #expect(vm.greeting.contains("Alex"))
    }

    @Test
    func greeting_doesNotContainName_whenEmpty() async {
        let (vm, _) = makeVM(name: "")
        await vm.loadInitial()
        #expect(!vm.greeting.contains("Alex"))
        #expect(!vm.greeting.isEmpty)
    }

    @Test
    func weekDates_areSevenDaysMondayToSunday() async {
        let (vm, _) = makeVM()
        await vm.loadInitial()
        #expect(vm.weekDates.count == 7)
        let first = testCalendar.dateComponents([.year, .month, .day], from: vm.weekDates[0])
        #expect(first.year == 2026)
        #expect(first.month == 4)
        #expect(first.day == 13)
        let last = testCalendar.dateComponents([.year, .month, .day], from: vm.weekDates[6])
        #expect(last.day == 19)
    }

    @Test
    func weekRangeLabel_formatsCorrectly() async {
        let (vm, _) = makeVM()
        await vm.loadInitial()
        #expect(vm.weekRangeLabel == "APR 13 – APR 19")
    }

    @Test
    func headerDateLabel_formatsCorrectly() {
        let (vm, _) = makeVM()
        #expect(vm.headerDateLabel == "THURSDAY · APR 16")
    }

    @Test
    func mockedValues_areStable() {
        let (vm, _) = makeVM()
        #expect(vm.sessionsCompleted == 3)
        #expect(vm.sessionsGoal == 5)
        #expect(vm.totalVolume == "18,420")
        #expect(vm.mockMinutes == 45)
        #expect(vm.mockExercises == 6)
        #expect(vm.mockSets == 22)
    }

    @Test
    func loadInitial_setsErrorMessage_whenRepoThrows() async {
        let (vm, _) = makeVM(shouldThrow: true)
        await vm.loadInitial()
        #expect(vm.errorMessage != nil)
        #expect(!vm.isLoading)
        #expect(vm.userName.isEmpty)
    }

    @Test
    func selectDate_updatesSelectedDate() {
        let (vm, _) = makeVM()
        let newDate = testCalendar.date(byAdding: .day, value: 2, to: fixedDate)!
        vm.selectDate(newDate)
        #expect(vm.selectedDate == newDate)
    }
}
