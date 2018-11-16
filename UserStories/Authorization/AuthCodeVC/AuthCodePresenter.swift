//
//  AuthCodePresenter.swift
//  MyTester
//
//  Created by Деветов Даниял on 18/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

protocol AuthCodePresenterProtocol {
    func sendPhone()
    func sendCode()
}

class AuthCodePresenter: AuthCodePresenterProtocol {
    weak var view: AuthCodeViewProtocol!
    lazy var authService: AuthorizationServiceProtocol = AuthorizationService()
    
    init(view: AuthCodeViewProtocol) {
        self.view = view
    }
    
    func sendPhone() {
        view.showLoading()
        let api = Api.sendPhone(phone: view.registrationModel.phone)
        authService.sendPhone(api: api, ifSuccess: { [weak self] in
            guard let `self` = self else { return }
            self.view.hideLoading()
        }, ifFailure: { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.showAlertWithOkAction(with: error.message ?? ErrorModel.Connection().message!)
        })
    }
    
    func sendCode() {
        view.showLoading()
        let api = Api.auth(phone: view.registrationModel.phone, code: view.registrationModel.code)
        authService.auth(api: api, ifSuccess: { [weak self] (result) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            if result.isRegister {
                UserDefaults.standard.set(result.token, forKey: "token")
                UserDefaults.standard.set("auth", forKey: "session")
                self.view.goToMenu()
            } else {
                self.view.goToRegistration(authResponse: result)
            }
        }, ifFailure: { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.showAlertWithOkAction(with: error.message ?? ErrorModel.Connection().message!)
        })
    }
}
