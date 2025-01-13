//
//  RecipesViewController.swift
//  Fetch-Recipe-App
//
//  Created by Yan's Mac on 12/28/24.
//

import UIKit

class RecipesViewController: UIViewController {
    var noRecipesAlert: UIAlertController?
    let recipesVM = ReceipesViewModel()
    let networkManager = NetworkManager()
    var endpointsSegment = UISegmentedControl()
    var hasPresentedLoadImageErrorAlert = false
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "recipe")
        return tableView
    }()
    
    override func loadView() {
        super.loadView()
        setupBindings()
        fetchRecipes(with: .allRecipes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        configureTableView()
        configureEndpointsSegment()
    }
    
    fileprivate func setupBindings() {
        recipesVM.onRecipesUpdated = { [weak self] in
            guard let self = self else { return }
            recipesVM.updateCellHeight(for: tableView.frame.height)
            tableView.reloadData()
            
        }
    }
    
    fileprivate func configureEndpointsSegment() {
        // First segment used as instruction to user to select endpoint, and disabled.
        endpointsSegment.insertSegment(withTitle: "Select Endpoint: ", at: 0, animated: false)
        endpointsSegment.setEnabled(false, forSegmentAt: 0)
        endpointsSegment.setWidth(130, forSegmentAt: 0)
        
        // Separate font attributes for "instruction" segment and endpoint segments.
        let disabledFontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.black,
        ]
        endpointsSegment.setTitleTextAttributes(disabledFontAttributes, for: .disabled)
        
        let enabledFontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]
        endpointsSegment.setTitleTextAttributes(enabledFontAttributes, for: .normal)
        
        // Insert endpoint options into segment.
        for (i, endpoint) in Endpoint.allCases.enumerated() {
            endpointsSegment.insertSegment(withTitle: String(describing: endpoint), at: i + 1, animated: false)
        }
        
        // Select allRecipes endpoint at default.
        endpointsSegment.selectedSegmentIndex = 1
        
        endpointsSegment.addTarget(self, action: #selector(selectSegment(_:)), for: .valueChanged)
        navigationItem.titleView = endpointsSegment
        
    }
    
    @objc func selectSegment(_ sender: UISegmentedControl) {
        // Upon selection send fetch request. Except for "instruction" segment at index 0 - selection routed to index 1.
        switch sender.selectedSegmentIndex {
        case 0:
            sender.selectedSegmentIndex = 1
        default:
            fetchRecipes(with: Endpoint.allCases[sender.selectedSegmentIndex - 1])
        }
    }
    
    fileprivate func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5),
            tableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: -5)
        ])
    }
    
    fileprivate func fetchRecipes(with endpoint: Endpoint) {
        hasPresentedLoadImageErrorAlert = false
        Task {
            do {
                let result = try await networkManager.fetchRecipes(endpoint: endpoint)
                recipesVM.recipes = result.recipes
            } catch {
                // TODO: cleanup error alert to display ResponseError message only.
                // TODO: refactor to separate method.
                presentErrorAlert(with: error)
            }
        }
    }
    
    fileprivate func shiftSegmentAndFetchRecipes() {
        endpointsSegment.selectedSegmentIndex = 1
        fetchRecipes(with: .allRecipes)
    }
    
    fileprivate func presentErrorAlert(with error: any Error) {
        noRecipesAlert = UIAlertController(title: "No Recipes Fetched", message: "\(error.localizedDescription)", preferredStyle: .alert)
        noRecipesAlert?.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
            if !(self?.hasPresentedLoadImageErrorAlert ?? false) {
                self?.shiftSegmentAndFetchRecipes()
            }
        }))
        noRecipesAlert?.addAction(UIAlertAction(title: "See Technical Details", style: .default, handler: { [weak self] _ in
            let developerAlert = UIAlertController(title: "Technical Error Message", message: "\(error)", preferredStyle: .alert)
            developerAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                if !(self?.hasPresentedLoadImageErrorAlert ?? false) {
                    self?.shiftSegmentAndFetchRecipes()
                }
            }))
            self?.present(developerAlert, animated: true)
        }))
        present(noRecipesAlert!, animated: true)
    }
}

extension RecipesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return recipesVM.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        Task {
            do {
                try await loadCellImage(for: cell, at: indexPath)
            } catch {
                if !hasPresentedLoadImageErrorAlert {
                    hasPresentedLoadImageErrorAlert = true
                    presentErrorAlert(with: error)
                }
            }
        }
    }
    
    func loadCellImage(for cell: UITableViewCell, at indexPath: IndexPath) async throws {
        guard let recipes = recipesVM.recipes else { return }
        if let recipeCell = cell as? RecipeCell {
            try await recipeCell.loadRecipeImage(recipes[indexPath.row])
        }
    }
}

extension RecipesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = recipesVM.recipes?.count,
                rows > 0 else { return 1 }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipes = recipesVM.recipes,
              recipes.count > 0 else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Fetched data returned 0 recipes."
            cell.textLabel?.textAlignment = .center
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath) as? RecipeCell {
            cell.cellData = recipes[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath)
            cell.textLabel?.text = recipes[indexPath.row].name
            return cell
        }
    }
}
