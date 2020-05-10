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
    
    @Published var loginModel: LoginModel!
    
    static let shared = SessionStore()
    let serverURL: String = "https://rosenergo.calcn1.ru/api/"
    
    func login(email: String, password: String) {
        let parameters = LoginParameters(email: email, password: password)
        AF.request(serverURL + "login", method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: LoginModel.self) { response in
                switch response.result {
                case .success( _):
                    guard let loginModel = response.value else { return }
                    self.loginModel = loginModel
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
        
        AF.request(serverURL + "logout", method: .post, headers: headers)
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

struct LoginModel: Codable, Hashable {
    let data: DataClass
}

struct DataClass: Codable, Hashable {
    let id, roleID: Int
    let name, email, avatar: String
    let settings: Settings
    let createdAt, updatedAt, apiToken: String
    let agentID: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case name, email, avatar, settings
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case apiToken = "api_token"
        case agentID = "agent_id"
    }
}

struct Settings: Codable, Hashable {
    let locale: String
}
