//
//  AddNoteViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 12/02/2021.
//

import Foundation

protocol AddNoteCoordinatorDelegate: class {
    func addNoteCancelButtonTapped()
    func noteSuccessfullyAdded()
}

protocol AddNoteViewDelegate: class {
    func errorAddingNote()
}

class AddNoteViewModel {
    
    weak var viewDelegate: AddNoteViewDelegate?
    weak var coordinatorDelegate: AddNoteCoordinatorDelegate?
    let dataManager: DataManagerCoreData
    var notebook: NotebookMO?
    
    init(dataManager: DataManagerCoreData, notebook: NotebookMO) {
        self.dataManager = dataManager
        self.notebook = notebook
    }

    func cancelButtonTapped() {
        coordinatorDelegate?.addNoteCancelButtonTapped()
    }

    func submitButtonTapped(title: String, content: String) {
                
        let createdAt = Date()
        
        guard let notebook = notebook else { return }
        dataManager.saveNote(notebook: notebook, title: title, content: content, createdAt: createdAt)
        coordinatorDelegate?.noteSuccessfullyAdded()
        
    }
    
}
