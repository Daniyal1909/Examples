//
//  BaseTVCPresenter.swift
//  MyTester
//
//  Created by Деветов Даниял on 14/09/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

protocol BaseTVCPresenterProtocol {
    func getItems()
}

class BaseTVCPresenter: BaseTVCPresenterProtocol {
    weak var view: BaseTViewProtocol!
    var type: BaseTVCType!
    lazy var deviceService: DeviceServiceProtocol = DeviceService()
    lazy var feedbackService: FeedbackServiceProtocol = FeedbackService()
    
    init(view: BaseTViewProtocol, type: BaseTVCType) {
        self.view = view
        self.type = type
    }
    
    func getItems() {
        view.showLoading()
        
        let successBlock: ([BaseCellModel]) -> Void = { [weak self] (result) in
            guard let `self` = self else { return }
            guard !result.isEmpty else { return }
            self.view.setResults(items: result)
            self.view.hideLoading()
        }
        
        let failureBlock: (ErrorModel) -> Void = { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.showAlertWithOkAction(with: error.message ?? "Message")
        }
        switch type {
        case .deviceModel?:
            deviceService.getDeviceModels(ifSuccess: successBlock, ifFailure: failureBlock)
        case .typeOfUseDevice?:
            deviceService.getTypesOfUse(ifSuccess: successBlock, ifFailure: failureBlock)
        case  .messageSubject?:
            feedbackService.getMessageSubjects(ifSuccess: successBlock, ifFailure: failureBlock)
        default: break
        }
    }
}
