//
//  APIService.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 29.11.2022.
//

import UIKit




extension URLSession {
    enum CustomError: Error {
        case invalidURL, invalidData
    }

    func request<T: Codable>(url: URL?,
                             expecting: T.Type,
                             completion: @escaping(Result<T, Error>) -> Void
    ) {
        guard let url = url else {
            completion(.failure(CustomError.invalidURL))
            return
        }

        let task = dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(CustomError.invalidData))
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
                print(error.localizedDescription)
            }
        }
    }
}
