//
//  SessionStore.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 10.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import Alamofire
import Combine
import SwiftUI

class SessionStore: ObservableObject {
    @CodableUserDefaults(key: "loginModel", default: nil)
    var loginModel: LoginModel? {
        willSet {
            objectWillChange.send()
        }
    }

    @CodableUserDefaults(key: "loginParameters", default: nil)
    var loginParameters: LoginParameters? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var photosData: [Data] = [Data]()
    @Published var videoURL: String?
    @Published var alertItem: AlertItem?
    @Published var uploadProgress: Double = 0.0
    @Published var showServerAlert: Bool = false
    @Published var loginState: Bool = false
    @Published var logoutState: Bool = false
    @Published var uploadState: Bool = false
    @Published var changelogLoadingFailure: Bool = false
    @Published var licenseLoadingFailure: Bool = false
    @Published var inspectionsLoadingState: LoadingState = .loading
    @Published var vyplatnyedelaLoadingState: LoadingState = .loading
    @Published var inspections: [Inspections] = [Inspections]()
    @Published var vyplatnyedela: [Vyplatnyedela] = [Vyplatnyedela]()
    @Published var сhangelogModel: [ChangelogModel] = [ChangelogModel]()
    @Published var licenseModel: [LicenseModel] = [LicenseModel]()

    static let shared = SessionStore()

    let serverURL: String = "https://rosenergo.calcn1.ru/api/"

    func stringDate() -> String {
        let currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createStringDate = dateFormatter.string(from: currentDate)
        return createStringDate
    }

    private func clearData() {
        loginModel = nil
        logoutState = false
        loginParameters = nil
        inspections.removeAll()
        inspectionsLoadingState = .loading
        vyplatnyedela.removeAll()
        vyplatnyedelaLoadingState = .loading
    }

    func login(email: String, password: String) {
        loginState = true

        let parameters = LoginParameters(
            email: email,
            password: password
        )

        AF.request(serverURL + "login", method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: LoginModel.self) { [self] response in
                switch response.result {
                case .success:
                    guard let loginModelResponse = response.value else { return }
                    loginModel = loginModelResponse
                    loginParameters = parameters
                    loginState = false
                case let .failure(error):
                    alertItem = AlertItem(title: "Ошибка", message: "Логин или пароль неверны, либо отсутствует соединение с интернетом.", action: false)
                    loginState = false
                    print(error)
                }
            }
    }

    func logout() {
        logoutState = true

        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "logout", method: .post, headers: headers)
            .validate()
            .response { [self] _ in
                clearData()
            }
    }

    func validateToken() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "token", method: .post, headers: headers)
            .validate()
            .response { [self] response in
                switch response.result {
                case .success:
                    break
                case .failure:
                    if let code = response.response?.statusCode {
                        if code != 200, loginParameters != nil {
                            login(email: loginParameters!.email, password: loginParameters!.password)
                        } else if code != 200, loginParameters == nil {
                            loginModel = nil
                        } else {
                            break
                        }
                    } else {
                        showServerAlert = true
                    }
                }
            }
    }

    func uploadInspections(parameters: InspectionParameters) {
        uploadState = true

        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "testinspection", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertItem = AlertItem(title: "Успешно", message: "Осмотр успешно загружен на сервер.", action: true)
                    uploadState = false
                case let .failure(error):
                    alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить осмотр позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    debugPrint(error)
                }
            }
    }

    func uploadVyplatnyeDela(parameters: VyplatnyeDelaParameters) {
        uploadState = true

        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        AF.request(serverURL + "vyplatnyedela", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .response { [self] response in
                switch response.result {
                case .success:
                    alertItem = AlertItem(title: "Успешно", message: "Выплатное дело успешно загружено на сервер.", action: true)
                    uploadState = false
                case let .failure(error):
                    alertItem = AlertItem(title: "Ошибка", message: "Попробуйте загрузить выплатное дело позже.\n\(error.errorDescription ?? "")", action: false)
                    uploadState = false
                    print(error.errorDescription!)
                }
            }
    }

    var cancellation: AnyCancellable?

    func request<T: Codable>(_ url: String, method: HTTPMethod = .get, headers: HTTPHeaders? = nil) -> AnyPublisher<Result<T, AFError>, Never> {
        let publisher = AF.request(url, method: method, headers: headers)
            .validate()
            .uploadProgress { [self] progress in
                uploadProgress = progress.fractionCompleted
            }
            .publishDecodable(type: T.self)
        return publisher.result()
    }

    func getVyplatnyedela() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        cancellation = request(serverURL + "vyplatnyedelas", headers: headers)
            .sink { [self] (response: Result<[Vyplatnyedela], AFError>) in
                switch response {
                case .success(let value):
                    vyplatnyedela = value
                    vyplatnyedelaLoadingState = .success
                case .failure(let error):
                    vyplatnyedelaLoadingState = .failure
                    print(error)
                }
            }
    }

    func getInspections() {
        let headers: HTTPHeaders = [
            .authorization(bearerToken: loginModel?.data.apiToken ?? ""),
            .accept("application/json"),
        ]

        cancellation = request(serverURL + "inspections", headers: headers)
            .sink { [self] (response: Result<[Inspections], AFError>) in
                switch response {
                case .success(let value):
                    inspections = value
                    inspectionsLoadingState = .success
                case .failure(let error):
                    inspectionsLoadingState = .failure
                    print(error)
                }
            }
    }

    func loadLicense() {
        cancellation = request("https://api.lisindmitriy.me/license")
            .sink { [self] (response: Result<[LicenseModel], AFError>) in
                switch response {
                case .success(let value):
                    licenseModel = value
                case .failure(let error):
                    licenseLoadingFailure = true
                    print(error)
                }
            }
    }

    func loadChangelog() {
        cancellation = request("https://api.lisindmitriy.me/changelog")
            .sink { [self] (response: Result<[ChangelogModel], AFError>) in
                switch response {
                case .success(let value):
                    сhangelogModel = value
                case .failure(let error):
                    changelogLoadingFailure = true
                    print(error)
                }
            }
    }
}

enum LoadingState {
    case loading, failure, success
}
