import UIKit

struct ArticlesResponseModel: Codable {
	let status: String?
	let totalResults: Int?
	let articles: [ArticlesModel]?

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case totalResults = "totalResults"
		case articles = "articles"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decodeIfPresent(String.self, forKey: .status)
		totalResults = try values.decodeIfPresent(Int.self, forKey: .totalResults)
		articles = try values.decodeIfPresent([ArticlesModel].self, forKey: .articles)
	}
}
