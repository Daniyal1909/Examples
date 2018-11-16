//
//  DeviceService.swift
//  MyTester
//
//  Created by Деветов Даниял on 15/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit
import Alamofire

protocol DeviceServiceProtocol {
    func getDeviceModels(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping(ErrorModel) -> Void)
    func getTypesOfUse(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping(ErrorModel) -> Void)
    func getSellers(ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping(ErrorModel) -> Void)
    func registerDevice(params: [String : Any], warrantyCardImage: UIImage?, ifSuccess: @escaping () -> Void, ifFailure: @escaping(ErrorModel) -> Void)
    func getDeviceList(ifSuccess: @escaping ([DeviceModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func getDeviceWith(id: Int, ifSuccess: @escaping (DeviceModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

class DeviceService: DeviceServiceProtocol {
    lazy var networkLayer: NetworkLayerProtocol = NetworkLayer()
    
    func getDeviceModels(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping(ErrorModel) -> Void) {
        networkLayer.request(api: .deviceModels, ifSuccess: { (result: [BaseModel]) in
            ifSuccess(Mapper.mapBaseModelToCellModel(items: result))
        }, ifFailure: ifFailure)
    }
    
    func getTypesOfUse(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping(ErrorModel) -> Void) {
        networkLayer.request(api: .typesOfUse, ifSuccess: { (result: [TypesOfUse]) in
            ifSuccess(Mapper.mapTypeOfUseToCellModel(items: result))
        }, ifFailure: ifFailure)
    }
    
    func getSellers(ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping(ErrorModel) -> Void) {
        networkLayer.request(api: Api.sellers, ifSuccess: { (result: [BaseModel]) in
            let dict = Mapper.mapArrayArrToAlphabeticDictionary(array: result)
            let sections = dict.keys.sorted()
            ifSuccess(dict, sections)
        }, ifFailure: ifFailure)
    }
    
    func registerDevice(params: [String : Any], warrantyCardImage: UIImage?, ifSuccess: @escaping () -> Void, ifFailure: @escaping(ErrorModel) -> Void) {
        let api = Api.deviceRegistration
        var image = warrantyCardImage
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if warrantyCardImage != nil {
                if image!.size.width > 1000 || image!.size.height > 1000 {
                    image = image?.resizeImage(targetSize: CGSize(width: 1000, height: 1000))
                }
                if let imageData = image?.jpegData(compressionQuality: 1) {
                    print(imageData)
                    multipartFormData.append(imageData, withName: "warranty_card", fileName: "file.png", mimeType: "image/png")
                }
            }
            
            for (key, value) in params as [String : Any] {
                    multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
            }}, to: api.path, method: api.method, headers: api.headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if (response.result.value as? Bool) == true {
                                ifSuccess()
                            } else {
                                do {
                                    var readableJson = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: AnyObject]
                                    if (readableJson?["message"] as? String) != nil {
                                        if let data = response.data {
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
                                } catch {
                                    print(error.localizedDescription)
                                    ifFailure(ErrorModel.Connection())
                                }
                            }
                        }
                    case .failure:
                        ifFailure(ErrorModel.Connection())
                    }
        })
    }
    
    func getDeviceList(ifSuccess: @escaping ([DeviceModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.deviceList
        networkLayer.request(api: api, ifSuccess: { (result: [DeviceModel]) in
            ifSuccess(result)
        }, ifFailure: ifFailure)
    }
    
    func getDeviceWith(id: Int, ifSuccess: @escaping (DeviceModel) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.deteiledDevice(id: id)
        networkLayer.request(api: api, ifSuccess: { (result: DeviceModel) in
            ifSuccess(result)
        }, ifFailure: ifFailure)
    }
}
