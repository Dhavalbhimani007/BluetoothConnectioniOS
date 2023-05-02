//
//  BLECharacteristic.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//


import Foundation
import CoreBluetooth.CBPeripheral

/**
 BLE connect extension
 */
extension BLEConnect {
    /// Call this function when we can receive the data from device
    /// - Parameter characteristic: Characteristic of device
    func didUpdateValueFor(characteristic: CBCharacteristic) {

    }

    /// Using this function we can discover the services of device
    func didDiscoverServices() {
        guard let services = bleService.connectedDevice?.services else { return }
    }

    /// Using this function we can discover all the characteristics of device
    /// - Parameters:
    ///   - peripheral: Connected peripheral (band)
    ///   - service: Service of band
    func didDiscoverCharacteristicsFor(peripheral: CBPeripheral, service: CBService) {
        if let characteristics = service.characteristics {
            var strCharacteristics = ""
            for characteristic in characteristics {
                if strCharacteristics.isEmpty {
                    strCharacteristics = "=> \(characteristic)\n"
                } else {
                    strCharacteristics = "\(strCharacteristics)=> \(characteristic)\n"
                }
                    bleService.readCharacteristicDevice = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        completionHandler?()
    }
}
