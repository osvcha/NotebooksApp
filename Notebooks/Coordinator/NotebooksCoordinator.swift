//
//  NotebooksCoordinator.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 07/02/2021.
//

import UIKit

class NotebooksCoordinator: Coordinator {
    let presenter: UINavigationController
    let notebooksDataManager: DataManagerCoreData
    let addNotebookDataManager: DataManagerCoreData
    let addNoteDataManager: DataManagerCoreData
    let notesDataManager: DataManagerCoreData
    let editNoteDataManager: DataManagerCoreData
    
    init(presenter: UINavigationController,
         notebooksDataManager: DataManagerCoreData,
         addNotebookDataManager: DataManagerCoreData,
         notesDataManager: DataManagerCoreData,
         addNoteDataManager: DataManagerCoreData,
         editNoteDataManager: DataManagerCoreData) {
        self.presenter = presenter
        self.notebooksDataManager = notebooksDataManager
        self.addNotebookDataManager = addNotebookDataManager
        self.notesDataManager = notesDataManager
        self.addNoteDataManager = addNoteDataManager
        self.editNoteDataManager = editNoteDataManager
    }
    

    override func start() {
        let notebooksViewModel = NotebooksViewModel(notebooksDataManager: notebooksDataManager)
        let notebooksViewController = NotebooksViewController(viewModel: notebooksViewModel)
        notebooksViewController.title = NSLocalizedString("Notebooks", comment: "")
        notebooksViewModel.viewDelegate = notebooksViewController
        notebooksViewModel.coordinatorDelegate = self
        presenter.pushViewController(notebooksViewController, animated: false)
    }
    
    override func finish() {}
}


//Notebooks Coordinator Delegate
extension NotebooksCoordinator: NotebooksCoordinatorDelegate {
    func didSelect(notebook: NotebookMO) {
        let notesViewModel = NotesViewModel(notebook: notebook, notesDataManager: notesDataManager)
        notesViewModel.coordinatorDelegate = self
        let notesViewController = NotesViewController(viewModel: notesViewModel)
        notesViewController.title = NSLocalizedString(notebook.title ?? "Notes", comment: "")
        notesViewModel.viewDelegate = notesViewController
        presenter.pushViewController(notesViewController, animated: true)
    }
    
    func notebooksPlusButtonTapped() {
        let addNotebookCoordinator = AddNotebookCoordinator(presenter: presenter, addNotebookDataManager: addNotebookDataManager)
        addChildCoordinator(addNotebookCoordinator)
        addNotebookCoordinator.start()

        addNotebookCoordinator.onCancelTapped = { [weak self] in
            guard let self = self else { return }

            addNotebookCoordinator.finish()
            self.removeChildCoordinator(addNotebookCoordinator)
        }

        addNotebookCoordinator.onNotebookCreated = { [weak self] in
            guard let self = self else { return }

            addNotebookCoordinator.finish()
            self.removeChildCoordinator(addNotebookCoordinator)
        }
    }
}

//Notes Coordinator Delegate
extension NotebooksCoordinator: NotesCoordinatorDelegate {
    
    func didSelect(note: NoteMO) {
        
        let editNoteViewModel = EditNoteViewModel(note: note, editNoteDataManager: notesDataManager)
        editNoteViewModel.coordinatorDelegate = self
        let editNoteViewController = EditNoteViewController(viewModel: editNoteViewModel)
        editNoteViewController.title = NSLocalizedString(note.title ?? "Note", comment: "")
        editNoteViewModel.viewDelegate = editNoteViewController
        presenter.pushViewController(editNoteViewController, animated: true)
        
        
    }
    
    func notesPlusButtonTapped(notebook: NotebookMO) {
        let addNoteCoordinator = AddNoteCoordinator(presenter: presenter, notebook: notebook, addNoteDataManager: addNoteDataManager)
        addChildCoordinator(addNoteCoordinator)
        addNoteCoordinator.start()

        addNoteCoordinator.onCancelTapped = { [weak self] in
            guard let self = self else { return }

            addNoteCoordinator.finish()
            self.removeChildCoordinator(addNoteCoordinator)
        }

        addNoteCoordinator.onNoteCreated = { [weak self] in
            guard let self = self else { return }

            addNoteCoordinator.finish()
            self.removeChildCoordinator(addNoteCoordinator)
        }
    }
}


//Edit Note Coordinator Delegate
extension NotebooksCoordinator: EditNoteCoordinatorDelegate {
    func noteSaveButtonTapped() {
        presenter.popViewController(animated: true)
    }
}
