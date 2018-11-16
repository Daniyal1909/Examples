//
//  BaseCellModel.swift
//  MyTester
//
//  Created by Деветов Даниял on 10/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit

class BaseCellModel: Decodable {
    var id = 0
    var title = ""
    var secondTitle = ""
    var topSpace = 1
    var bottomSpace = 0
    var image: UIImage?
    var rightImage: UIImage = #imageLiteral(resourceName: "ic_closure")
    var isActive = true
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
    }
    
    convenience init(id: Int, title: String) {
        self.init()
        self.id = id
        self.title = title
    }
}
