//
//  DeviceModel.swift
//  MyTester
//
//  Created by Деветов Даниял on 20/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

class DeviceModel: Decodable {
    var id: Int!
    var model: String!
    var dateOfPurchase: String?
    var deviceImage: String?
    var warrantyCardImage: String?
    var serialNumber: String?
    var sellerName: String?
    var warrantyTo: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case model
        case dateOfPurchase = "date_of_purchase"
        case deviceImage = "img_device"
        case warrantyCardImage = "img_warranty_card"
        case serialNumber = "serial_number"
        case sellerName = "seller"
        case warrantyTo = "warranty_up_to"
    }
}
