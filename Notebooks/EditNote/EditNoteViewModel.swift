//
//  EditNoteViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 13/02/2021.
//

import Foundation
import CoreData

protocol EditNoteCoordinatorDelegate: class {
    func noteSaveButtonTapped()
}

protocol EditNoteViewDelegate: class {
    
    func newNoteImage(at: IndexPath)
    
}

class EditNoteViewModel: NSObject {
    
    weak var coordinatorDelegate: EditNoteCoordinatorDelegate?
    weak var viewDelegate: EditNoteViewDelegate?
    let editNoteDataManager: DataManagerCoreData?
    var fetchResultsController:  NSFetchedResultsController<NSFetchRequestResult>?
    var note: NoteMO?
    
    var blockOperations: [BlockOperation] = []
    
    init(note: NoteMO, editNoteDataManager: DataManagerCoreData) {
        self.note = note
        self.editNoteDataManager = editNoteDataManager
    }
    
    deinit {
        for operation in blockOperations { operation.cancel() }
        blockOperations.removeAll()
    }

    
    fileprivate func setupPhotoResultsController() {
        
        guard let editNoteDataManager = editNoteDataManager,
            let note = note else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photograph")
        let noteNameSortDescriptor = NSSortDescriptor(key: "createdAt",
                                                          ascending: false)
        request.sortDescriptors = [noteNameSortDescriptor]
        
        
        request.predicate = NSPredicate(format: "note == %@", note)
        
        
        
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: editNoteDataManager.viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        
        self.fetchResultsController?.delegate = self
        
        do {
            try self.fetchResultsController?.performFetch()
        } catch {
            print("Error while trying to perform a note fetch.")
        }
        
    }
    
    func viewWasLoaded() {
        self.setupPhotoResultsController()
    }

    func numberOfItems(in section: Int) -> Int {
        if let fetchResultsController = fetchResultsController {
            return fetchResultsController.sections![section].numberOfObjects
        } else {
            return 0
        }
        
    }
    
    func viewModel(at indexPath: IndexPath) -> NotePhotographCellViewModel? {
        guard let photograph = fetchResultsController?.object(at: indexPath) as? PhotographMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        let notePhotoCell = NotePhotographCellViewModel(photograph: photograph)
        return notePhotoCell
        
    }
    
    func noteSaveButtonTapped(title: String, content: String) {
        //guardo datos
        guard let note = note else { return }
        editNoteDataManager?.updateNote(note: note, title: title, content: content)
        //aviso al coordinator
        coordinatorDelegate?.noteSaveButtonTapped()
    }
    
    func addNotePhoto(with photoUrl: URL){
        guard let note = note else { return }
        editNoteDataManager?.addNotePhoto(photoUrl: photoUrl, note: note )
    }
}


extension EditNoteViewModel: NSFetchedResultsControllerDelegate {
    
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
        
        switch type {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let newIndexPath = newIndexPath {
                        self?.viewDelegate?.newNoteImage(at: newIndexPath)
                    }
                })
            )
            
        default:
            fatalError()
        }
        
        
    }
    
    // did change content.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change content.")
        
        for operation: BlockOperation in self.blockOperations {
            operation.start()
        }
        
    }
    
}




