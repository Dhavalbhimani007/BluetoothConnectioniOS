//
//  BLEDelegate.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import Foundation
import CoreBluetooth.CBPeripheral

extension BLEConnect: CBPeripheralDelegate {
    /// This method is invoked after a didUpdateValueFor:  call, or upon receipt of a notification/indication.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - characteristic: CB characteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let er = error {
            debugPrint("ERROR didUpdateValue \(er)")
            return
        }
        didUpdateValueFor(characteristic: characteristic)
    }

    /// This method returns the result of a setNotifyValue:forCharacteristic:  call.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - characteristic: CB characteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint(#function)
    }

    /// This method returns the result of a discoverServices: call. If the service(s) were read successfully, they can be retrieved via peripheral's services property.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            debugPrint(error?.localizedDescription ?? "")
            return
        }
        didDiscoverServices()
    }

    /// This method returns the result of a discoverCharacteristics:forService: call. If the characteristic(s) were read successfully, they can be retrieved via service's characteristics property.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - service: CB service
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didDiscoverCharacteristicsFor(peripheral: peripheral, service: service)
    }

    /// This method returns the result of a writeValue:forCharacteristic:type: call, when the CBCharacteristicWriteWithResponse type is used.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - characteristic: CB characteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("\(#function) Error: \(error?.localizedDescription ?? "not")")
    }

    /// This method returns the result of a discoverDescriptorsForCharacteristic: call. If the descriptors were read they can be retrieved via characteristic's descriptors property.
    /// - Parameters:
    ///   - peripheral: CB peripheral
    ///   - characteristic: CB characteristic
    ///   - error: Error
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        debugPrint("DiscoverDescriptors: ", characteristic)
    }
}
