//
//  AddNoteCoordinator.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 12/02/2021.
//

import UIKit

class AddNoteCoordinator: Coordinator {
    let presenter: UINavigationController
    let addNoteDataManager: DataManagerCoreData
    var addNoteNavigationController: UINavigationController?
    var notebook: NotebookMO?
    var onCancelTapped: (() -> Void)?
    var onNoteCreated: (() -> Void)?
    
    init(presenter: UINavigationController, notebook: NotebookMO ,addNoteDataManager: DataManagerCoreData) {
        self.presenter = presenter
        self.addNoteDataManager = addNoteDataManager
        self.notebook = notebook
    }
    
    override func start() {
        guard let notebook = notebook else {return}
        let addNoteViewModel = AddNoteViewModel(dataManager: addNoteDataManager, notebook: notebook)
        addNoteViewModel.coordinatorDelegate = self

        let addNoteViewController = AddNoteViewController(viewModel: addNoteViewModel)
        addNoteViewModel.viewDelegate = addNoteViewController
        addNoteViewController.isModalInPresentation = true
        addNoteViewController.title = "Add note"

        let navigationController = UINavigationController(rootViewController: addNoteViewController)
        self.addNoteNavigationController = navigationController
        presenter.present(navigationController, animated: true, completion: nil)
    }
    
    override func finish() {
        addNoteNavigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AddNoteCoordinator: AddNoteCoordinatorDelegate {
    
    func addNoteCancelButtonTapped() {
        onCancelTapped?()
    }

    func noteSuccessfullyAdded() {
        onNoteCreated?()
    }
}
