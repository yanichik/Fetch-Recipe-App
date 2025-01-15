//
//  NetworkManager.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 12/28/24.
//

import Foundation
import UIKit

enum Endpoint: String, CaseIterable {
    case allRecipes = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    case malformed = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
    case empty = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
}

enum ResponseError: Error, CustomStringConvertible, LocalizedError {
    case invalidUrl
    case invalidReponse (statusCode: Int)
    case invalidData (error: any Error)
    
    var description: String {
        switch self {
        case .invalidUrl:
            return "Endpoint cannot be converted to URL."
        case .invalidReponse(let statusCode):
            return "Received invalid response status code: \(statusCode)"
        case .invalidData(let error):
            return "Received invalid data with error: \(error)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Unable to connect to the server."
        case .invalidReponse:
            return "The server returned an invalid response."
        case .invalidData:
            return "The data couldn’t be read because it is missing or corrupted."
        }
    }
}

struct NetworkManager {
    static let shared = NetworkManager()
    
    init() { }
    
    func fetchRecipes(endpoint: String) async throws -> Recipes{
        guard let url = URL(string: endpoint) else {
            throw ResponseError.invalidUrl
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        let httpResponse = response as! HTTPURLResponse
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ResponseError.invalidReponse(statusCode: httpResponse.statusCode)
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(Recipes.self, from: data)
            return result
        }
        catch {
            throw ResponseError.invalidData(error: error)
        }
    }
    
    func loadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw ResponseError.invalidUrl
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            throw ResponseError.invalidData(error: error)
        }
    }
}
