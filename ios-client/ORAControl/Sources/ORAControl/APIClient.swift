import Foundation
import SwiftUI

class APIClient: ObservableObject {
    @Published var token: String = KeychainHelper.shared.getToken() ?? "" {
        didSet { KeychainHelper.shared.saveToken(token) }
    }
    var baseURL = URL(string: "http://localhost:8000")!

    private func request(_ path: String, method: String = "GET", body: Data? = nil) async throws -> (Data, URLResponse) {
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if let body { req.httpBody = body }
        return try await URLSession.shared.data(for: req)
    }

    func status() async throws -> StatusResponse {
        let (data, _) = try await request("/status")
        return try JSONDecoder().decode(StatusResponse.self, from: data)
    }

    func mcStart() async throws { _ = try await request("/mc/start", method: "POST") }
    func mcStop() async throws { _ = try await request("/mc/stop", method: "POST") }
    func renderStart(path: String, start: Int, end: Int) async throws {
        let body = "blend_file=\(path)&frame_start=\(start)&frame_end=\(end)".data(using: .utf8)
        _ = try await request("/render/start", method: "POST", body: body)
    }
    func renderStop() async throws { _ = try await request("/render/stop", method: "POST") }
}

struct StatusResponse: Codable {
    let mc_running: Bool
    let render_running: Bool
}

class KeychainHelper {
    static let shared = KeychainHelper()
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: "apiToken",
                                    kSecValueData as String: data]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    func getToken() -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: "apiToken",
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
}
