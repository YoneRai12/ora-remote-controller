import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var api: APIClient
    @State private var status: StatusResponse?
    @State private var showingSettings = false
    @State private var tokenInput = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Token", text: $api.token)
                .textFieldStyle(.roundedBorder)
                .padding()
            if let status {
                Text("MC: \(status.mc_running ? "Running" : "Stopped")")
                Text("Render: \(status.render_running ? "Running" : "Stopped")")
            }
            HStack {
                Button("MC Start") { Task { try? await api.mcStart(); await loadStatus() } }
                Button("MC Stop") { Task { try? await api.mcStop(); await loadStatus() } }
            }
            HStack {
                Button("Render Start") { showingSettings = true }
                Button("Render Stop") { Task { try? await api.renderStop(); await loadStatus() } }
            }
        }
        .task { await loadStatus() }
        .sheet(isPresented: $showingSettings) { RenderSettingsView() }
    }

    func loadStatus() async {
        status = try? await api.status()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView().environmentObject(APIClient())
    }
}
