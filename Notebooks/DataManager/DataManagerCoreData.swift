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
            
            guard let imageThumbnail = DownSampler.downsample(imageAt: photoUrl, to: CGSize(width: 100, height: 100), scale: CGFloat(3)),
                  let imageDataJpg = imageThumbnail.jpegData(compressionQuality: 1) else { return }
            
            
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
            
            
            if let image1URL = Bundle.main.url(forResource: "GranCanaria1", withExtension: "jpg") {
                
                guard let image1Thumbnail = DownSampler.downsample(imageAt: image1URL, to: CGSize(width: 100, height: 100), scale: CGFloat(3)),
                      let image1DataJpg = image1Thumbnail.jpegData(compressionQuality: 1) else { return }
                guard let photograph1 = PhotographMO.createPhoto(createdAt: Date(),
                                                                 imageData: image1DataJpg,
                                                                 in: managedObjectContext) else { return }
            
                note.addToPhotographs(photograph1)
                
            }
            
            if let image2URL = Bundle.main.url(forResource: "GranCanaria2", withExtension: "jpg") {
                
                guard let image2Thumbnail = DownSampler.downsample(imageAt: image2URL, to: CGSize(width: 100, height: 100), scale: CGFloat(3)),
                      let image2DataJpg = image2Thumbnail.jpegData(compressionQuality: 1) else { return }
                guard let photograph2 = PhotographMO.createPhoto(createdAt: Date(),
                                                                 imageData: image2DataJpg,
                                                                 in: managedObjectContext) else { return }
            
                note.addToPhotographs(photograph2)
                
            }
            
            if let image3URL = Bundle.main.url(forResource: "GranCanaria3", withExtension: "jpg") {
                
                guard let image3Thumbnail = DownSampler.downsample(imageAt: image3URL, to: CGSize(width: 100, height: 100), scale: CGFloat(3)),
                      let image3DataJpg = image3Thumbnail.jpegData(compressionQuality: 1) else { return }
                guard let photograph3 = PhotographMO.createPhoto(createdAt: Date(),
                                                                 imageData: image3DataJpg,
                                                                 in: managedObjectContext) else { return }
            
                note.addToPhotographs(photograph3)
                
            }
            
            if let image4URL = Bundle.main.url(forResource: "GranCanaria4", withExtension: "jpg") {
                
                guard let image4Thumbnail = DownSampler.downsample(imageAt: image4URL, to: CGSize(width: 100, height: 100), scale: CGFloat(3)),
                      let image4DataJpg = image4Thumbnail.jpegData(compressionQuality: 1) else { return }
                guard let photograph4 = PhotographMO.createPhoto(createdAt: Date(),
                                                                 imageData: image4DataJpg,
                                                                 in: managedObjectContext) else { return }
            
                note.addToPhotographs(photograph4)
                
            }
            

            
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("could not dummy content.")
            }
             
            
        }
        
        
        
    }
    
    
}
