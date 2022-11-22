//
//  RestService.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 22.11.2022.
//

import Foundation
import Alamofire

enum Countries: String {
    case us, de, pl, fr, ua, be
}

enum Categories: String {
    case business, entertainment, general, health, science, sports, technology
}

class RestService {
    private enum Constants {
        static let mainURL = "https://newsapi.org/v2/top-headlines?"
        static let apiKey = "a948c415d8ca45329ec98ab6850cdc31"
        static let secondApiKey = "950819fa59cc45119d45f608793c70da"
    }

    static let shared: RestService = .init()

    private init() {}

    // MARK: CONTROL API RESPONSE
    private func getJsonResponse(
        _ path: String,
        params: [String: Any] = [:],
        method: HTTPMethod = .get,
        encoding: ParameterEncoding = URLEncoding.default,
        completion: @escaping(([ArticlesModel]) -> Void)
    ) {

        let url = "\(Constants.mainURL)\(path)&apiKey=\(Constants.apiKey)"
        if let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {

            AF.request(
                encoded,
                method: method,
                parameters: params,
                encoding: encoding,
                headers: nil
            ).responseJSON
            { response in
                switch response.result {
                case .success(_):
                    print("Successfull request")
                    print(url)

                    let decoder = JSONDecoder()
                    if let data = try? decoder.decode(ArticlesResponseModel.self, from: response.data ?? .empty) {
                        let articles = data.articles ?? []
                        completion(articles)
                    }

                case .failure(let error):
                    print("Error while getting TopArticles request: \(error.localizedDescription)")
                }
            }
        }
    }

    func getAllTopArticles(
        country: Countries? = nil,
        category: Categories? = nil,
        query: String? = nil,
        pageNumber: Int = 1,
        limit: Int = 5,
        completionHandler: @escaping(([ArticlesModel]) -> Void)
    ) {
        var path = "pageSize=\(limit)&page=\(pageNumber)"

        if let queryKey = query, !queryKey.isEmpty {
            path = "\(path)&q=\(queryKey)"
        }

        if let countryKey = country {
            path = "\(path)&country=\(countryKey.rawValue)"
        }

        if let categoryKey = category {
            path = "\(path)&category=\(categoryKey.rawValue)"
        }

        print(path)

        getJsonResponse(path) { articles in
            completionHandler(articles)
        }
    }
}