//
//  NetworkManagerTests.swift
//  Fetch-Recipe-AppTests
//
//  Created by Yan's Mac on 1/13/25.
//

import XCTest
import UIKit
@testable import Fetch_Recipe_App

extension Endpoint {
    static let invalidEndpoint = "https://Invalid.d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
}

final class NetworkManagerTests: XCTestCase {
    
    var expectedImage: UIImage? = nil
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        let fileUrlString = bundle.path(forResource: "apam-balik-small", ofType: "jpg")!
        expectedImage = UIImage(contentsOfFile: fileUrlString)
    }
    
    func testFetchRecipes_InvalidEndpoint_ThrowError() async {
        do {
            let _ = try await NetworkManager.shared.fetchRecipes(endpoint: Endpoint.invalidEndpoint)
            XCTFail("Fetching recipes with invalid endpoint should throw an error.")
        } catch {
            XCTAssertNotNil(error, "Fetching recipes with invalid endpoint should throw an error.")
        }
    }
    
    func testFetchRecipes_EmptyEndpoint_ReturnNoRecipes() async {
        do {
            let result = try await NetworkManager.shared.fetchRecipes(endpoint: Endpoint.empty.rawValue)
            XCTAssert(result.recipes.isEmpty, "Fetching from empty endpoint should return an empty array of Recipes")
        } catch {
            XCTFail("Fetching from empty endpoint should not throw an error.")
        }
    }
    
    func testFetchRecipes_AllRecipesEndpoint_ReturnRecipes() async {
        do {
            let result = try await NetworkManager.shared.fetchRecipes(endpoint: Endpoint.allRecipes.rawValue)
            XCTAssertTrue(!result.recipes.isEmpty, "Fetching from allRecipes endpoint should not return an empty array.")
        } catch {
            XCTFail("Fetching from allRecipes endpoint should not throw an error.")
        }
    }
    
    func testLoadImageFromUrlString_ReturnImage() async {
        let testUrlString = "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg"
        guard let expectedImage = expectedImage else {
            XCTFail("Expected image not set.")
            return
        }
        guard let loadedImage = try? await NetworkManager.shared.loadImage(from: testUrlString) else {
            XCTFail("Failed to load image.")
            return
        }
        XCTAssertEqual(loadedImage.pngData(), expectedImage.pngData(), "Loaded image is different from expected image.")
    }
}
