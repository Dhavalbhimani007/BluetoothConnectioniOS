//
//  BLEServices.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import UIKit
import CoreBluetooth.CBPeripheral

/**
 This class was implemented to declared all variables here related to the BLE class
 */
final class BLEServices: NSObject {
    /// Instance of BLE Services
    static let shared = BLEServices()
    /// Ble manager scanner for device
    var scanner = BLEManager()
    /// Connected peripheral device data
    var connectedDevice: CBPeripheral?
    /// Read data of band characteristic
    var readCharacteristicDevice: CBCharacteristic?
}
