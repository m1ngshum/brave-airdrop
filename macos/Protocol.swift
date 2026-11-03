import Foundation

enum InvalidRequest: Error { case invalid }

struct Request {
    let id: String
    let item: Any?

    init(_ data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = json["version"] as? NSNumber,
              CFGetTypeID(version) != CFBooleanGetTypeID(), version.doubleValue == 1,
              let id = json["requestId"] as? String, id.utf8.count == 36, UUID(uuidString: id) != nil,
              let action = json["action"] as? String else { throw InvalidRequest.invalid }
        self.id = id
        if action == "ping", Set(json.keys) == ["version", "requestId", "action"] {
            item = nil
            return
        }
        guard action == "share", Set(json.keys) == ["version", "requestId", "action", "kind", "payload"],
              let kind = json["kind"] as? String, let payload = json["payload"] as? [String: String],
              payload.count == 1, let value = payload[kind], !value.isEmpty else { throw InvalidRequest.invalid }
        switch kind {
        case "url":
            guard value.utf8.count <= 8192, !value.unicodeScalars.contains(where: {
                CharacterSet.whitespacesAndNewlines.contains($0) || CharacterSet.controlCharacters.contains($0)
            }), let url = URL(string: value, encodingInvalidCharacters: false),
            let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
            let host = url.host(), !host.isEmpty, url.user == nil, url.password == nil
            else { throw InvalidRequest.invalid }
            item = url
        case "text":
            guard value.utf8.count <= 16384 else { throw InvalidRequest.invalid }
            item = value
        default: throw InvalidRequest.invalid
        }
    }
}

import CoreFoundation

func readExactly(_ count: Int, from handle: FileHandle) throws -> Data {
    var result = Data()
    while result.count < count {
        guard let chunk = try handle.read(upToCount: count - result.count), !chunk.isEmpty
        else { throw InvalidRequest.invalid }
        result.append(chunk)
    }
    return result
}

func readFrame(from handle: FileHandle) throws -> Data {
    let header = try readExactly(4, from: handle)
    let count = header.enumerated().reduce(0) { $0 | (Int($1.element) << (8 * $1.offset)) }
    guard (1...131072).contains(count) else { throw InvalidRequest.invalid }
    return try readExactly(count, from: handle)
}

func respond(_ status: String, id: String?, code: String? = nil) {
    var reply: [String: Any] = ["version": 1, "requestId": id as Any? ?? NSNull(), "status": status]
    if let code { reply["error"] = ["code": code] }
    do {
        let data = try JSONSerialization.data(withJSONObject: reply)
        var length = UInt32(data.count).littleEndian
        try FileHandle.standardOutput.write(contentsOf: withUnsafeBytes(of: &length) { Data($0) } + data)
    } catch {
        exit(1)
    }
}
