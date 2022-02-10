//
//  UdacityClient.swift
//  OntheMap2
//
//  Created by Mac on 11/6/21.
//

import Foundation

class UdacityClient: NSObject {
    
    struct User {
        
        static var createdAt = ""
        static var updatedAt = ""
        static var firstName = ""
        static var lastName = ""
        static var location = ""
        static var link = ""
    }
    
    struct PreviousPostLocationObject {
        static var objectId = ""
    }
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
        
    }
    static let ApplicationId = " QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let APIkey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case createSessionId
        case getLocations
        case postLocation
        case getUser
        case updateLocation
        case logout
        case webAuth
        
        var stringValue: String {
            switch self {
            case .createSessionId:
                return Endpoints.base + "/session"
            case .webAuth:
                return "https://auth.udacity.com/sign-up"
            case .postLocation:
                return Endpoints.base + "/StudentLocation"
            case .getLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .updateLocation:
                return Endpoints.base + "/StudentLocation" + PreviousPostLocationObject.objectId
            case .getUser:
                return Endpoints.base + "/users/" + Auth.accountKey
            case .logout:
                return Endpoints.base + "/session"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    override init() {
        super.init()
    }
    
    class func shared() -> UdacityClient {
        struct Singleton {
            static var shared = UdacityClient()
        }
        return Singleton.shared
    }
    
   class func taskForGETRequest <ResponseType: Decodable>(url : URL, type: String, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> Void {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if type == "Udacity" {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue(UdacityClient.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityClient.APIkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil, error)
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                if type == "Udacity" {
                    let range = 5..<data.count
                    let newData = data.subdata(in: range)
                    let responseObject = try JSONDecoder().decode(responseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } else {
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                    completion(responseObject, nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable > (url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let range = (5..<data.count)
                    let newData = data.subdata(in: range)
                    print(String(data: newData, encoding: .utf8)!)
                    
                    let responseObject = try JSONDecoder().decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
           
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        
        task.resume()
}
    
    class func getUser(completion: @escaping (String?, String?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getUser.url, type: "Udacity", responseType: GetUserDataResponse.self) {
            response, error in
            if let response = response {
                print("Data completed")
                completion(response.firstName, response.lastName, nil)
                User.firstName = response.firstName
                User.lastName = response.lastName
                print(response)
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocation], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getLocations.url, type: "Parse", responseType: StudentLocationResults.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
                    print(response)
            }else{
                completion([], error)
            }
        }
    }
    
    class func postLocation(firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        
        let body = PostLocation(uniqueKey: Auth.accountKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        taskForPOSTRequest(url: Endpoints.postLocation.url, responseType: PostLocationResponse.self, body: body) { response, error in
            if let response = response {
                User.createdAt = response.createdAt
                PreviousPostLocationObject.objectId = response.objectId
                print(response.createdAt)
                completion(true, nil)
            }else{
                completion(false, error)
            }
        }
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = ("{\"udacity\": {\"username\": \"" + username + "\", \"password\": \"" + password + "\"}}").data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            do {
                let range = (5..<data.count)
                let newData = data.subdata(in: range)
                print(String(data: newData, encoding: .utf8)!)
                let responseObject = try JSONDecoder().decode(LoginResponse.self, from: newData)
                DispatchQueue.main.async {
                    Auth.accountKey = responseObject.account.key ?? "no account key"
                    Auth.sessionId = responseObject.session.id ?? "no session id"
                    completion(responseObject.account.registered, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func logout(completion: @escaping(Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            do{
                let range = (5..<data.count)
                let newData = data.subdata(in: range)
                print(String(data: newData, encoding: .utf8)!)
                _ = try JSONDecoder().decode(Session.self, from: newData)
                DispatchQueue.main.async {
                    Auth.sessionId = ""
                    completion(true, nil)
                }
            }catch{
                completion(false, error)
                print("Logout failed")
            }
        }
        
        task.resume()
    }
    
    
    class func updateLocation(firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: Endpoints.updateLocation.url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Auth.accountKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\': \(longitude)}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(UpdateLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    User.updatedAt = responseObject.updatedAt
                    print("location updated")
                    completion(true, nil)
                }
            } catch {
                do {
                    let range = (5..<data.count)
                    let newData = data.subdata(in: range)
                    print(String(data: newData, encoding: .utf8)!)
                    let responseObject = try JSONDecoder().decode(UpdateLocationResponse.self, from: newData)
                    DispatchQueue.main.async {
                        User.updatedAt = responseObject.updatedAt
                        print("location updated")
                        completion(true, nil)
                    }
                }catch{
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
}
