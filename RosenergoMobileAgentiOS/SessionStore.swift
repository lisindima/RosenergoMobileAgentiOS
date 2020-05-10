//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import Alamofire

class SessionStore: ObservableObject {
    
    static let shared = SessionStore()
    
    func login(email: String, password: String) {
        let parameters = LoginParameters(email: email, password: password)
        AF.request("https://rosenergo.calcn1.ru/api/login",method: .post, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        
    }
    
    func logout(apiToken: String) {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiToken)",
            "Accept": "application/json"
        ]
        
        AF.request("https://rosenergo.calcn1.ru/api/logout",method: .post, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print(data)
                case .failure(let error):
                    print(error.errorDescription!)
                }
            }
        
    }
}

struct LoginParameters: Encodable {
    let email: String
    let password: String
}
