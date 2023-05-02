//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by PRODEV on 02/05/23.
//

import UIKit
import CoreBluetooth.CBPeripheral

class FetchBluetoothVC: UIViewController {

    //Outlets
    @IBOutlet weak var tblBluetoothList: UITableView!

    //Properies
    var arrDisconveredDevices: [Peripheral] = []

    //Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        scanBLEDevices()
    }

    private func setup() {
        tblBluetoothList.register(UINib(nibName: "BluetoothListCell", bundle: nil), forCellReuseIdentifier: "BluetoothListCell")
        tblBluetoothList.refreshControl = UIRefreshControl()
        tblBluetoothList.refreshControl?.addTarget(self,
           action: #selector(pulldownToRefresh), for: .valueChanged)
        tblBluetoothList.refreshControl?.tintColor = .gray
    }

    @objc func pulldownToRefresh() {
        rescanBLEDevices()
    }
    
    private func scanBLEDevices()  {
        BLEConnect.shared.setup(delegate: self)
        stopScanningAfter(seconds: 5)
    }
    
    func rescanBLEDevices() {
        arrDisconveredDevices = []
        tblBluetoothList.reloadData()
        BLEConnect.shared.refresh()
        stopScanningAfter(seconds: 5)
    }
    
    func stopScanningAfter(seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            BLEConnect.shared.stopScanning()
            self.tblBluetoothList.refreshControl?.endRefreshing()
        })
    }

    //MARK: Actions
    @IBAction func btnRescanClicked(_ sender: Any) {
        rescanBLEDevices()
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension FetchBluetoothVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDisconveredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothListCell") as? BluetoothListCell else { return UITableViewCell() }
        let peripheral = arrDisconveredDevices[indexPath.row]
        cell.lblTitle.text = peripheral.name
        cell.selectionStyle = .none
        cell.btnConnect.addTarget(self, action: #selector(btnConnectBluetoothClicked), for: .touchUpInside)
        switch peripheral.peripheral.state {
        case .connected:
            cell.btnConnect.setTitle("Connected", for: .normal)
        case .connecting:
            cell.btnConnect.setTitle("Connecting", for: .normal)
        case .disconnected:
            cell.btnConnect.setTitle("Connect", for: .normal)
        case .disconnecting:
            cell.btnConnect.setTitle("Disconnecting", for: .normal)
        @unknown default:
            cell.btnConnect.setTitle("Connect", for: .normal)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension FetchBluetoothVC {
    @objc func btnConnectBluetoothClicked(sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblBluetoothList)
        guard let indexPath = self.tblBluetoothList.indexPathForRow(at: buttonPosition) else {return}
        
        let peripheral = arrDisconveredDevices[indexPath.row]
        switch peripheral.peripheral.state {
        case .connected:
            let peripheral = arrDisconveredDevices[indexPath.row].peripheral
            BLEConnect.shared.disConnectDevice(peripheral: peripheral)
            break
        case .connecting:
            let peripheral = arrDisconveredDevices[indexPath.row].peripheral
            BLEConnect.shared.disConnectDevice(peripheral: peripheral)
            break
        case .disconnected:
            let peripheral = arrDisconveredDevices[indexPath.row].peripheral
            BLEConnect.shared.connectDevice(peripheral: peripheral)
        case .disconnecting:
            break
        @unknown default:
            break
        }
    }
}

//MARK: - BLEConnectDelegate
extension FetchBluetoothVC: BLEConnectDelegate {

    func didConnect() {
        BLEConnect.shared.stopScanning()
    }

    func didDisconnect() {
        debugPrint("didDisconnect")
    }

    func foundDevices() {
        arrDisconveredDevices = BLEServices.shared.scanner.peripherals
        tblBluetoothList.reloadData()
    }

    func failToConnect() {
        let alert = UIAlertController(title: "Failed to connnect", message: "Please try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in
             }))
        self.present(alert, animated: true, completion: nil)
    }
}
