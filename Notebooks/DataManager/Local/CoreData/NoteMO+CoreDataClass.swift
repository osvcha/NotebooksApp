//
//  NoteMO+CoreDataClass.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//
//

import Foundation
import CoreData


public class NoteMO: NSManagedObject {

    @discardableResult
    static func createNote(createdAt: Date,
                           notebook: NotebookMO,
                           title: String,
                           content: String,
                           in managedObjectContext: NSManagedObjectContext) -> NoteMO? {
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note",
                                                       into: managedObjectContext) as? NoteMO
        note?.createdAt = createdAt
        note?.title = title
        note?.content = content
        note?.notebook = notebook
        
        return note
    }
}
