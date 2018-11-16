//
//  AuthorizationService.swift
//  MyTester
//
//  Created by Деветов Даниял on 17/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import Alamofire

protocol AuthorizationServiceProtocol {
    func auth(api: Api, ifSuccess: @escaping (AuthResponseModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func getCountryCodes(ifSuccess: @escaping ([String :[BaseCellModel]], [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func sendPhone(api: Api, ifSuccess: @escaping () -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

class AuthorizationService: AuthorizationServiceProtocol {
    lazy var networkLayer: NetworkLayerProtocol = NetworkLayer()
    
    func auth(api: Api, ifSuccess: @escaping (AuthResponseModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        networkLayer.request(api: api, ifSuccess: { (result: AuthResponseModel) in
            ifSuccess(result)
        }, ifFailure: ifFailure)
    }
    
    func getCountryCodes(ifSuccess: @escaping ([String :[BaseCellModel]], [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.getCountryPhoneCodes
        networkLayer.request(api: api, ifSuccess: { (result: [CountryPhoneCodeModel]) in
            let resultWithMask = Mapper.mapPhoneMasks(array: result)
            let dict = Mapper.mapCountryPhoneCodeToBaseCellModelDict(array: resultWithMask)
            let sections = dict.keys.sorted()
            ifSuccess(dict, sections)
        }, ifFailure: ifFailure)
    }
    
    func sendPhone(api: Api, ifSuccess: @escaping () -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        request(api.path, method: api.method, parameters: api.params, headers: nil).responseJSON { (responseJSON) in
            switch responseJSON.result {
            case.success:
                if responseJSON.result.value as? Bool ?? false {
                    ifSuccess()
                } else {
                    if let data = responseJSON.data {
                        do {
                            let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                            ifFailure(error)
                        } catch {
                            ifFailure(ErrorModel.Connection())
                        }
                    } else {
                        ifFailure(ErrorModel.Connection())
                    }
                }
            case .failure:
                ifFailure(ErrorModel.Connection())
            }
        }
    }
}
