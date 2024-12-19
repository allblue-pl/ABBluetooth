import SwiftUI

public struct ABBluetoothDevicesListView: View {
    @ObservedObject private var model: ABBluetoothDevicesListModel
    
    public init(_ model: ABBluetoothDevicesListModel) {
        self.model = model
    }

    public var body: some View {
        List(self.model.discoveredDevices) { device in
            HStack {
                Button(device.name) {
                    if let listener = model.listeners_OnDeviceSelected {
                        listener(device)
                    }
                }
            }
        }
        .onAppear {
            model.btDevices.startScanning()
        }
        .onDisappear {
            model.btDevices.stopScanning()
        }
    }
}

public class ABBluetoothDevicesListModel: ObservableObject {
    @Published public var discoveredDevices: [DeviceInfo];
    
    var errorFn: (_ errorMessage: String) -> Void
    var btDevices: ABBluetoothDevices
    
    var listeners_OnDeviceSelected: ((DeviceInfo) -> Void)?
    
    deinit {
        self.btDevices.stopScanning()
    }
    
    public init(errorFn: @escaping (_ errorMessage: String) -> Void) {
        self.discoveredDevices = []
        
        self.errorFn = errorFn
        self.btDevices = ABBluetoothDevices(errorFn: errorFn)
        
        self.listeners_OnDeviceSelected = nil
        
        self.btDevices.setListener_OnDiscover {
            self.discoveredDevices = [DeviceInfo]()
            for device in self.btDevices.getDiscoveredDevices() {
                self.discoveredDevices.append(DeviceInfo(uuid: device.identifier.uuidString, name: device.name ?? "-"))
            }
        }
    }
    
    public func setListener_OnDeviceSelected(listener: @escaping (DeviceInfo) -> Void) {
        self.listeners_OnDeviceSelected = listener
    }
    
    
    public struct DeviceInfo: Identifiable {
        public var id = UUID()
        
        public var uuid: String
        public var name: String
        
        public init(uuid: String, name: String) {
            self.uuid = uuid
            self.name = name
        }
        
    }
}

