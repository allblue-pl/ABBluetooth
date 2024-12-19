import CoreBluetooth
import SwiftUI

import ABLibs

public class ABBluetoothDevices: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    private var discoveredDevices: [CBPeripheral]
    private var listeners_onDiscovered: (() -> Void)?
    private var errorFn: (_ errorMessage: String) -> Void
    
    private var centralManager: CBCentralManager!
    
    
    
    public init(errorFn: @escaping (_ errorMessage: String) -> Void) {
        self.errorFn = errorFn
        self.discoveredDevices = []
        self.listeners_onDiscovered = nil
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [ String: Any ], rssi RSSI: NSNumber) {
        var deviceFound = false
        for discoveredDevice in self.discoveredDevices {
            if discoveredDevice == peripheral {
                deviceFound = true
                break
            }
        }
        
        if !deviceFound {
            if (peripheral.name != nil) {
                self.discoveredDevices.append(peripheral)
                if let listeners_onDiscovered {
                    listeners_onDiscovered()
                }
            } else {
                // print("Test: " + (peripheral.description ?? "-"))
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if (central.state != .poweredOn) {
            print("Central state is not powered on")
        } else {
            print("Central scanning...")
            if let centralManager {
                centralManager.scanForPeripherals(withServices: nil, options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true ])
            }
        }
    }
    
    public func getDiscoveredDevices() -> [CBPeripheral] {
        return self.discoveredDevices
    }
    
    public func setListener_OnDiscover(_ onDiscovered: @escaping () -> Void) {
        self.listeners_onDiscovered = onDiscovered
    }
    
    public func startScanning() {
        discoveredDevices = []
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        var showBluetoothPermissionWarning = false
        
//        var bluetoothPermission:Bool
        if #available(iOS 13.1, *) {
            showBluetoothPermissionWarning = CBCentralManager.authorization == .denied ||
                    CBCentralManager.authorization == .restricted
        } else if #available(iOS 13.0, *) {
            showBluetoothPermissionWarning = CBCentralManager().authorization == .denied ||
                    CBCentralManager().authorization == .restricted
        } else {
//            bluetoothPermission = true
        }

        if (showBluetoothPermissionWarning) {
            print("ABBluetoothDevices -> No bluetooth permission.")
            
            errorFn(Lang.t(TABBluetooth.errors_NoBluetoothPermission))
        } else {
            print("ABBluetoothDevices -> Starting scanning...")
        }
    }
    
    public func stopScanning() {
        if let centralManager {
            centralManager.stopScan()
        }
    }
    
}
