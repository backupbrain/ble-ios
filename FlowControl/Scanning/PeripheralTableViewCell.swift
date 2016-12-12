//
//  GattTableViewCell.swift
//  Services
//
//  Created by Adonis Gaitatzis on 11/21/16.
//  Copyright © 2016 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 Peripheral Table View Cell
 */
class PeripheralTableViewCell: UITableViewCell {
    
    // MARK: UI elements
    @IBOutlet weak var broadcastNameLabel: UILabel!
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    /**
     Render Cell with Peripheral properties
     */
    func displayPeripheral(blePeripheral: BlePeripheral) {
        broadcastNameLabel.text = blePeripheral.broadcastName
        identifierLabel.text = blePeripheral.peripheral.identifier.uuidString
        rssiLabel.text = blePeripheral.rssi.stringValue
    }

}
