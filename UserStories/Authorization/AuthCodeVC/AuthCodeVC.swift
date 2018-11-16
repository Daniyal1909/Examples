//
//  AuthCodeVC.swift
//  MyTester
//
//  Created by Деветов Даниял on 18/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit
import AKMaskField

protocol AuthCodeViewProtocol: BaseViewProtocol {
    var registrationModel: AuthorizationModel { get set }
    
    func showLoading()
    func hideLoading()
    func goToRegistration(authResponse: AuthResponseModel)
    func goToMenu()
}

class AuthCodeVC: UIViewController {
    
    @IBOutlet var codeLabels: [UILabel]!
    @IBOutlet weak var codeTextField: AKMaskField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var sendCodeAgainButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    var timer = Timer()
    var timeInterval = 59
    var registrationModel = AuthorizationModel()
    var presenter: AuthCodePresenterProtocol!
    var countryFromAuth = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = AuthCodePresenter(view: self)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        codeTextField.maskDelegate = self
        codeTextField.setMask("{dddd}", withMaskTemplate: "    ")
        startTimer()
    }
    
    func startTimer() {
        timerLabel.text = "Отправить повторно через 1:00 мин"
        timerLabel.isHidden = false
        sendCodeAgainButton.isHidden = true
        timeInterval = 59
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if self.timeInterval == 0 {
                self.stopTimer()
            }
            var stringTime = "\(self.timeInterval)"
            if stringTime.count == 1 {
                stringTime.insert("0", at: stringTime.startIndex)
            }
            self.timerLabel.text = "Отправить повторно через 0:\(stringTime) мин"
            self.timeInterval -= 1
        })
    }
    
    func stopTimer() {
        timerLabel.isHidden = true
        sendCodeAgainButton.isHidden = false
        timer.invalidate()
    }
    
    @IBAction func sendCodeAgain(_ sender: UIButton) {
        presenter.sendPhone()
        startTimer()
    }
    
    @IBAction func continueButtonClick(_ sender: UIButton) {
        registrationModel.code = codeTextField.text ?? ""
        presenter.sendCode()
    }
}

extension AuthCodeVC: AKMaskFieldDelegate {
    func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
        guard var text = maskField.text else { return }
        for (index, char) in text.enumerated() {
            codeLabels[index].text = String(char)
        }
        text = text.replacingOccurrences(of: " ", with: "")
        if text.count == 4 {
            continueButton.isEnabled = true
            continueButton.backgroundColor = .black
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = baseImageTintColor
        }
    }
}

extension AuthCodeVC: AuthCodeViewProtocol {
    func showLoading() {
        hideKeyboard()
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
    
    func goToRegistration(authResponse: AuthResponseModel) {
        let regVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
        regVC.countryFromAuth = countryFromAuth
        regVC.token = authResponse.token
        navigationController?.pushViewController(regVC, animated: true)
    }
    
    func goToMenu() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
        UIApplication.shared.delegate?.window??.rootViewController = vc
    }
}
