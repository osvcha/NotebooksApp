//
//  DataManagerCoreData.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//

import CoreData
import UIKit

class DataManagerCoreData: NSObject {
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
            
        self.persistentContainer = NSPersistentContainer(name: modelName)
        
        super.init()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.persistentContainer.loadPersistentStores { [weak self] (description, error) in
                if let error = error {
                    fatalError("Couldn't load CoreData Stack \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    completionHandler(self?.persistentContainer)
                }
            }
        }
        
    }
    
    func saveNotebook(title: String, createdAt: Date) {
        let notebook = NotebookMO(context: viewContext)
        notebook.setValue(title, forKey: "title")
        notebook.setValue(createdAt, forKey: "createdAt")
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func saveNote(notebook: NotebookMO, title: String, content: String, createdAt: Date) {
        let note = NoteMO(context: viewContext)
        note.setValue(title, forKey: "title")
        note.setValue(content, forKey: "content")
        note.setValue(createdAt, forKey: "createdAt")
        note.setValue(notebook, forKey: "notebook")
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateNote(note: NoteMO, title: String, content: String) {
        
        let note = note
        note.title = title
        note.content = content

        do {
          try viewContext.save()
        } catch let error as NSError {
            print("Could not update note. \(error.localizedDescription), \(error.userInfo)")
        }
        
    }
    
    func deleteAll() {
        guard let persistentStoreUrl = persistentContainer
                .persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentStoreUrl,
                                                                                      ofType: NSSQLiteStoreType,
                                                                                      options: nil)
        } catch {
            fatalError("could not delete database. \(error.localizedDescription)")
        }
    }
    
    func deleteAllNotebooks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Notebook")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.save()
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
                viewContext.reset()
        } catch {
            fatalError("could not delete notebooks. \(error.localizedDescription)")
        }
    }
    
    func deleteNotebook(notebook: NotebookMO) {
        persistentContainer.viewContext.delete(notebook)
        
        do {
            try viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            fatalError("could not delete a notebook. \(error.localizedDescription)")
        }
        
    }
    
    func deleteNote(note: NoteMO) {
        persistentContainer.viewContext.delete(note)
        
        do {
            try viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            fatalError("could not delete a note. \(error.localizedDescription)")
        }
        
    }
    
    func addNotePhoto(photoUrl: URL, note: NoteMO) {
        
        performInBackground {  (managedObjectContext) in
            
            if let imageData = try? Data(contentsOf: photoUrl) {
                if let image = UIImage(data: imageData) {
                    guard let imageDataJpg = image.jpegData(compressionQuality: 1) else { return }
                    
                    
                    
                    //note.addToPhotographs(photograph)
                    
                    let noteID = note.objectID
                    let copyNote = managedObjectContext.object(with: noteID) as! NoteMO
                    
                    guard let photograph = PhotographMO.createPhoto(createdAt: Date(),
                                                          imageData: imageDataJpg,
                                                          in: managedObjectContext) else { return }
                    
                    copyNote.addToPhotographs(photograph)
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        fatalError("could not create note with thumbnail image in background.")
                    }
                    
                }
            }
 
        }

        
    }
    
    func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("=== could not save view context ===")
            print("error: \(error.localizedDescription)")
        }
    }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        //creamos nuestro managedobjectcontext privado
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        //seteamos nuestro viewcontext
        privateMOC.parent = viewContext
        
        //ejecutamos el block dentro de este privateMOC.
        privateMOC.perform {
            block(privateMOC)
        }
    }
    
    func createDummyContent() {
        
        performInBackground {  (managedObjectContext) in
            
            guard let notebook2 = NotebookMO.createNotebook(createdAt: Date(),
                                      title: "Otro Notebook",
                                      in: managedObjectContext) else {return}
            
            NoteMO.createNote(createdAt: Date(),
                              notebook: notebook2,
                              title: "Otra nota",
                              content: "Contenido de la nota",
                              in: managedObjectContext)
            
            guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                           title: "Notebook con notas y fotos",
                                                           in: managedObjectContext) else {return}
            
            NoteMO.createNote(createdAt: Date(),
                              notebook: notebook,
                              title: "Nota sin fotos",
                              content: "Nota sin fotos",
                              in: managedObjectContext)
            
            guard let note = NoteMO.createNote(createdAt: Date(),
                              notebook: notebook,
                              title: "Nota con fotos",
                              content: "Nota de prueba con fotos",
                              in: managedObjectContext) else { return }
            
            guard let image1 = UIImage(named: "GranCanaria1") else { return }
            guard let imageData1 = image1.jpegData(compressionQuality: 1) else { return }
            guard let photograph1 = PhotographMO.createPhoto(createdAt: Date(),
                                                             imageData: imageData1,
                                                             in: managedObjectContext) else { return }
            
            guard let image2 = UIImage(named: "GranCanaria2") else { return }
            guard let imageData2 = image2.jpegData(compressionQuality: 1) else { return }
            guard let photograph2 = PhotographMO.createPhoto(createdAt: Date(),
                                                             imageData: imageData2,
                                                             in: managedObjectContext) else { return }
            
            guard let image3 = UIImage(named: "GranCanaria3") else { return }
            guard let imageData3 = image3.jpegData(compressionQuality: 1) else { return }
            guard let photograph3 = PhotographMO.createPhoto(createdAt: Date(),
                                                             imageData: imageData3,
                                                             in: managedObjectContext) else { return }
            
            guard let image4 = UIImage(named: "GranCanaria4") else { return }
            guard let imageData4 = image4.jpegData(compressionQuality: 1) else { return }
            guard let photograph4 = PhotographMO.createPhoto(createdAt: Date(),
                                                             imageData: imageData4,
                                                             in: managedObjectContext) else { return }
            
            note.addToPhotographs(photograph1)
            note.addToPhotographs(photograph2)
            note.addToPhotographs(photograph3)
            note.addToPhotographs(photograph4)
            
            
            
            
            
            
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("could not dummy content.")
            }
            
        }
        
        
        
    }
    
    
}
