//
//  ReceipesViewModel.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 12/31/24.
//

import Foundation

class ReceipesViewModel {
    var recipes: [Recipe]? {
        didSet {
            onRecipesUpdated?()
        }
    }
    var cellHeight: CGFloat = 0.0
    var pickerLabelWidth: CGFloat = 85
    
    var onRecipesUpdated: (() -> Void)?
    
    func updateCellHeight(for tableViewHeight: CGFloat) {
        cellHeight = tableViewHeight/10
    }
}
