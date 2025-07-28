import SwiftUI

@main
struct ORAControlApp: App {
    @StateObject private var api = APIClient()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(api)
        }
    }
}
