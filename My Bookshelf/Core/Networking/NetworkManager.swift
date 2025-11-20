//
//  NetworkManager.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import Foundation
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

    func fetch<T: Decodable>(
        url: String,
        completion: @escaping (Result<T, AFError>) -> Void
    ) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        AF.request(url)
            .validate()
            .responseDecodable(of: T.self, decoder: decoder) { response in
                completion(response.result)
            }
    }
}
