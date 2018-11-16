//
//  RegistrationPresenter.swift
//  MyTester
//
//  Created by Деветов Даниял on 09/11/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import CoreLocation

protocol RegistrationPresenterProtocol {
    func requestLocation()
    func register(regModel: RegistrationModel, token: String)
}

class RegistrationPresenter: NSObject, RegistrationPresenterProtocol {
    weak var view: RegistrationViewProtocol!
    private lazy var registrationService: RegistrationServiceProtocol = RegistrationService()
    private var locationManager = CLLocationManager()
    private var latitude: Double?
    private var longitude: Double?
    
    init(view: RegistrationViewProtocol) {
        self.view = view
    }
    
    func requestLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .denied, .restricted:
            self.view.setCountryFromAuth()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            view.showLoading()
        }
    }
    
    func register(regModel: RegistrationModel, token: String) {
        var params: [String: AnyObject] = [:]
        if regModel.userName != nil {
            params["username"] = regModel.userName! as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "registration.user_name_error"))
            return
        }
        if regModel.country != nil {
            params["country"] = regModel.country! as AnyObject
        } else {
            view.showAlertWithOkAction(with: Localizer.shared.stringForKey(key: "registration.country_error"))
            return
        }
        if regModel.firstName != nil {
            params["first_name"] = regModel.firstName! as AnyObject
        }
        if regModel.lastName != nil {
            params["last_name"] = regModel.lastName! as AnyObject
        }
        if regModel.email != nil {
            params["email"] = regModel.email! as AnyObject
        }
        if regModel.city != nil {
            params["city"] = regModel.city! as AnyObject
        }
        if latitude != nil {
            params["latitude"] = latitude! as AnyObject
        }
        if longitude != nil {
            params["longitude"] = longitude! as AnyObject
        }
        
        view.showLoading()
        registrationService.register(parameters: params, token: token, ifSuccess: { [weak self] (result) in
            guard let `self` = self else { return }
            if result.success {
                self.view.endRegistration()
                UserDefaults.standard.set(result.token, forKey: "token")
                UserDefaults.standard.set("auth", forKey: "session")
            }
        }, ifFailure: { [weak self] (error) in
            guard let `self` = self else { return }
            self.view.hideLoading()
            self.view.showAlertWithOkAction(with: error.errors?.isEmpty ?? true ? error.message ?? "" : error.errors?.first?.message ?? "")
        })
    }
}

extension RegistrationPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            self.view.hideLoading()
        }
        guard let currentLocation = locations.last else { return }
        locationManager.stopUpdatingLocation()
        latitude = currentLocation.coordinate.latitude
        longitude = currentLocation.coordinate.longitude
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            guard error == nil, let placemark = placemarks?.first else { self.view.setCountryFromAuth(); return }
            if placemark.country != nil {
                self.view.setGoeData(country: placemark.country!, city: placemark.locality)
            } else {
                self.view.setCountryFromAuth()
            }
        }
    }
}
