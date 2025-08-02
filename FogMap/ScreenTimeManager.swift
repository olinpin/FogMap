//
//  ScreenTimeManager.swift
//  FogMap
//

import Foundation
import FamilyControls
import DeviceActivity

@MainActor
class ScreenTimeManager: ObservableObject {
    @Published var totalScreenTime: TimeInterval = 0
    @Published var authorizationStatus: AuthorizationStatus = AuthorizationCenter.shared.authorizationStatus

    func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                await fetchScreenTime()
            } catch {
                authorizationStatus = AuthorizationCenter.shared.authorizationStatus
                print("Failed to request authorization: \(error)")
            }
        }
    }

    func fetchScreenTime() async {
        guard authorizationStatus == .authorized else { return }

        let store = DeviceActivityReportStore()
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let interval = DateInterval(start: startOfDay, end: now)
        let query = DeviceActivityReportQuery(during: interval, filter: .total)

        do {
            for try await result in store.execute(query) {
                if case .totalActivity(let report) = result {
                    totalScreenTime = report.activityDuration
                }
            }
        } catch {
            print("Failed to fetch screen time: \(error)")
        }
    }

    func formattedScreenTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: totalScreenTime) ?? "0m"
    }
}

