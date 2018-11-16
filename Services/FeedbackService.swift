//
//  FeedbackService.swift
//  MyTester
//
//  Created by Деветов Даниял on 13/11/2018.
//  Copyright © 2018 DIIT Center. All rights reserved.
//

import Foundation
import Alamofire

protocol FeedbackServiceProtocol {
    func getMessageSubjects(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void)
    func sendMessage(params: [String : AnyObject], image: UIImage?, ifSuccess: @escaping () -> Void, ifFailure: @escaping (ErrorModel) -> Void)
}

final class FeedbackService: FeedbackServiceProtocol {
    lazy var networkLayer: NetworkLayerProtocol = NetworkLayer()
    
    func getMessageSubjects(ifSuccess: @escaping ([BaseCellModel]) -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.messageSubjects
        networkLayer.request(api: api, ifSuccess: { (result: [SubjectModel]) in
            let presentationArray = Mapper.mapSubjectToCellModel(array: result)
            presentationArray.first?.bottomSpace = 20
            presentationArray.first?.topSpace = 20
            ifSuccess(presentationArray)
        }, ifFailure: ifFailure)
    }
    
    func sendMessage(params: [String : AnyObject], image: UIImage?, ifSuccess: @escaping () -> Void, ifFailure: @escaping (ErrorModel) -> Void) {
        let api = Api.feedback
        var mutableImage = image
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if mutableImage != nil {
                if mutableImage!.size.width > 1000 || image!.size.height > 1000 {
                    mutableImage = mutableImage?.resizeImage(targetSize: CGSize(width: 1000, height: 1000))
                }
                if let imageData = mutableImage?.jpegData(compressionQuality: 1) {
                    print(imageData)
                    multipartFormData.append(imageData, withName: "img", fileName: "file.png", mimeType: "image/png")
                }
            }
            
            for (key, value) in params as [String : Any] {
                multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
            }}, to: api.path, method: api.method, headers: api.headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if (response.result.value as? Bool) == true {
                                ifSuccess()
                            } else {
                                do {
                                    var readableJson = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? [String: AnyObject]
                                    if (readableJson?["message"] as? String) != nil {
                                        if let data = response.data {
                                            do {
                                                let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                                                ifFailure(error)
                                            } catch {
                                                ifFailure(ErrorModel.Connection())
                                            }
                                        } else {
                                            ifFailure(ErrorModel.Connection())
                                        }
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                    ifFailure(ErrorModel.Connection())
                                }
                            }
                        }
                    case .failure:
                        ifFailure(ErrorModel.Connection())
                    }
        })
    }
}
