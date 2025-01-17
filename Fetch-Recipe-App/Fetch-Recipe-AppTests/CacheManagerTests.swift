//
//  CacheManagerTests.swift
//  Fetch-Recipe-AppTests
//
//  Created by Yan's Mac on 1/16/25.
//

import XCTest
import UIKit
@testable import Fetch_Recipe_App

final class CacheManagerTests: XCTestCase {
    
//    TODO: add these tests, not necessarily in this class
//    1. show lazy loading by outputing partial list at load vs after scroll
    
    var cacheDirectoryString = CacheManager.shared.cacheDirectory.absoluteString
    var testRecipe = Recipe(cuisine: "Malaysian",
                            name: "Apam Balik",
                            photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                            photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                            uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                            sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                            youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
        )
    var expectedImage: UIImage? = nil
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        let fileUrlString = bundle.path(forResource: "apam-balik-small", ofType: "jpg")!
        expectedImage = UIImage(contentsOfFile: fileUrlString)
    }

    override func setUpWithError() throws {
        try clearCacheDirectory()
    }

    override func tearDownWithError() throws {
        try clearCacheDirectory()
    }
    
    func testSaveImageToDisk() throws {
        guard let expectedImage = expectedImage else {
            XCTFail("Expected image not set.")
            return
        }
        guard let loadedImage = CacheManager.shared.loadImageFromDisk(forKey: testRecipe.uuid) else {
            XCTFail("Failed to load the saved image from disk.")
            return
        }
        if try CacheManager.shared.saveImageToDisk(expectedImage, forKey: testRecipe.uuid) {
            XCTAssertEqual(loadedImage.pngData(), expectedImage.pngData(), "Loaded image is different from saved image.")
        } else {
            XCTFail("Failed to save image to disk.")
        }
    }
    
    func clearCacheDirectory() throws {
        if FileManager.default.fileExists(atPath: cacheDirectoryString) {
            let contents = try FileManager.default.contentsOfDirectory(atPath: cacheDirectoryString)
            for fileUrl in contents {
                do {
                    try FileManager.default.removeItem(atPath: fileUrl)
                } catch {
                    XCTFail("Failed to clear cache directory.")
                }
            }
        }
    }
}
