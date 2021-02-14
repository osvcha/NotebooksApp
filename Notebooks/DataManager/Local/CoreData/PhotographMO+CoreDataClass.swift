//
//  PhotograhpMO+CoreDataClass.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//
//

import Foundation
import CoreData

public class PhotographMO: NSManagedObject {
    static func createPhoto(createdAt: Date,
                            imageData: Data,
                            in managedObjectContext: NSManagedObjectContext) -> PhotographMO? {
        let photograph = NSEntityDescription.insertNewObject(forEntityName: "Photograph",
                                                             into: managedObjectContext) as? PhotographMO
        
        photograph?.createdAt = createdAt
        photograph?.imageData = imageData
        return photograph
    }
}
