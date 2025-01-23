import Foundation

public struct ABBluetoothDeviceInfo: Identifiable {
    public var id = UUID()
    
    public var uuid: String
    public var name: String
    
    public init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }
}
