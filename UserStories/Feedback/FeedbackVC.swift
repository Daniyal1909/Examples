//
//  FeedbackVC.swift
//  MyTester
//
//  Created by Деветов Даниял on 15/11/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

protocol FeedbackViewProtocol: BaseViewProtocol {
    func showLoading()
    func hideLoading()
    func endSendingMessage()
}

class FeedbackVC: UIViewController {
    @IBOutlet weak var chooiseSubjectButton: UIButton!
    @IBOutlet weak var chooiseDeviceButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var setImageButton: UIButton!
    @IBOutlet weak var imageInfoView: UIView!
    @IBOutlet weak var imageNameTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadingView: UIView!
    
    var presenter: FeedbackPresenterProtocol!
    var feedbackModel = FeedbackModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = FeedbackPresenter(view: self)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func openSubjectsButtonClick(_ sender: UIButton) {
        let baseTVC = UIStoryboard(name: "BaseTVCSB", bundle: nil).instantiateViewController(withIdentifier: "baseTVC") as! BaseTVC
        baseTVC.type = .messageSubject
        baseTVC.delegate = self
        baseTVC.selectedItemID = feedbackModel.subjectID
        self.navigationController?.pushViewController(baseTVC, animated: true)
    }
    
    @IBAction func openDevicesButtonClick(_ sender: UIButton) {
        let deviceList = UIStoryboard(name: "DeviceListSB", bundle: nil).instantiateViewController(withIdentifier: "DeviceListVC") as! DeviceListVC
        deviceList.delegate = self
        self.navigationController?.pushViewController(deviceList, animated: true)
    }
    
    @IBAction func setImageButtonClicK(_ sender: UIButton) {
        showImagePickerChooise()
    }
    
    func showImagePickerChooise() {
        let alert = UIAlertController(title: "Выберите способ закрузки фото", message: nil, preferredStyle: .actionSheet)
        let galeryAction = UIAlertAction(title: "Галерея", style: .default) { (_) in
            self.openGalery()
        }
        let cameraAction = UIAlertAction(title: "Камера", style: .default) { (_) in
            self.openCamera()
        }
        alert.addAction(galeryAction)
        alert.addAction(cameraAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openGalery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func deleteImageButtonClick(_ sender: UIButton) {
        feedbackModel.image = nil
        setImageButton.isHidden = false
        imageInfoView.isHidden = true
    }
}

extension FeedbackVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderColor = .black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").count == 0 {
            textField.borderColor = baseImageTintColor
        }
    }
}

extension FeedbackVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Сообщение" {
            textView.text = ""
            textView.textColor = .black
            textView.borderColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text ?? "").count == 0 {
            textView.text = "Сообщение"
            textView.textColor = baseImageTintColor
            textView.borderColor = baseImageTintColor
        }
    }
}

extension FeedbackVC: FeedbackViewProtocol {
    func showLoading() {
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
    
    func endSendingMessage() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FeedbackVC: BaseTVCDelegate {
    func didSelect(type: BaseTVCType, item: BaseCellModel) {
        feedbackModel.subjectID = item.id
        chooiseSubjectButton.setTitle(item.title, for: .normal)
        chooiseSubjectButton.setTitleColor(.black, for: .normal)
        chooiseSubjectButton.borderColor = .black
    }
}

extension FeedbackVC: DeviceListDelegate {
    func setSelected(item: DeviceModel) {
        feedbackModel.deviceID = item.id
        chooiseDeviceButton.setTitle(item.model, for: .normal)
        chooiseDeviceButton.setTitleColor(.black, for: .normal)
        chooiseDeviceButton.borderColor = .black
    }
}

extension FeedbackVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if #available(iOS 11.0, *) {
            if let fileUrl = info[UIImagePickerController.InfoKey.imageURL.rawValue] as? URL {
                imageNameTextField.text = fileUrl.lastPathComponent
            } else {
                imageNameTextField.text = "Фото выбрано"
            }
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            self.feedbackModel.image = image
            self.setImageButton.isHidden = true
            self.imageInfoView.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
