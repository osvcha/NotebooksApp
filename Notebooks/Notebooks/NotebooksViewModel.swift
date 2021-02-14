//
//  NotebooksViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 09/02/2021.
//

import Foundation
import CoreData

protocol NotebooksCoordinatorDelegate: class {
    func didSelect(notebook: NotebookMO)
    func notebooksPlusButtonTapped()
}

protocol NotebooksViewDelegate: class {
    func errorFetchingNotebooks()
    func notebookDataChange()
}

class NotebooksViewModel: NSObject {
    
    weak var coordinatorDelegate: NotebooksCoordinatorDelegate?
    weak var viewDelegate: NotebooksViewDelegate?
    let notebooksDataManager: DataManagerCoreData?
    var notebookViewModels: [NotebookCellViewModel] = []
    var fetchResultsController:  NSFetchedResultsController<NSFetchRequestResult>?
    var predicateSearchBar: String = ""

    init(notebooksDataManager: DataManagerCoreData) {
        self.notebooksDataManager = notebooksDataManager
    }
    
    
    fileprivate func setupResultsController() {
        
        guard let notebooksDataManager = notebooksDataManager else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebookNameSortDescriptor = NSSortDescriptor(key: "createdAt",
                                                          ascending: false)
        request.sortDescriptors = [notebookNameSortDescriptor]
        
        if (predicateSearchBar != "") {
            request.predicate = NSPredicate(format: "title CONTAINS[c] %@", predicateSearchBar)
        }
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: notebooksDataManager.viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        self.fetchResultsController?.delegate = self
        
        do {
            try self.fetchResultsController?.performFetch()
        } catch {
            self.viewDelegate?.errorFetchingNotebooks()
            print("Error while trying to perform a notebook fetch.")
        }
        
    }
    
    func searchBarChange(text: String) {
        predicateSearchBar = text
        self.setupResultsController()
    }
    
    func viewWasLoaded() {
        self.setupResultsController()
    }

    func numberOfSections() -> Int {
        return fetchResultsController?.sections?.count ?? 0
    }

    func numberOfRows(in section: Int) -> Int {
        if let fetchResultsController = fetchResultsController {
            return fetchResultsController.sections![section].numberOfObjects
        } else {
            return 0
        }
        
    }

    func viewModel(at indexPath: IndexPath) -> NotebookCellViewModel? {
        guard let notebook = fetchResultsController?.object(at: indexPath) as? NotebookMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        let notebookCell = NotebookCellViewModel(notebook: notebook)
        return notebookCell
        
    }

    func didSelectRow(at indexPath: IndexPath) {
        guard let notebook = fetchResultsController?.object(at: indexPath) as? NotebookMO else {
            fatalError("Error selecting a notebook from table view")
        }
        coordinatorDelegate?.didSelect(notebook: notebook)
    }

    func plusButtonTapped() {
        coordinatorDelegate?.notebooksPlusButtonTapped()
    }
    
    func deleteAllButtonTapped() {
        guard let notebooksDataManager = notebooksDataManager else {
            return
        }
        notebooksDataManager.deleteAllNotebooks()
        self.setupResultsController()
        viewDelegate?.notebookDataChange()
    }
    
    func addDummyButtonTapped() {
        notebooksDataManager?.createDummyContent()
    }
    
    func deleteNotebookButtonTapped(at indexPath: IndexPath) {
        guard let notebooksDataManager = notebooksDataManager,
              let notebook = fetchResultsController?.object(at: indexPath) as? NotebookMO else {
            fatalError("Error selecting a notebook from table view")
        }
        notebooksDataManager.deleteNotebook(notebook: notebook)
    }

}


extension NotebooksViewModel: NSFetchedResultsControllerDelegate {
    
    // will change
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       print("Will Change")
    }
    
    // did change a section.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType){
        print("did change a section")
    }
    
    // did change an object.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("did change an object")
        
        self.viewDelegate?.notebookDataChange()
        
    }
    
    // did change content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change content.")
    }
    
}
