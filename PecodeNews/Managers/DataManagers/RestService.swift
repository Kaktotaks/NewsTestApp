//
//  RestService.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 22.11.2022.
//

import Foundation
import Alamofire

class RestService {
    private enum Constants {
        static let mainURL = "https://newsapi.org/v2/top-headlines?"
        static let apiKey = "a948c415d8ca45329ec98ab6850cdc31"
        static let secondApiKey = "950819fa59cc45119d45f608793c70da"
        static let thirdApiKey = "9c262814018e40bb8d6ed98ff3b866d4"
    }

    public var isPaginating = false

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
            ).responseJSON { response in
                switch response.result {
                case .success:
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
        pagination: Bool = false,
        country: String? = "us",
        category: String? = nil,
        query: String? = nil,
        page: Int = 1,
        limit: Int = 5,
        completionHandler: @escaping(([ArticlesModel]) -> Void)
    ) {
        var path = "pageSize=\(limit)&page=\(page)"

        if let queryKey = query, !queryKey.isEmpty {
            path = "\(path)&q=\(queryKey)"
        }

        if let countryKey = country {
            path = "\(path)&country=\(countryKey)"
        }

        if let categoryKey = category {
            path = "\(path)&category=\(categoryKey)"
        }

        print(path)

        if pagination {
            isPaginating = true
        }

            self.getJsonResponse(path) { articles in
                completionHandler(articles)
                if pagination {
                    self.isPaginating = false
                }
            }
    }
}
