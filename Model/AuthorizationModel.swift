//
//  AuthorizationModel.swift
//  MyTester
//
//  Created by Деветов Даниял on 18/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

class AuthorizationModel {
    var phone: String {
        return mutablePhone
    }
    private var mutablePhone = ""
    var code = ""
    
    func set(phone: String) {
        var mutablePhone = phone
        mutablePhone = mutablePhone.replacingOccurrences(of: "+", with: "")
        mutablePhone = mutablePhone.replacingOccurrences(of: " ", with: "")
        self.mutablePhone = mutablePhone
    }
}
