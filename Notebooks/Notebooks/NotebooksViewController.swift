//
//  NotebooksViewController.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 07/02/2021.
//

import UIKit

class NotebooksViewController: UIViewController {
    
    
    //SearchBar
    let searchController = UISearchController(searchResultsController: nil)
    
    //TableView
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(NotebookCell.self, forCellReuseIdentifier: NotebookCell.identifier)
        table.estimatedRowHeight = 100
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .white
        return table
    }()
    
    //ViewModel
    let viewModel: NotebooksViewModel
    
    
    init(viewModel: NotebooksViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        
        configureTheView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewWasLoaded()
    }
    
    func configureTheView() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let plusImage = UIImage(systemName: "plus.circle.fill")
        let rightBarButtonItem = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(plusButtonTapped))
        rightBarButtonItem.tintColor = .mainColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationController?.navigationBar.backgroundColor = .white
        
        let deleteImage = UIImage(systemName: "trash.fill")
        let leftBarButtonItemDelete = UIBarButtonItem(image: deleteImage, style: .plain, target: self, action: #selector(deleteAllButtonTapped))
        leftBarButtonItemDelete.tintColor = .mainColor
        
        let addDummyImage = UIImage(systemName: "text.badge.plus")
        let leftBarButtonItemDummy = UIBarButtonItem(image: addDummyImage, style: .plain, target: self, action: #selector(addDummyButtonTapped))
        leftBarButtonItemDummy.tintColor = .mainColor
        
        
        navigationItem.leftBarButtonItems = [leftBarButtonItemDelete, leftBarButtonItemDummy]
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notebooks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        UISearchBar.appearance().tintColor = .mainColor
        self.navigationController?.navigationBar.tintColor = .mainColor
        
        let systemFont = UIFont.systemFont(ofSize: 18)
        let font = UIFont(name: "Noteworthy-Bold", size: 20.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? systemFont,
            .foregroundColor: UIColor.mainColor,
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
    }

    
    
        
    @objc func plusButtonTapped() {
        viewModel.plusButtonTapped()
    }
    
    @objc func addDummyButtonTapped() {
        
        let alert = UIAlertController(title: "Add dummy content?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] (action: UIAlertAction) in
            self?.viewModel.addDummyButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil ))
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func deleteAllButtonTapped() {
        
        let alert = UIAlertController(title: "Delete all Notebooks?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] (action: UIAlertAction) in
            self?.viewModel.deleteAllButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil ))
        present(alert, animated: true, completion: nil)
        
    }
    
    fileprivate func showErrorFetchingNotebooksAlert() {
        let alertMessage: String = NSLocalizedString("Error fetching notebooks\nPlease try again later", comment: "")
        showAlert(alertMessage)
    }
    
}

//MARK:- Table DataSource
extension NotebooksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NotebookCell.identifier, for: indexPath) as? NotebookCell,
            let cellViewModel = viewModel.viewModel(at: indexPath) {
            cell.viewModel = cellViewModel
            return cell
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { [weak self] (_, _, complete) in
            self?.viewModel.deleteNotebookButtonTapped(at: indexPath)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeAction
       
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
}

//MARK:- Table Delegate
extension NotebooksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath)
    }
    
}

//MARK:- Notebook Delegate
extension NotebooksViewController: NotebooksViewDelegate {
    func notebookDataChange() {
        tableView.reloadData()
    }
        
    func errorFetchingNotebooks() {
        showErrorFetchingNotebooksAlert()
    }
}

//MARK:- SearchBar Delegate
extension NotebooksViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    viewModel.searchBarChange(text: searchBar.text ?? "")
    tableView.reloadData()
  }
}
