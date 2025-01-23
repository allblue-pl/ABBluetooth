import SwiftUI

public struct ABBluetoothDevicesListView: View {
    @ObservedObject private var model: ABBluetoothDevicesListModel
    
    public init(_ model: ABBluetoothDevicesListModel) {
        self.model = model
    }

    public var body: some View {
        List(self.model.discoveredDevices) { deviceInfo in
            HStack {
                Button(deviceInfo.name) {
                    if let listener = model.listeners_OnDeviceSelected {
                        listener(deviceInfo)
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
    @Published public var discoveredDevices: [ABBluetoothDeviceInfo];
    
    var errorFn: (_ errorMessage: String) -> Void
    var btDevices: ABBluetoothDevices
    
    var listeners_OnDeviceSelected: ((ABBluetoothDeviceInfo) -> Void)?
    
    deinit {
        self.btDevices.stopScanning()
    }
    
    public init(errorFn: @escaping (_ errorMessage: String) -> Void) {
        self.discoveredDevices = []
        
        self.errorFn = errorFn
        self.btDevices = ABBluetoothDevices(errorFn: errorFn)
        
        self.listeners_OnDeviceSelected = nil
        
        self.btDevices.setListener_OnDiscover {
            self.discoveredDevices = [ABBluetoothDeviceInfo]()
            for device in self.btDevices.getDiscoveredDevices() {
                self.discoveredDevices.append(ABBluetoothDeviceInfo(uuid: device.identifier.uuidString, name: device.name ?? "-"))
            }
        }
    }
    
    public func setListener_OnDeviceSelected(onDeviceSelected: @escaping (ABBluetoothDeviceInfo) -> Void) {
        self.listeners_OnDeviceSelected = onDeviceSelected
    }
}

