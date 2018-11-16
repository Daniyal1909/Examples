//
//  AuthPhonePresenter.swift
//  MyTester
//
//  Created by Деветов Даниял on 15/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

protocol AuthPhonePresenterProtocol {
    func send(phone: String)
}

class AuthPhonePresenter: AuthPhonePresenterProtocol {
    weak var view: AuthPhoneViewProtocol!
    lazy var authService: AuthorizationServiceProtocol = AuthorizationService()
    
    init(view: AuthPhoneViewProtocol) {
        self.view = view
    }
    
    func send(phone: String) {
        let resultPhone = cleanPhone(phone: phone)
        let api = Api.sendPhone(phone: resultPhone)
        view.showLoading()
        authService.sendPhone(api: api, ifSuccess: { [weak self] in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.goToAuthorizationVC(with: resultPhone)
        }, ifFailure: { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.showAlertWithOkAction(with: error.message ?? ErrorModel.Connection().message ?? "")
        })
    }
    
    private func cleanPhone(phone: String) -> String {
        var mutablePhone = phone
        mutablePhone = mutablePhone.replacingOccurrences(of: "+", with: "")
        mutablePhone = mutablePhone.replacingOccurrences(of: " ", with: "")
        return mutablePhone
    }
}
