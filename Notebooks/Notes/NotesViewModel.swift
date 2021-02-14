//
//  NotesViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//

import Foundation
import CoreData

protocol NotesCoordinatorDelegate: class {
    func didSelect(note: NoteMO)
    func notesPlusButtonTapped(notebook: NotebookMO)
}

protocol NotesViewDelegate: class {
    func notesFetched()
    func errorFetchingNotes()
    func noteDataChange()
}



class NotesViewModel: NSObject {
    
    weak var coordinatorDelegate: NotesCoordinatorDelegate?
    weak var viewDelegate: NotesViewDelegate?
    let notesDataManager: DataManagerCoreData?
    var fetchResultsController:  NSFetchedResultsController<NSFetchRequestResult>?
    var notebook: NotebookMO?
    var predicateSearchBar: String = ""

    init(notebook: NotebookMO, notesDataManager: DataManagerCoreData) {
        self.notebook = notebook
        self.notesDataManager = notesDataManager
    }
    
    fileprivate func setupResultsController() {
        
        guard let notesDataManager = notesDataManager,
            let notebook = notebook else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let noteNameSortDescriptor = NSSortDescriptor(key: "createdAt",
                                                          ascending: false)
        request.sortDescriptors = [noteNameSortDescriptor]
        
        if (predicateSearchBar != "") {
            request.predicate = NSPredicate(format: "(notebook == %@) AND ((title CONTAINS[c] %@) OR (content CONTAINS[c] %@))", notebook, predicateSearchBar, predicateSearchBar)
        } else {
            request.predicate = NSPredicate(format: "notebook == %@", notebook)
        }
        
        
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: notesDataManager.viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        
        self.fetchResultsController?.delegate = self
        
        do {
            try self.fetchResultsController?.performFetch()
        } catch {
            print("Error while trying to perform a note fetch.")
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
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        if let fetchResultsController = fetchResultsController {
            return fetchResultsController.sections![section].numberOfObjects
        } else {
            return 0
        }
        
    }
    
    func viewModel(at indexPath: IndexPath) -> NoteCellViewModel? {
        guard let note = fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        let noteCell = NoteCellViewModel(note: note)
        return noteCell
        
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        
        guard let note = fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Error selecting a note from table view")
        }
        coordinatorDelegate?.didSelect(note: note)
    }
    
    func plusButtonTapped() {
        guard let notebook = notebook else {return}
        coordinatorDelegate?.notesPlusButtonTapped(notebook: notebook)
    }
    
    func deleteNoteButtonTapped(at indexPath: IndexPath) {
        guard let notesDataManager = notesDataManager,
              let note = fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Error selecting a note from table view")
        }
        notesDataManager.deleteNote(note: note)
    }

}

extension NotesViewModel: NSFetchedResultsControllerDelegate {
    
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
        self.viewDelegate?.noteDataChange()
        
    }
    
    // did change content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change content.")
    }
    
}

