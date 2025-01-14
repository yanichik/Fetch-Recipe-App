//
//  RecipeCell.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 12/31/24.
//

import UIKit

class RecipeCell: UITableViewCell {
    
    var nameLabel = UILabel()
    var cuisineLabel = UILabel()
    var recipeImageView = UIImageView()
    var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var cellData: Recipe? {
        didSet {
            guard let cellData = cellData else { return }
            nameLabel.text = cellData.name
            cuisineLabel.text = "(\(cellData.cuisine + " Cuisine"))"
            activityIndicator.startAnimating()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadRecipeImage(_ cellData: Recipe) async throws {
        // Table view cells are being re-used. Since image loading is async, during cell dequeue there is short time where wrong image appears. Nil out the image prior to load so only spinner is visible during loading.
        if let image = ImageCache.shared.loadImageFromDisk(forUrlString: cellData.photoUrlSmall) {
            recipeImageView.image = image
            activityIndicator.stopAnimating()
            return
        } else {
            recipeImageView.image = nil
            if let photoUrlString = cellData.photoUrlSmall {
                do {
                    guard let url = URL(string: photoUrlString) else { return }
                    try await ImageCache.shared.fetchImage(url: url) { [weak self] image in
                        Task {
                            self?.recipeImageView.image = image
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                } catch {
                    throw(error)
                }
            }
        }
    }
    
    private func configureCell() {
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(cuisineLabel)
        cuisineLabel.translatesAutoresizingMaskIntoConstraints = false
        cuisineLabel.numberOfLines = 0
        cuisineLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(recipeImageView)
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 10
        
        contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.contentMode = .scaleAspectFill
        activityIndicator.clipsToBounds = true
        activityIndicator.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            
            cuisineLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            cuisineLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            
            recipeImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            recipeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            recipeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            recipeImageView.widthAnchor.constraint(equalToConstant: 125),
            
            activityIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            activityIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            activityIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            activityIndicator.widthAnchor.constraint(equalToConstant: 125)
        ])
    }
}
