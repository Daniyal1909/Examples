//
//  NetworkLayer.swift
//  MyTester
//
//  Created by Деветов Даниял on 14/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkLayerProtocol {
    func request<T: Decodable>(api: Api, ifSuccess: @escaping (T) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

class NetworkLayer: NetworkLayerProtocol {
    func request<T: Decodable>(api: Api, ifSuccess: @escaping (T) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        Alamofire.request(api.path, method: api.method, parameters: api.params, headers: api.headers).responseJSON { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
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
