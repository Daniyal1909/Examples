//
//  AuthPhoneVC.swift
//  MyTester
//
//  Created by Деветов Даниял on 12/10/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit
import AKMaskField

protocol AuthPhoneViewProtocol: BaseViewProtocol {
    func goToAuthorizationVC(with phone: String)
    func showLoading()
    func hideLoading()
}

class AuthPhoneVC: UIViewController {
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneField: AKMaskField!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    
    var countryPhoneCode = CountryPhoneCodeModel.init(title: "Россия", code: "+7", mask: "{ddd} {ddd} {dd} {dd}", maskTemplate: "             ")
    var presenter: AuthPhonePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        presenter = AuthPhonePresenter(view: self)
        setMask()
    }
    
    func setMask() {
        phoneField.maskDelegate = self
        phoneField.setMask(countryPhoneCode.mask, withMaskTemplate: countryPhoneCode.maskTemplate)
        countryCodeLabel.text = countryPhoneCode.code
        countryButton.setTitle(countryPhoneCode.title, for: .normal)
        continueButton.isEnabled = false
        continueButton.backgroundColor = baseImageTintColor
    }
    
    @IBAction func openCountriesVC() {
        let searchVC = UIStoryboard(name: "SearchSB", bundle: nil).instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        searchVC.delegate = self
        searchVC.type = .countryPhoneCode
        searchVC.selectedItemID = countryPhoneCode.id
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func continueButtonClick() {
        hideKeyboard()
        presenter.send(phone: countryPhoneCode.code + (phoneField.text ?? ""))
    }
}

extension AuthPhoneVC: AKMaskFieldDelegate {
    func maskField(_ maskField: AKMaskField, didChangedWithEvent event: AKMaskFieldEvent) {
        let text = maskField.text?.replacingOccurrences(of: " ", with: "")
        if text?.count ?? 0 == countryPhoneCode.phoneNumberCount {
            continueButton.isEnabled = true
            continueButton.backgroundColor = .black
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = baseImageTintColor
        }
    }
}

extension AuthPhoneVC: SearchViewDelegate {
    func didSelect(item: BaseCellModel, type: SearchType) {
        self.countryPhoneCode = item as! CountryPhoneCodeModel
        setMask()
    }
}

extension AuthPhoneVC: AuthPhoneViewProtocol {
    func goToAuthorizationVC(with phone: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AuthCodeVC") as! AuthCodeVC
        let regModel = AuthorizationModel()
        regModel.set(phone: phone)
        vc.registrationModel = regModel
        vc.countryFromAuth = countryPhoneCode.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLoading() {
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
}
