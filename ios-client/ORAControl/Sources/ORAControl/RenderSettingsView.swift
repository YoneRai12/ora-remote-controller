import SwiftUI

struct RenderSettingsView: View {
    @EnvironmentObject var api: APIClient
    @Environment(\.dismiss) var dismiss
    @State private var path = ""
    @State private var start = "1"
    @State private var end = "250"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Blend File Path", text: $path)
                TextField("Frame Start", text: $start)
                    .keyboardType(.numberPad)
                TextField("Frame End", text: $end)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Render Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        Task {
                            let s = Int(start) ?? 1
                            let e = Int(end) ?? s
                            try? await api.renderStart(path: path, start: s, end: e)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct RenderSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        RenderSettingsView().environmentObject(APIClient())
    }
}
