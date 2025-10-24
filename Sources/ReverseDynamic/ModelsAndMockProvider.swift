import Foundation
import UIKit

public struct ProcInfo: Codable {
    public let pid: Int
    public let name: String
    public let arch: String
    public init(pid:Int, name:String, arch:String){ self.pid = pid; self.name = name; self.arch = arch }
}

public struct MemRegion: Codable {
    public let addr: UInt64
    public let size: UInt64
    public let perms: String
    public let mappedPath: String?
    public init(addr:UInt64, size:UInt64, perms:String, mappedPath:String?){ self.addr = addr; self.size = size; self.perms = perms; self.mappedPath = mappedPath }
}

public struct FunctionInfo: Codable {
    public let name: String
    public let addr: UInt64
    public let size: UInt64
    public let demangled: String?
    public init(name:String, addr:UInt64, size:UInt64, demangled:String?){ self.name = name; self.addr = addr; self.size = size; self.demangled = demangled }
}

public final class MockProvider {
    public static let shared = MockProvider()
    private init() {}

    public func fetchProcesses(completion: @escaping ([ProcInfo]) -> Void) {
        let procs: [ProcInfo] = [
            ProcInfo(pid: 101, name: "com.example.testapp", arch: "arm64"),
            ProcInfo(pid: 202, name: "com.example.helper", arch: "arm64e"),
            ProcInfo(pid: 303, name: "com.example.runner", arch: "x86_64")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            completion(procs)
        }
    }

    public func fetchMemoryMap(pid: Int, completion: @escaping ([MemRegion]) -> Void) {
        let regions = [
            MemRegion(addr: 0x100000000, size: 0x2000, perms: "r-x", mappedPath: "/usr/lib/libsystem.dylib"),
            MemRegion(addr: 0x100002000, size: 0x4000, perms: "rw-", mappedPath: nil),
            MemRegion(addr: 0x100006000, size: 0x1000, perms: "r--", mappedPath: "/private/var/containers/app")
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            completion(regions)
        }
    }

    public func fetchFunctions(pid: Int, completion: @escaping ([FunctionInfo]) -> Void) {
        var funcs: [FunctionInfo] = []
        for i in 0..<160 {
            let addr = UInt64(0x100010000 + i * 0x30)
            funcs.append(FunctionInfo(name: "_func_\(i)", addr: addr, size: 0x24, demangled: "func_\(i)"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion(funcs)
        }
    }

    public func fetchMemoryBytes(pid: Int, addr: UInt64, size: Int, completion: @escaping (Data) -> Void) {
        var bytes = Data(count: size)
        for i in 0..<size {
            let val = UInt8((Int(addr) + i) & 0xff)
            bytes[i] = val
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            completion(bytes)
        }
    }
}
