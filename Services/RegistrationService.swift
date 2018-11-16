//
//  RegistrationService.swift
//  MyTester
//
//  Created by Деветов Даниял on 12/11/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import Alamofire

protocol RegistrationServiceProtocol {
    func register(parameters: [String: AnyObject], token: String, ifSuccess: @escaping (UserRegistrationResultModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

final class RegistrationService: RegistrationServiceProtocol {
    
    func register(parameters: [String: AnyObject], token: String, ifSuccess: @escaping (UserRegistrationResultModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.registration
        let headers = ["Authorization" : "Bearer \(token)"]
        request(api.path, method: api.method, parameters: parameters, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    do {
                        let result = try JSONDecoder().decode(UserRegistrationResultModel.self, from: data)
                        ifSuccess(result)
                    } catch {
                        do {
                            let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                            ifFailure(error)
                        } catch {
                            ifFailure(ErrorModel.Connection())
                        }
                    }
                } else {
                    ifFailure(ErrorModel.Connection())
                }
            case .failure:
                ifFailure(ErrorModel.Connection())
            }
        }
    }
}
