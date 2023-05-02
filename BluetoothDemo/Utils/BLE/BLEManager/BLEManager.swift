//
//  BLEManager.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import CoreBluetooth
import os.log
/**
 BLE manager delegate
 */
protocol BLEManagerDelegate: AnyObject {
    /// Status changes
    func statusChanges(_ status: BLEManager.Status)
    /// When new peripherals found
    func newPeripherals()
}
/**
 Peripheral structer class
 */
public struct Peripheral: Hashable, Equatable {
    /// Instance of peripheral
    let peripheral: CBPeripheral
    /// Instance of rssi number
    let rssi: NSNumber
    /// Name of BLE Device
    let name: String

    /// Check equal method
    /// - Returns: `true` when two Peripheral object are equal otherwise `false`
    public static func == (lhs: Peripheral, rhs: Peripheral) -> Bool { lhs.peripheral.identifier == rhs.peripheral.identifier }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral)
    }
}
/**
 BLE manager object class
 */
final class BLEManager: NSObject {

    /// BLE status enum
    public enum Status {
        /// uninitialized
        case uninitialized
        /// Ready
        case ready
        /// Not ready
        case notReady(CBManagerState)
        /// Scanning
        case scanning
        /// Connecting
        case connecting(Peripheral)
        /// Connnected
        case connected(CBPeripheral)
        /// Disconnected
        case disconnect
        /// Failed to connect
        case failedToConnect(CBPeripheral, Error?)

        /// Return status name
        var singleName: String {
            switch self {
            case .connected(let p): return "\(ConstantsString.connectedTo) \(String(describing: p.name))"
            case .uninitialized: return ConstantsString.uninitialized
            case .ready: return ConstantsString.readyToScan
            case .notReady: return ConstantsString.notReady
            case .scanning: return ConstantsString.scanning
            case .connecting(let p): return "\(ConstantsString.connectingTo) \(p.name)"
            case .failedToConnect(let p, _): return "\(ConstantsString.failedToConnect) \(String(describing: p.name))"
            case .disconnect: return ConstantsString.disconnected
            }
        }
    }
    /// Service filter enable for band true/false
    var serviceFilterEnabled = true {
        didSet {
            refresh()
        }
    }
    /// Status of band
    private (set) var status: Status = .uninitialized {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.scannerDelegate?.statusChanges(self.status)
            }
        }
    }
    /// Central manager of discovered or connected remote peripheral devices
    var centralManager: CBCentralManager?
    /// Background queue
    private let bgQueue = DispatchQueue(label: "backgroundPeripheralSearch", qos: .utility)
    /// Dispatch source for remote peripheral devices
    private lazy var dispatchSource: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(queue: bgQueue)
        t.setEventHandler {
            let oldPeripherals = self.peripherals
            let oldSet: Set<Peripheral> = Set(oldPeripherals)
            self.tmpPeripherals.subtract(oldSet)
            let p = Array(self.tmpPeripherals)

            DispatchQueue.main.sync { [weak self] in
                guard let `self` = self else { return }

                self.peripherals += p
                self.peripherals = self.peripherals.sorted { $0.rssi.intValue > $1.rssi.intValue }
                self.scannerDelegate?.newPeripherals()
            }

            self.tmpPeripherals.removeAll()
        }
        return t
    }()
    /// Scanner delegate
    weak var scannerDelegate: BLEManagerDelegate? {
        didSet {
            scannerDelegate?.statusChanges(status)
        }
    }
    /// Set of peripheral devices
    private var tmpPeripherals = Set<Peripheral>()
    /// List of peripheral devices
    private (set) var peripherals: [Peripheral] = []

    // MARK: - Object lifecycle
    /// Initialize the CBCentral manager
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    /// Start scanning for ble device
    public func startScanning() {
        rescan()
        dispatchSource.schedule(deadline: .now() + .seconds(1), repeating: 2)
        dispatchSource.activate()
        status = .scanning
    }

    /// Refresh to scanning the ble device
    public func refresh() {
        stopScanning()
        peripherals.removeAll()
        tmpPeripherals.removeAll()
        rescan()
    }

    /// Stop scanning
    public func stopScanning() {
        centralManager?.stopScan()
        status = .ready
    }

    /// Connect ble device
    /// - Parameter peripheral: Request peripheral to connect selected peripheral
    public func connect(to peripheral: Peripheral) {
        stopScanning()
        status = .connecting(peripheral)
    }

    /// Rescannig ble device
    public func rescan() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        status = .scanning
    }
}

// MARK: - CBCentralManager delegate method
extension BLEManager: CBCentralManagerDelegate {
    /// Call this function when bluetooth state is change
    /// - Parameters: Data of CB central manager
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn, .resetting:
            status = .ready
        case .poweredOff, .unauthorized, .unknown, .unsupported:
            status = .notReady(central.state)
        @unknown default:
            break
        }
    }

    /// Call this function when any devices is found
    /// - Parameters:
    ///    - central: CB central manager
    ///    - peripheral: CB peripheral
    ///    - advertisementData: Advertisment data
    ///    - RSSI: Number
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Unnamed"
        let p = Peripheral(peripheral: peripheral, rssi: RSSI, name: peripheral.name ?? name)
        tmpPeripherals.insert(p)
    }

    /// Call this function when connect device
    /// - Parameters:
    ///    - central: CB central manager
    ///    - peripheral: CB peripheral
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        status = .connected(peripheral)
    }

    /// Call this function when disconnect the device
    /// - Parameters:
    ///    - central: CB central manager
    ///    - peripheral: CB peripheral
    ///    - error: Error
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        status = .disconnect
    }

    /// Call this funtion when device fail to connect
    /// - Parameters:
    ///    - central: CB central manager
    ///    - peripheral: CB peripheral
    ///    - error: Error
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        status = .failedToConnect(peripheral, error)
    }

}
