//
//  AddNotebookViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 10/02/2021.
//

import Foundation

protocol AddNotebookCoordinatorDelegate: class {
    func addNotebookCancelButtonTapped()
    func notebookSuccessfullyAdded()
}

protocol AddNotebookViewDelegate: class {
    func errorAddingNotebook()
}

class AddNotebookViewModel {
    
    weak var viewDelegate: AddNotebookViewDelegate?
    weak var coordinatorDelegate: AddNotebookCoordinatorDelegate?
    let dataManager: DataManagerCoreData

    init(dataManager: DataManagerCoreData) {
        self.dataManager = dataManager
    }

    func cancelButtonTapped() {
        coordinatorDelegate?.addNotebookCancelButtonTapped()
    }

    func submitButtonTapped(title: String) {
                
        let createdAt = Date()
        
        dataManager.saveNotebook(title: title, createdAt: createdAt)
        coordinatorDelegate?.notebookSuccessfullyAdded()
        
    }
    
}
