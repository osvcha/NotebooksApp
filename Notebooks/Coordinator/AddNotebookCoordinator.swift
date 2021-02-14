//
//  AddNotebookCoordinator.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 10/02/2021.
//

import UIKit

class AddNotebookCoordinator: Coordinator {
    let presenter: UINavigationController
    let addNotebookDataManager: DataManagerCoreData
    var addNotebookNavigationController: UINavigationController?
    var onCancelTapped: (() -> Void)?
    var onNotebookCreated: (() -> Void)?
    
    init(presenter: UINavigationController, addNotebookDataManager: DataManagerCoreData) {
        self.presenter = presenter
        self.addNotebookDataManager = addNotebookDataManager
    }
    
    override func start() {
        let addNotebookViewModel = AddNotebookViewModel(dataManager: addNotebookDataManager)
        addNotebookViewModel.coordinatorDelegate = self

        let addNotebookViewController = AddNotebookViewController(viewModel: addNotebookViewModel)
        addNotebookViewModel.viewDelegate = addNotebookViewController
        addNotebookViewController.isModalInPresentation = true
        addNotebookViewController.title = "Add notebook"

        let navigationController = UINavigationController(rootViewController: addNotebookViewController)
        self.addNotebookNavigationController = navigationController
        presenter.present(navigationController, animated: true, completion: nil)
    }
    
    override func finish() {
        addNotebookNavigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AddNotebookCoordinator: AddNotebookCoordinatorDelegate {
    
    func addNotebookCancelButtonTapped() {
        onCancelTapped?()
    }

    func notebookSuccessfullyAdded() {
        onNotebookCreated?()
    }
}
