//
//  BLEManager.swift
//  phoneapp
//
//  Created by Jalen Gabbidon on 9/3/20.
//  Copyright © 2020 Jalen Gabbidon. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

struct Central: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}

class BLEManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    @Published var isPoweredOn = false


    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
                   isPoweredOn = true
                    addServices()
               } else {
                   isPoweredOn = false
               }
    }
    
    
    private var service: CBUUID!
    private let value = "AD34E"
    
    func addServices() {
        let valueData = value.data(using: .utf8)
         // 1. Create instance of CBMutableCharcateristic
        let poseData = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.notify, .write, .read], value: nil, permissions: [.readable, .writeable])
        let videoTimestamps = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.read], value: valueData, permissions: [.readable])
        // 2. Create instance of CBMutableService
        service = CBUUID(nsuuid: UUID())
        let myService = CBMutableService(type: service, primary: true)
        // 3. Add characteristics to the service
        myService.characteristics = [poseData, videoTimestamps]
        // 4. Add service to peripheralManager
        peripheralManager.add(myService)
        // 5. Start advertising
        startAdvertising()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("This function was called correctly")
    }
    
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey : "LCA: " + UIDevice().name, CBAdvertisementDataServiceUUIDsKey :     [service]])
        print("Started Advertising")
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        peripheralManager.delegate = self
    }
    
}
