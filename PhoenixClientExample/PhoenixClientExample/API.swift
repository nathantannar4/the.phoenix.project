//
//  API.swift
//  PhoenixClientExample
//
//  Created by Nathan Tannar on 2018-08-20.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import Result
import Moya
import Promises

enum API {
    
    case ping
    
    case signUp(Auth)
    
    case login(Auth)
    
    case verifyLogin
    
    
}

extension API: TargetType {
    
    var baseURL: URL { return URL(string: "http://localhost:8000")! }
    
    var path: String {
        switch self {
        case .ping:
            return "/"
        case .signUp:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .verifyLogin:
            return "/auth/verify/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .ping, .verifyLogin:
            return .get
        case .signUp, .login:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    static var bearerToken: String?
    
    var headers: [String : String]? {
        return ["X-API-KEY": "myApiKey", "Content-Type": "application/json", "Accept": "application/json"]
    }
    
    var validationType: ValidationType {
        return .none
    }
    
    var task: Task {
        switch self {
        case .ping, .verifyLogin:
            return .requestPlain
        case .signUp(let auth):
            return .requestJSONEncodable(auth)
        case .login(let auth):
            return .requestJSONEncodable(auth)
        }
    }
    
}

extension API: AccessTokenAuthorizable {
    
    var authorizationType: AuthorizationType {
        switch self {
        case .login:
            return .basic
        case .verifyLogin:
            return .bearer
        default:
            return .none
        }
    }
    
}

final class AuthPlugin: PluginType {
    
    private var bearerToken: String? {
        get {
            return UserDefaults.standard.value(forKey: "Bearer") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Bearer")
        }
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        guard let route = target as? API else { return request }
        
        let authorizationType = route.authorizationType
        
        var request = request
        
        switch route.authorizationType {
        case .basic:
            switch route {
            case .login(let auth):
                let str = "\(auth.username):\(auth.password)"
                let encoded = str.data(using: .utf8)?.base64EncodedString()
                guard let basic = encoded else { return request }
                let authValue = authorizationType.rawValue + " " + basic
                request.setValue(authValue, forHTTPHeaderField: "Authorization")
            default:
                break
            }
        case .bearer:
            guard let token = bearerToken else { return request }
            let authValue = authorizationType.rawValue + " " + token
            request.setValue(authValue, forHTTPHeaderField: "Authorization")
        case .none:
            break
        }
        
        return request
        
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        guard let route = target as? API else { return }
        
        switch route {
        case .login:
            do {
                let response = try result.dematerialize()
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let token = try response.map(BearerToken.self, using: decoder)
                self.bearerToken = token.value
            } catch {
                // Login must have failed
            }
        default:
            break
        }
        
    }

}

final class Network {
    
    private static var provider: MoyaProvider<API> {
        return MoyaProvider<API>(plugins: [NetworkLoggerPlugin(verbose: true), AuthPlugin()])
    }
    
    static func request<T: Decodable>(_ route: API,
                                      decodeAs decodable: T.Type) -> Promise<T> {
        return Promise<T>(on: .global(qos: .background)) { fufill, reject in
            provider.request(route) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let model = try response.filterSuccessfulStatusCodes()
                            .map(decodable, using: decoder)
                        fufill(model)
                    } catch {
                        reject(error)
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    static func request(_ route: API) -> Promise<Data> {
        return Promise<Data>(on: .global(qos: .background)) { fufill, reject in
            provider.request(route) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.filterSuccessfulStatusCodes()
                        fufill(response.data)
                    } catch {
                        reject(error)
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
}
