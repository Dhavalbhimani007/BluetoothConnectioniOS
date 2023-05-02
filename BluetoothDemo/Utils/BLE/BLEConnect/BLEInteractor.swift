//
//  BLEInteractor.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import Foundation
import UIKit
import CoreBluetooth.CBPeripheral

/**
 BLE connect extension
 */
extension BLEConnect {
    /// Refresh to scanning the ble device
    func refresh() {
        bleService.scanner.refresh()
    }

    /// Stop scanning
    func stopScanning() {
        bleService.scanner.stopScanning()
    }

    /// Connect device to selected peripheral
    /// - Parameter peripheral: Data of peripheral devices
    func connectDevice(peripheral: CBPeripheral) {
        bleService.connectedDevice = peripheral
        bleService.scanner.centralManager?.connect(peripheral, options: nil)
    }

    /// Disconnect device
    func disConnectDevice(peripheral: CBPeripheral) {
        bleService.scanner.centralManager?.cancelPeripheralConnection(peripheral)
    }

    /// Check bluetooth is on/off
    /// - Returns: True/False
    func isBluetoothOn() -> Bool {
        return bleService.scanner.centralManager?.state == .poweredOn
    }
}

/// Convert Data to HexString
extension Data {
    /// Data to hex string
    internal var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
