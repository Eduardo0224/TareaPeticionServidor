//
//  ServiceSender.swift
//  TareaPeticionServidor
//
//  Created by Eduardo Andrade on 7/9/19.
//  Copyright © 2019 EduardoAndrade. All rights reserved.
//

import Foundation

class ServiceSender {
    
    enum Endpoints  {
        static let base = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        
        case getBookBy(isbn: String)
        
        var stringValue: String {
            switch self {
            case .getBookBy(let isbn):
                return "\(Endpoints.base)\(isbn)"
            }
        }
        
        var url: URL? {
            if let url = URL(string: stringValue) {
                return url
            }
            return nil
        }
    }
    
    class func searchBy(isbn: String, completion: @escaping (BookData?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getBookBy(isbn: isbn).url!) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode([String:BookData].self, from: data)
                print(responseObject)
                if responseObject.isEmpty {
                    completion(nil, error)
                    return
                }
                let books = responseObject.values.map {$0}
                DispatchQueue.main.async {
                    completion(books.first, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
            
        }
        task.resume()
    }
}

