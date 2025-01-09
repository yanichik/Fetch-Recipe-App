//
//  Recipes.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 12/28/24.
//

import Foundation

struct Recipes: Codable {
    let recipes: [Recipe]?
}

struct Recipe: Codable {
    let cuisine: String!
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let uuid: String!
    let sourceUrl: String?
    let youtubeUrl: String?
}


/*
 "cuisine": "British",
 "name": "Bakewell Tart",
 "photo_url_large": "https://some.url/large.jpg",
 "photo_url_small": "https://some.url/small.jpg",
 "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
 "source_url": "https://some.url/index.html",
 "youtube_url": "https://www.youtube.com/watch?v=some.id"
 */
