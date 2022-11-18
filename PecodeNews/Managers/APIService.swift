//
//  APIService.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit
import Alamofire

class APIService {
    static var shared = APIService()
    private init() {}

    enum Country: String {
        case ua, de, pl, fr, us, be
    }

    // MARK: - Network request for reloading Articles by picked country
    func requestCountryArticles(with country: Country, completion: @escaping(([ArticlesModel]) -> Void)) {
        let url = "https://newsapi.org/v2/top-headlines?country=\(country.rawValue)&apiKey=\(Constants.secondApiKey)"
        AF.request(url).responseJSON { response in

            switch response.result {
            case .success( _):
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

    // MARK: - Network request for searching Articles
    func requestSearchingArticles(with query: String, completion: @escaping([ArticlesModel]?) -> Void) {

        guard
            let formatedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        else {
            return
        }

        let url = "https://newsapi.org/v2/everything?q=\(formatedQuery)&apiKey=\(Constants.secondApiKey)"

        AF.request(url).responseJSON { response in

            switch response.result {
            case .success( _):
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
