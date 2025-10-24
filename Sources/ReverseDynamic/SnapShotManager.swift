import Foundation

final class SnapshotManager {
    static let shared = SnapshotManager()
    private init() {}

    func createSnapshot(name: String, completion: @escaping (URL?) -> Void) {
        let meta: [String:Any] = [
            "name": name,
            "created_at": ISO8601DateFormatter().string(from: Date()),
            "processes": []
        ]
        let fm = FileManager.default
        let url = fm.temporaryDirectory.appendingPathComponent("\(name)-\(Int(Date().timeIntervalSince1970)).json")
        if let data = try? JSONSerialization.data(withJSONObject: meta, options: [.prettyPrinted]) {
            try? data.write(to: url)
            completion(url)
            return
        }
        completion(nil)
    }
}
