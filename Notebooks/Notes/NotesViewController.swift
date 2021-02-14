//
//  NotesViewController.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//

import UIKit

class NotesViewController: UIViewController {
    
    //SearchBar
    let searchController = UISearchController(searchResultsController: nil)
    
    //TableView
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(NoteCell.self, forCellReuseIdentifier: NoteCell.identifier)
        table.estimatedRowHeight = 100
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .white
        return table
    }()
    
    //ViewModel
    let viewModel: NotesViewModel
    
    init(viewModel: NotesViewModel) {
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
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        UISearchBar.appearance().tintColor = .mainColor
        self.navigationController?.navigationBar.tintColor = .mainColor
        
    }
    
    @objc func plusButtonTapped() {
        viewModel.plusButtonTapped()
    }
    
    
    
    fileprivate func showErrorFetchingNotesAlert() {
        let alertMessage: String = NSLocalizedString("Error fetching notes\nPlease try again later", comment: "")
        showAlert(alertMessage)
    }
    
}

extension NotesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell,
            let cellViewModel = viewModel.viewModel(at: indexPath) {
            cell.viewModel = cellViewModel
            return cell
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { [weak self] (_, _, complete) in
            
            self?.viewModel.deleteNoteButtonTapped(at: indexPath)
            
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeAction
       
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   
    
    
    
}

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRow(at: indexPath)
    }
    
}

extension NotesViewController: NotesViewDelegate {
    func noteDataChange() {
        tableView.reloadData()
    }
    
    func notesFetched() {
        tableView.reloadData()
    }
    
    func errorFetchingNotes() {
        showErrorFetchingNotesAlert()
    }
    
}

//MARK:- SearchBar Delegate
extension NotesViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    viewModel.searchBarChange(text: searchBar.text ?? "")
    tableView.reloadData()
  }
}
