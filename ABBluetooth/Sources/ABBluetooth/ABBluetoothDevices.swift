//
//  BluetoothPrinter.swift
//  Rocko Interval Timer
//
//  Created by Jakub Zolcik on 16/03/2021.
//

import CoreBluetooth
import SwiftUI

public class ABBluetoothDevices: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    private var onDiscoverFn: ((DiscoverState, ABBluetoothDevices) -> Void)?
    private var discoveredDevices = [CBPeripheral]()
    
    private var centralManager: CBCentralManager!
//    private var peripheral: CBPeripheral!
//    private var characteristic: CBCharacteristic!
//    private var dataToSend: Data!
    
    
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
                self.onDiscoverFn!(DiscoverState.DeviceDiscovered, self)
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
            self.centralManager!.scanForPeripherals(withServices: nil, options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true ])
        }
    }
    
    public func getDiscoveredDevices() -> [CBPeripheral] {
        return self.discoveredDevices
    }
    
    public func onDiscover(_ onDiscover: @escaping (DiscoverState, ABBluetoothDevices) -> Void) {
        self.onDiscoverFn = onDiscover
    }
    
    public func startScanning() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
      
        var bluetoothPermission:Bool
        if #available(iOS 13.1, *) {
            bluetoothPermission = CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            bluetoothPermission = CBCentralManager().authorization == .allowedAlways
        } else {
            bluetoothPermission = true
        }
        
        if (!bluetoothPermission) {
            print("No bluetooth permission.")
            
            let alert = UIAlertController(title: "Brak Pozwolenia Bluetooth", message: "Żeby skorzystać z funkcji Bluetooth musisz zezwolić na jego wykorzystanie w ustawieniach telefonu.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            UIApplication.shared.windows.last?.rootViewController?.present(alert, animated: true)
        } else {
            print("Starting scanning...")
        }
    }
    
    public func stopScanning() {
        self.centralManager!.stopScan()
    }
    
    
    private func extractData(from data: inout Data) -> Data? {
        guard data.count > 0 else {
            return nil
        }
        
        let length = min(100, data.count)
        let range = 0..<length
        let subData = data.subdata(in: range)
        data.removeSubrange(range)
        
        return subData
    }
    
    
    
    public enum DiscoverState {
        case Finished
        case DeviceDiscovered
    }
    
}
