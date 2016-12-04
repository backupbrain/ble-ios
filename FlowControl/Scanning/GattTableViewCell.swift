//
//  PeripheralTableViewCell.swift
//  Services
//
//  Created by Adonis Gaitatzis on 11/21/16.
//  Copyright © 2016 Adonis Gaitatzis. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 GATT Charactersitic Table View Cell
 */
class GattTableViewCell: UITableViewCell {

    // MARK: UI Elements
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var readableLabel: UILabel!
    @IBOutlet weak var writeableLabel: UILabel!
    @IBOutlet weak var notifiableLabel: UILabel!
    @IBOutlet weak var noAccessLabel: UILabel!
    
    /**
     Initialize cell
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /**
     Cell was selected
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     Render the cell with Characteristic properties
     */
    func displayCharacteristic(characteristic: CBCharacteristic) {
        uuidLabel.text = characteristic.uuid.uuidString
        
        let isReadable = BlePeripheral.isCharacteristic(isReadable: characteristic)
        let isWriteable = BlePeripheral.isCharacteristic(isWriteable: characteristic)
        let isNotifiable = BlePeripheral.isCharacteristic(isNotifiable: characteristic)
        
        readableLabel.isHidden = !isReadable
        writeableLabel.isHidden = !isWriteable
        notifiableLabel.isHidden = !isNotifiable

        if isReadable || isWriteable || isNotifiable {
            noAccessLabel.isHidden = true
        } else {
            noAccessLabel.isHidden = false
        }
        
    }
    
    
}
