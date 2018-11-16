//
//  FeedbackPresenter.swift
//  MyTester
//
//  Created by Деветов Даниял on 15/11/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation

protocol FeedbackPresenterProtocol {
    
}

class FeedbackPresenter: FeedbackPresenterProtocol {
    weak var view: FeedbackViewProtocol!
    lazy var feedbackService: FeedbackServiceProtocol = FeedbackService()
    
    init(view: FeedbackViewProtocol) {
        self.view = view
    }
    
    func sendMessage(model: FeedbackModel) {
        var params: [String : AnyObject] = [:]
        if let name = model.name {
            params["user_name"] = name as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "feedback.required_fields_error"))
            return
        }
        if let email = model.email {
            params["user_email"] = email as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "feedback.required_fields_error"))
            return
        }
        if let message = model.message {
            params["message"] = message as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "feedback.required_fields_error"))
            return
        }
        if let subjectID = model.subjectID {
            params["theme_id"] = subjectID as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "feedback.required_fields_error"))
            return
        }
        if let deviceID = model.deviceID {
            params["device_id"] = deviceID as AnyObject
        }
        view.showLoading()
        feedbackService.sendMessage(params: params, image: model.image, ifSuccess: { [weak self] in
            guard let `self` = self else { return }
            self.view.endSendingMessage()
        }, ifFailure: { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.showAlertWithOkAction(with: error.errors?.first?.message ?? error.message ?? Localizer.shared.stringForKey(key: "feedback.required_fields_error"))
        })
    }
}
