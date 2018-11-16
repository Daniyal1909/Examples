//
//  LanguageService.swift
//  MyTester
//
//  Created by Деветов Даниял on 08/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

fileprivate let appleLanguage = "AppleLanguages"

protocol LanguagesServiceProtocol {
    func getLanguages(ifSuccess: @escaping ([LanguageModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

final class LanguageService: LanguagesServiceProtocol {
    
    lazy var networkLayer: NetworkLayerProtocol = NetworkLayer()
    
    class func getCurrentLanguage() -> String {
        return ((UserDefaults.standard.value(forKey: appleLanguage) as? [String])?.first)!
    }
    
    class func setLanguage(code: String) {
        UserDefaults.standard.set([code], forKey: appleLanguage)
        Localizer.shared.setSelectedLanguage(lang: code)
        UserDefaults.standard.synchronize()
    }
    
    func getLanguages(ifSuccess: @escaping ([LanguageModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.getLanguages
        networkLayer.request(api: api, ifSuccess: { (result: [LanguageModel]) in
            ifSuccess(result)
        }, ifFailure: ifFailure)
    }
}
