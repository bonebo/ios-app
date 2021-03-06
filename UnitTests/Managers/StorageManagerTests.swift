//
//  UnitTests.swift
//  UnitTests
//
//  Created by Juraj Hilje on 26/12/2018.
//  Copyright © 2018 IVPN. All rights reserved.
//

import XCTest
import CoreData

@testable import IVPNClient

class StorageManagerTests: XCTestCase {

    override func tearDown() {
        StorageManager.clearSession()
    }

    func testSaveDefaultNetwork() {
        StorageManager.saveDefaultNetwork()
        let networks = StorageManager.fetchNetworks(isDefault: true)
        if let network = networks?.first {
            XCTAssertTrue(network.isDefault)
            XCTAssertEqual(network.name, "Default")
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testSaveCellularNetwork() {
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "Mobile data")
            XCTAssertEqual(network.type, NetworkType.cellular.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testSaveWiFiNetwork() {
        StorageManager.saveWiFiNetwork(name: "WiFi 1")
        let networks = StorageManager.fetchNetworks(name: "WiFi 1", type: NetworkType.wifi.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "WiFi 1")
            XCTAssertEqual(network.type, NetworkType.wifi.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testSaveNetwork() {
        StorageManager.saveNetwork(name: "WiFi 2", type: NetworkType.wifi.rawValue)
        let networks = StorageManager.fetchNetworks(name: "WiFi 2", type: NetworkType.wifi.rawValue)
        if let network = networks?.first {
            XCTAssertEqual(network.name, "WiFi 2")
            XCTAssertEqual(network.type, NetworkType.wifi.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testFetchDefaultNeworks() {
        StorageManager.saveDefaultNetwork()
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchDefaultNeworks()
        
        if let network = networks?.first {
            XCTAssertTrue(network.isDefault)
            XCTAssertEqual(network.name, "Default")
        } else {
            XCTFail("Network not found")
        }
        
        if let network = networks?.last {
            XCTAssertEqual(network.name, "Mobile data")
            XCTAssertEqual(network.type, NetworkType.cellular.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testGetTrust() {
        StorageManager.saveCellularNetwork()
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        if let network = networks?.first {
            let trust = StorageManager.getTrust(network: network)
            XCTAssertEqual(trust, NetworkTrust.Default.rawValue)
        } else {
            XCTFail("Network not found")
        }
    }
    
    func testRemoveNetworks() {
        StorageManager.saveCellularNetwork()
        StorageManager.remove(entityName: "Network")
        let networks = StorageManager.fetchNetworks(name: "Mobile data", type: NetworkType.cellular.rawValue)
        XCTAssertTrue(networks?.isEmpty ?? true)
    }
    
    func testRemoveNetwork() {
        StorageManager.saveWiFiNetwork(name: "WiFi to remove")
        StorageManager.removeNetwork(name: "WiFi to remove")
        let networks = StorageManager.fetchNetworks(name: "WiFi to remove")
        XCTAssertNil(networks, "Network was not deleted")
    }
    
    func testUpdateActiveNetwork() {
        let network = Network(context: StorageManager.context, needToSave: false)
        network.name = "Mobile data"
        network.type = NetworkType.cellular.rawValue
        network.trust = NetworkTrust.Default.rawValue
        Application.shared.network = network
        StorageManager.updateActiveNetwork(trust: NetworkTrust.Default.rawValue)
        XCTAssertEqual(Application.shared.network.trust, NetworkTrust.Default.rawValue)
    }

}
