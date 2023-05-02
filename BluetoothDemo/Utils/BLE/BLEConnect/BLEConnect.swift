//
//  BLEConnect.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import Foundation
import CoreBluetooth.CBPeripheral
/**
 BLE connect delegate
 */
protocol BLEConnectDelegate: AnyObject {
    /// When BLE device did connect
    func didConnect()
    /// When BLE device did disconnect
    func didDisconnect()
    /// When BLE devices found
    func foundDevices()
    /// When fail to connect wit ble device
    func failToConnect()
}

/**
 This class was implemented to start scanning nearby BLE devices, connect device
 #Super Class:
       BaseViewController
 #Helper Classes:
    BLEServices
 */
final class BLEConnect: NSObject {

    /// Instance of BLE connect
    static let shared = BLEConnect()
    /// Connection delegate
    weak var delegateBLE: BLEConnectDelegate?
    /// Call back
    var completionHandler: CompletionHandler?
    ///  Object of BLE services
    let bleService = BLEServices.shared

    /// Setup the delegate's to the ble scanner & start sacnning near by devices
    /// - Parameter delegate: delegate of BLEConnect
    func setup(delegate: BLEConnectDelegate?) {
        delegateBLE = delegate
        bleService.scanner.scannerDelegate = self
        bleService.scanner.startScanning()
    }
}

// MARK: - BLEManager delegate method
extension BLEConnect: BLEManagerDelegate {
    /// Call this function when bluetooth state is change
    /// - Parameter Status: Status of band connection
    func statusChanges(_ status: BLEManager.Status) {
        switch status {
        case .connected(let p):
            if p == bleService.connectedDevice {
                delegateBLE?.didConnect()
                bleService.connectedDevice?.delegate = self
            }
        case .disconnect:
                delegateBLE?.didDisconnect()
        case .failedToConnect(_, let error):
            debugPrint("Fail To Connect: \(String(describing: error?.localizedDescription))")
            delegateBLE?.failToConnect()
        case .connecting:
            break
        case .ready:
            bleService.scanner.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .notReady:
            break
        default:
            break
        }
    }

    /// Call this function when any new devices is found
    /// - Parameters:
    ///   - peripherals: List of peripheral devices
    ///   - existing: List of existing peripheral devices
    func newPeripherals() {
        if !bleService.scanner.peripherals.isEmpty {
            delegateBLE?.foundDevices()
        }
    }
}
