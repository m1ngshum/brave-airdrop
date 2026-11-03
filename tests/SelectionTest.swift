import Foundation

@main
struct SelectionTest {
    static func main() throws {
        let text = "AirDrop 測試\nsecond line 🐱"
        let file = try stageSelection(text)
        let directory = file.deletingLastPathComponent()
        defer { try? FileManager.default.removeItem(at: directory) }
        let bytes = try Data(contentsOf: file)
        precondition(bytes == Data(text.utf8))
        for (url, expected) in [(directory, 0o700), (file, 0o600)] {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            precondition(attributes[.posixPermissions] as? Int == expected)
        }
    }
}
