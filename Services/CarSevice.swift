//
//  CarSevice.swift
//  MyTester
//
//  Created by Деветов Даниял on 03/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

protocol CarServiceProtocol {
    func getBrands(ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func getModels(brandID: Int, ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func getYears(modelID: Int, ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func getCarThickness(api: Api, ifSuccess: @escaping (CarThicknessValue) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

class CarService: CarServiceProtocol {
    lazy var networkLayer: NetworkLayerProtocol = NetworkLayer()
    
    func getBrands(ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.getCarBrands
        networkLayer.request(api: api, ifSuccess: { (result: [CarBrandModel]) in
            Mapper.mapCarBrandToBaseCellModel(array: result, completion: { (mapped) in
                let dict = Mapper.mapArrayArrToAlphabeticDictionary(array: mapped)
                let sections = dict.keys.sorted()
                ifSuccess(dict, sections)
            })
        }, ifFailure: ifFailure)
    }
    
    func getModels(brandID: Int, ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.getCarModels(brandID: brandID)
        networkLayer.request(api: api, ifSuccess: { (result : [BaseModel]) in
            let dict = Mapper.mapArrayArrToAlphabeticDictionary(array: result)
            let sections = dict.keys.sorted()
            ifSuccess(dict, sections)
        }, ifFailure: ifFailure)
    }
    
    func getYears(modelID: Int, ifSuccess: @escaping (_ dict: [String : [BaseCellModel]], _ sections: [String]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.getCarYears(modelID: modelID)
        networkLayer.request(api: api, ifSuccess: { (result: [CarYearModel]) in
            let baseCellArr = Mapper.mapCarYearToBaseModel(array: result)
            let dict = Mapper.mapArrayArrToAlphabeticDictionary(array: baseCellArr)
            let sections = dict.keys.sorted()
            ifSuccess(dict, sections)
        }, ifFailure: ifFailure)
    }
    
    func getCarThickness(api: Api, ifSuccess: @escaping (CarThicknessValue) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        networkLayer.request(api: api, ifSuccess: { (result: CarThicknessValue) in
            ifSuccess(result)
        }, ifFailure: ifFailure)
    }
}
