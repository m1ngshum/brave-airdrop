import AppKit

final class Share: NSObject, NSSharingServiceDelegate {
    let id: String
    let service: NSSharingService

    init(id: String, service: NSSharingService) {
        self.id = id
        self.service = service
    }

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        respond("shared", id: id)
        exit(0)
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        let failure = error as NSError
        if failure.domain == NSCocoaErrorDomain && failure.code == NSUserCancelledError {
            respond("cancelled", id: id)
        } else {
            respond("error", id: id, code: "SHARE_FAILED")
        }
        exit(0)
    }
}

func run() throws {
    guard let executable = Bundle.main.executableURL else { throw InvalidRequest.invalid }
    let manifest = executable.deletingLastPathComponent().appendingPathComponent("app.braveairdrop.host.json")
    let descriptor = open(manifest.path, O_RDONLY | O_NOFOLLOW | O_NONBLOCK)
    guard descriptor >= 0 else { throw InvalidRequest.invalid }
    let registration = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    defer { try? registration.close() }
    var metadata = stat()
    guard fstat(registration.fileDescriptor, &metadata) == 0, metadata.st_uid == getuid(),
          metadata.st_mode & S_IFMT == S_IFREG, metadata.st_mode & 0o022 == 0
    else { throw InvalidRequest.invalid }
    guard let configData = try registration.read(upToCount: 4096), configData.count < 4096,
          let config = try JSONSerialization.jsonObject(with: configData) as? [String: Any],
          let origins = config["allowed_origins"] as? [String], origins.count == 1,
          let origin = CommandLine.arguments.dropFirst().first, origin == origins[0],
          origin.range(of: "^chrome-extension://[a-p]{32}/$", options: .regularExpression) != nil
    else { respond("error", id: nil, code: "UNAUTHORIZED"); return }

    let request: Request
    let frame = try readFrame(from: .standardInput)
    do { request = try Request(frame) } catch {
        let json = (try? JSONSerialization.jsonObject(with: frame)) as? [String: Any]
        let rawId = json?["requestId"] as? String
        let id = rawId.flatMap { $0.utf8.count == 36 && UUID(uuidString: $0) != nil ? $0 : nil }
        respond("error", id: id, code: "INVALID_REQUEST")
        return
    }
    guard let item = request.item else { respond("ready", id: request.id); return }
    guard flock(registration.fileDescriptor, LOCK_EX | LOCK_NB) == 0
    else { respond("error", id: request.id, code: "BUSY"); return }

    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    guard let service = NSSharingService(named: .sendViaAirDrop), service.canPerform(withItems: [item])
    else { respond("error", id: request.id, code: "AIRDROP_UNAVAILABLE"); return }

    let delegate = Share(id: request.id, service: service)
    service.delegate = delegate
    DispatchQueue.main.async {
        app.activate()
        respond("accepted", id: request.id)
        service.perform(withItems: [item])
    }
    // Closing the browser port closes stdin. No further requests are supported.
    DispatchQueue.global().async {
        _ = try? FileHandle.standardInput.read(upToCount: 1)
        exit(0)
    }
    withExtendedLifetime(delegate) { app.run() }
}

signal(SIGPIPE, SIG_IGN)
do { try run() } catch { respond("error", id: nil, code: "INVALID_REQUEST") }
