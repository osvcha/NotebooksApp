//
//  NotebookMO+CoreDataClass.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//
//

import Foundation
import CoreData


public class NotebookMO: NSManagedObject {
    
    @discardableResult
    static func createNotebook(createdAt: Date,
                               title: String,
                               in managedObjectContext: NSManagedObjectContext) -> NotebookMO? {
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook",
                                                           into: managedObjectContext) as? NotebookMO
        notebook?.createdAt = createdAt
        notebook?.title = title
        return notebook
    }
    
}
