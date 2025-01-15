//
//  CacheManager.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 1/13/25.
//

import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private init() {}
    
    private let cacheDirectory: URL = {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let directory = paths[0].appendingPathComponent("ImageCache")
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        return directory
    }()
    
    func saveImageToDisk(_ image: UIImage, forKey key: String) throws {
        guard let data = image.pngData() else { return }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Failed to write image to disk: \(error)")
            throw(error)
        }
    }
    
    func loadImageFromDisk(forCellData cellData: Recipe) -> UIImage? {
        guard let urlString = cellData.photoUrlSmall else { return nil }
        guard let url = URL(string: urlString) else { return nil }
        let key = hashedKey(forCellData: cellData)
        return loadImageFromDisk(forKey: key)
    }
    
    func loadImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    func fetchImage(forCellData cellData: Recipe, completion: @escaping (UIImage?) -> Void) async throws {
        let cacheKey = hashedKey(forCellData: cellData)
        
        if let cachedImage = loadImageFromDisk(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        do {
            guard let photoUrlString = cellData.photoUrlSmall else { return }
            guard let url = URL(string: photoUrlString) else { return }
            if let image = try await NetworkManager.shared.loadImage(from: url.absoluteString) {
                try saveImageToDisk(image, forKey: cacheKey)
                completion(image)
            }
        } catch {
            throw error
        }
    }
    
    private func hashedKey(forCellData cellData: Recipe) -> String {
        return cellData.uuid
//        return url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? url.lastPathComponent
    }
}
