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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
            XCTAssert(!result.recipes.isEmpty, "Fetching from allRecipes endpoint should not return an empty array.")
        } catch {
            XCTFail("Fetching from allRecipes endpoint should not throw an error.")
        }
    }
//    TODO: add these tests, not necessarily in this class
//    1. show lazy loading by outputing partial list at load vs after scroll
//    2.

    func disabledtestExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
