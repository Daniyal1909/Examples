//
//  RegistrationVC.swift
//  MyTester
//
//  Created by Деветов Даниял on 18/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol RegistrationViewProtocol: BaseViewProtocol {
    func setCountryFromAuth()
    func setGoeData(country: String, city: String?)
    func showLoading()
    func hideLoading()
    func endRegistration()
}

class RegistrationVC: UIViewController {
    
    //Fields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    //Other Views
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingView: UIView!
    
    var countryFromAuth = ""
    var token = ""
    var presenter: RegistrationPresenterProtocol!
    var isCityEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RegistrationPresenter(view: self)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.requestLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Keyboard notifications
    @objc func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    //Button actions
    @IBAction func continueButtonClick(_ sender: UIButton) {
        let regModel = RegistrationModel()
        regModel.userName = userNameTextField.text
        regModel.firstName = firstNameTextField.text
        regModel.lastName = lastNameTextField.text
        regModel.email = emailTextField.text
        regModel.country = countryTextField.text
        regModel.city = cityTextField.text
        presenter.register(regModel: regModel, token: token)
    }
}

extension RegistrationVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderColor = .black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" || textField.text == nil {
            textField.borderColor = baseImageTintColor
        }
    }
}

extension RegistrationVC: RegistrationViewProtocol {
    func showLoading() {
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
    
    //if can't take location
    func setCountryFromAuth() {
        countryTextField.text = countryFromAuth
    }
    
    func setGoeData(country: String, city: String?) {
        countryTextField.text = country
    }
    
    func endRegistration() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BaseTabBarController") as! BaseTabBarController
        UIApplication.shared.delegate?.window??.rootViewController = vc
    }
}
