//
//  ViewController.swift
//  Bootstrapping
//
//  Created by Adonis Gaitatzis on 11/15/16.
//  Copyright © 2016 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 This view lists the GATT profile of a connected characteristic
 */
class PeripheralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, BlePeripheralDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var broadcastNameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var gattProfileTableView: UITableView!
    @IBOutlet weak var gattTableView: UITableView!
    
    // UITableViewCell nib identifier
    let gatCellNibName = "GattTableViewCell"
    
    // UITableView cell reuse identifier
    let gattCellReuseIdentifier = "GattTableViewCell"
    
    // MARK: Connected Devices
    
    // Bluetooth Radio
    var centralManager:CBCentralManager!
    
    // Bluetooth Peripheral
    var blePeripheral:BlePeripheral!
    
    
    /**
     UIView loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Will connect to \(blePeripheral.peripheral.identifier.uuidString)")
        
        // Assign delegates
        blePeripheral.delegate = self
        centralManager.delegate = self
        centralManager.connect(blePeripheral.peripheral)
    }
    
    /**
     Ran out of memory
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Load UI elements
     */
    func loadUI() {
        // load the UITableView
        let nib = UINib(nibName: gatCellNibName, bundle: nil)
        gattTableView.register(nib, forCellReuseIdentifier: gattCellReuseIdentifier)
    }
    
    
    // MARK: BlePeripheralDelegate
    
    /**
     Characteristics were discovered.  Update the UI
     */
    func blePerihperal(discoveredCharacteristics characteristics: [CBCharacteristic], forService: CBService, blePeripheral: BlePeripheral) {
        gattTableView.reloadData()
    }
    
    /**
     RSSI discovered.  Update UI
     */
    func blePeripheral(readRssi rssi: NSNumber, blePeripheral: BlePeripheral) {
        rssiLabel.text = rssi.stringValue
    }
    
    /**
    Characteristic was read.  Not needed in this UIView
     */
    func blePeripheral(characteristicRead stringValue: String, characteristic: CBCharacteristic, blePeripheral: BlePeripheral) {
    }
    
    /**
     Characteristic was written to.  Not needed in this UIView
     */
    func blePeripheral(valueWritten characteristic: CBCharacteristic, blePeripheral: BlePeripheral) {
        
    }
    
    /**
     Characteristic was connected to.  Not needed in this UIView
     */
    func blePeripheral(connectedToCharacteristic characteristic: CBCharacteristic, blePeripheral: BlePeripheral) {
        
    }
    
    /**
     Characteristic subscription state changed.  Not needed in this UIView
     */
    func blePeripheral(subscriptionStateChanged subscribed: Bool, characteristic: CBCharacteristic, blePeripheral: BlePeripheral) {
        
    }
    
    
    // MARK: CBCentralManagerDelegate code
    
    /**
     Peripheral connected.  Update UI
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected Peripheral: \(peripheral.name)")
        
        broadcastNameLabel.text = blePeripheral.broadcastName
        identifierLabel.text = blePeripheral.peripheral.identifier.uuidString
        
        blePeripheral.connected(peripheral: peripheral)
    }
    
    /**
     Connection to Peripheral failed.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed to connect")
        print(error.debugDescription)
    }
    
    /**
     Peripheral disconnected.  Leave UIView
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected Peripheral: \(peripheral.name)")
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Bluetooth radio state changed.
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager updated: checking state")
        
        switch (central.state) {
        case .poweredOn:
            print("bluetooth on")
        default:
            print("bluetooth unavailable")
        }
    }
    

    
    // MARK: UITableViewDataSource

    /**
     Return number of rows in Service section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("returning num rows in section")
        if section < blePeripheral.gattProfile.count {
            if let characteristics = blePeripheral.gattProfile[section].characteristics {
                return characteristics.count
            }
        }
        return 0
    }
    
    /**
     Return a rendered cell for a Characteristic
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("returning table cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: gattCellReuseIdentifier, for: indexPath) as! GattTableViewCell
        
        
        print("section: indexPath.section")
        print("row: indexPath.row")
        print(indexPath)
        let section = indexPath.section
        let row = indexPath.row
        
        
        if section < blePeripheral.gattProfile.count {
            if let characteristics = blePeripheral.gattProfile[section].characteristics {
                if row < characteristics.count {
                    cell.displayCharacteristic(characteristic: characteristics[row])
                }
            }
        }
        
        return cell
    }
    
    /**
     Return the number of Service sections
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        print("returning number of sections")
        print(blePeripheral)
        print(blePeripheral.gattProfile)
        return blePeripheral.gattProfile.count
    }
    
    /**
     Return the title for a Service section
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print("returning title at section \(section)")
        if section < blePeripheral.gattProfile.count {
            return blePeripheral.gattProfile[section].uuid.uuidString
        }
        return nil
    }
    
    /**
     User selected a Characteristic table cell.  Update UI and open the next UIView
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = indexPath.row
        print("Selected Row: \(selectedRow)")
        
    }
    
    
    
    // MARK: Navigation
    
    /**
     Handle the Segue.  Prepare the next UIView with necessary information
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("leaving view - disconnecting from peripheral")
        
        if let indexPath = gattTableView.indexPathForSelectedRow {
            let selectedSection = indexPath.section
            let selectedRow = indexPath.row
            
            print("Selected Row: \(selectedRow)")
            
            let characteristicViewController = segue.destination as! CharacteristicViewController
            
            if selectedSection < blePeripheral.gattProfile.count {
                let service = blePeripheral.gattProfile[selectedSection]
                
                if let characteristics = blePeripheral.gattProfile[selectedSection].characteristics {
                    
                    if selectedRow < characteristics.count {
                        blePeripheral.connectedService = service
                        blePeripheral.connectedCharacteristic = characteristics[selectedRow]
                        
                        // populate next UIView with necessary information
                        characteristicViewController.centralManager = centralManager
                        characteristicViewController.blePeripheral = blePeripheral
                    }
                    
                }
            }
            
            gattTableView.deselectRow(at: indexPath, animated: false)
        }
    
        
    }
    


    
}

