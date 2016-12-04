//
//  PeripheralTableViewController.swift
//  Scanning
//
//  Created by Adonis Gaitatzis on 11/15/16.
//  Copyright © 2016 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 This view lists Peripherals during a Bluetooth Low Energy Scan
 */
class PeripheralTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var scanButton: UIButton!
    
    // Default unknown broadcast name
    let unknownBroadcastName = "(UNMARKED)"
    
    // PeripheralTableViewCell reuse identifier
    let peripheralCellReuseIdentifier = "PeripheralTableViewCell"
    
    
    // MARK: Scan Properties
    
    // scan timeout in seconds
    let scanTimeout_s = 5;
    
    // Current scan countdown
    var scanCountdown = 0
    
    // Scan timer
    var scanTimer:Timer!
    
    // Central Bluetooth Manager
    var centralManager:CBCentralManager!
    
    // Discovered Bluetooth Peripherals
    var blePeripherals = [BlePeripheral]()
    
    
    
    /**
     View loaded.  Start Bluetooth radio.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    /**
     Ran out of memory.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    User touched Scan Button.  Start or stop Bluetooth scan
     */
    @IBAction func onScanButtonClicked(_ sender: UIButton) {
        print("scan button clicked")
        // if scanning
        if centralManager.isScanning {
            stopBleScan()
        } else {
            startBleScan()
        }
    }

    
    /**
     Start Bluetooth Scan.  Update UI
     */
    func startBleScan() {
        scanButton.setTitle("Stop", for: UIControlState.normal)
        blePeripherals.removeAll()
        tableView.reloadData()
        print ("discovering devices")
        scanCountdown = scanTimeout_s
        scanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onScanCounterUpdated), userInfo: nil, repeats: true)
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /**
    Stop the Bluetooth Scan.  Update UI
     */
    func stopBleScan() {
        centralManager!.stopScan()
        scanTimer.invalidate()
        scanButton.setTitle("Start", for: UIControlState.normal)
    }
    
    /**
     Scan countdown timer update.  Update UI
     */
    func onScanCounterUpdated() {
        //you code, this is an example
        if scanCountdown > 0 {
            print("\(scanCountdown) seconds until Ble Scan ends")
            scanCountdown -= 1
        } else {
            stopBleScan()
        }
    }
    

    /**
     Peripheral Manager updated state.  Not needed in this UIView
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // do nothing
    }

    
    // MARK:  CBCentralManagerDelegate Functions
    
    /**
     centralManager is called each time a new Peripheral is discovered
     
     - parameters
     - central: the CentralManager for this UIView
     - peripheral: A discovered Peripheral
     - advertisementData: The Bluetooth advertisement data discevered with the Peripheral
     - rssi: the radio signal strength indicator for this Peripheral
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Discovered \(peripheral.name)")
        print("Discovered \(peripheral.identifier.uuidString) (\(peripheral.name))")
        
        // don't list if the Peripheral does not have  name
        
            var peripheralFound = false
            for blePeripheral in blePeripherals {
                if blePeripheral.peripheral.identifier == peripheral.identifier {
                    peripheralFound = true
                    break
                }
            }
            
            // don't duplicate discovered devices
            if !peripheralFound {
                
                // Broadcast name in advertisement data may be different than the actual broadcast name
                // It's ideal to use the advertisement data version as it's supported on programmable bluetooth devices
                var broadcastName = unknownBroadcastName
                if let alternateName = BlePeripheral.getAlternateBroadcastFromAdvertisementData(advertisementData: advertisementData) {
                    if alternateName != "" {
                        broadcastName = alternateName
                    } else {
                        if let peripheralName = peripheral.name{
                            broadcastName = peripheralName
                        }
                    }
                }
                
                // if the device is not connectable, then there's no point in listing it
                let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
                if (isConnectable) {
                    let blePeripheral = BlePeripheral(delegate: nil, peripheral: peripheral)
                    blePeripheral.rssi = RSSI
                    blePeripheral.broadcastName = broadcastName
                    blePeripherals.append(blePeripheral)
                    tableView.reloadData()
                    
                }
                
            }
        
    }
    
    
    
    
    /**
     Bluetooth radio state changed
     
     - Parameters:
     - central: the reference to the central
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            print ("BLE Hardware powered on and ready")
            scanButton.isEnabled = true
            //navigationController
        default:
            scanButton.isEnabled = false
            print ("Ble not unavailable")
        }
    }

    
    // MARK: - Table view data source
    
    /**
     return number of sections.  Only 1 is needed
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     Return number of Peripheral cells
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blePeripherals.count
    }

    
    /**
     Return rendered Peripheral cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: peripheralCellReuseIdentifier, for: indexPath) as! PeripheralTableViewCell
        
        // fetches the appropritae peripheral for the data source layout
        let blePeripheral = blePeripherals[indexPath.row]

        cell.displayPeripheral(blePeripheral: blePeripheral)

        return cell
    }
    
    /**
     User selected a Peripheral.  Update UI
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stopBleScan()
        
        let selectedRow = indexPath.row
        print("Row: \(selectedRow)")
        
        // if connection is not possible, deselect row
        if selectedRow < blePeripherals.count {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        print(blePeripherals[selectedRow])
    }
    
 
    // MARK: Navigation
    
    /**
     Prepare for segue.  Populate next UIView with necessary information
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let peripheralViewController = segue.destination as! PeripheralViewController
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let selectedRow = selectedIndexPath.row
            
            if selectedRow < blePeripherals.count {
                // prepare next UIView
                peripheralViewController.centralManager = centralManager
                peripheralViewController.blePeripheral = blePeripherals[selectedRow]
            }

            
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
    }

    

    
}
