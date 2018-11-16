//
//  Api.swift
//  MyTester
//
//  Created by Деветов Даниял on 14/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import Alamofire

enum Api {
    case deviceModels
    case typesOfUse
    case sellers
    case deviceRegistration
    case deviceList
    case deteiledDevice(id: Int)
    case getCarBrands
    case getCarModels(brandID: Int)
    case getCarYears(modelID: Int)
    case getLanguages
    case getCarThicknessValue(brandID: Int, modelID: Int, yearID: Int)
    case getCountryPhoneCodes
    case sendPhone(phone: String)
    case auth(phone: String, code: String)
    case registration
    case messageSubjects
    case feedback
}

extension Api {
    
    //Ссылка удалена в целях безопасности
    var baseURL: String {
        switch self {
        default: return ""
        }
    }
    
    var path: String {
        switch self {
        case .deviceModels: return "\(baseURL)device-model/list"
        case .typesOfUse: return "\(baseURL)type-use/list?id=1"
        case .sellers: return "\(baseURL)seller/list"
        case .deviceRegistration: return "\(baseURL)device/registration"
        case .deviceList: return "\(baseURL)device/list"
        case .deteiledDevice(let id): return "\(baseURL)device/detail?id=\(id)"
        case .getCarBrands: return "\(baseURL)brand-car/list"
        case .getCarModels(let id): return "\(baseURL)model-car/list?brand_id=\(id)"
        case .getCarYears(let id): return "\(baseURL)year-car/list?model_id=\(id)"
        case .getLanguages: return "\(baseURL)language/list"
        case .getCarThicknessValue(let brandID, let modelID, let yearID): return "\(baseURL)thickness-table/get-value?brand_id=\(brandID)&model_id=\(modelID)&year_id=\(yearID)"
        case .getCountryPhoneCodes: return "http://jsonstub.com/countries"
        case .sendPhone: return "\(baseURL)user/get-code"
        case .auth(let phone, let code): return "http://\(phone):\(code)@my-tester.diitcenter.ru/api/v1/user/auth"
        case .registration: return "\(baseURL)user/registration"
        case .messageSubjects: return "\(baseURL)callback/theme-list?id=1"
        case .feedback: return "\(baseURL)callback/send-letter"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .deviceModels, .typesOfUse, .sellers, .deviceList, .deteiledDevice, .getCarYears, .getCarModels, .getCarBrands, .getLanguages, .getCarThicknessValue, .getCountryPhoneCodes, .auth, .messageSubjects: return .get
        case .deviceRegistration, .sendPhone, .registration, .feedback: return .post
        }
    }
    
    var params: [String : Any]? {
        switch self {
        case .sendPhone(let phone):
            return ["phone" : phone]
        default: return nil
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .getCountryPhoneCodes:
            return [
                "Content-Type" : "application/json",
                "JsonStub-User-Key" : "3b7943a4-d826-4b5b-a302-9dfff3ea3c23",
                "JsonStub-Project-Key" : "e0c55578-5377-4840-bae0-5eab0d0775b8"
            ]
        default:
            return ["Authorization" : "Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")"]
        }
    }
}
