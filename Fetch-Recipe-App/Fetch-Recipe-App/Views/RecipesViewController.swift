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
    let picker = UIPickerView()
    
    
    
    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "recipe")
        return tableView
    }()
    
    override func loadView() {
        super.loadView()
        fetchRecipes(with: .allRecipes)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        configureTableView()
        configurePicker()
    }
    
    fileprivate func configurePicker() {
        picker.delegate = self
        picker.dataSource = self
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        picker.frame = CGRect(x: 0, y: 0, width: view.frame.width/2, height: 50)
        picker.transform = CGAffineTransform(rotationAngle: -.pi/2)
        
//        NSLayoutConstraint.activate([
//            picker.widthAnchor.constraint(equalToConstant: 50),
//            picker.heightAnchor.constraint(equalToConstant: view.frame.width / 2)
//        ])
        
//        navigationItem.titleView = picker
//        navigationItem.titleView?.backgroundColor = .green
        
        let segment = UISegmentedControl(items: Endpoint.allCases.map {String(describing: $0)})
        segment.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = segment
        navigationItem.titleView?.backgroundColor = .green
        
        NSLayoutConstraint.activate([
            navigationItem.titleView!.centerXAnchor.constraint(equalTo: navigationController!.navigationBar.centerXAnchor, constant: 40)
        ])
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
        Task {
            do {
                let result = try await networkManager.fetchRecipes(endpoint: endpoint)
                recipesVM.recipes = result.recipes
                recipesVM.updateCellHeight(for: tableView.frame.height)
//                print(tableView.frame.width)
                tableView.reloadData()
            } catch {
                // TODO: cleanup error alert to display ResponseError message only.
                // TODO: refactor to separate method
                noRecipesAlert = UIAlertController(title: "No Recipes Fetched", message: "\(error.localizedDescription)", preferredStyle: .alert)
                noRecipesAlert?.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] _ in
                    self?.picker.selectRow(0, inComponent: 0, animated: true)
                    self?.pickerView(self!.picker, didSelectRow: 0, inComponent: 0)
                }))
                print(error as! ResponseError)
//                print("\(error)")
//                print(error.localizedDescription)
                present(noRecipesAlert!, animated: true)
            }
        }
    }
}

extension RecipesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return recipesVM.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let recipes = recipesVM.recipes else { return }
        if let recipeCell = cell as? RecipeCell {
            recipeCell.loadRecipeImage(recipes[indexPath.row])
        }
    }
}

extension RecipesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = recipesVM.recipes?.count else { return 0 }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipes = recipesVM.recipes else { return UITableViewCell()}
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

extension RecipesViewController: UIPickerViewDelegate {
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let rows = Endpoint.allCases
//        return String(describing: rows[row])
//    }
    
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 200
//    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return recipesVM.pickerLabelWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rows = Endpoint.allCases
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 0, width: recipesVM.pickerLabelWidth, height: 50)
        titleLabel.text = String(describing: rows[row])
        titleLabel.transform = CGAffineTransform(rotationAngle: .pi/2)
        return titleLabel
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let endpoints = Endpoint.allCases
//        fetchRecipes(with: endpoints[row])
//    }
}

extension RecipesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let rows = Endpoint.allCases
        return rows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let endpoints = Endpoint.allCases
        fetchRecipes(with: endpoints[row])
    }
}

