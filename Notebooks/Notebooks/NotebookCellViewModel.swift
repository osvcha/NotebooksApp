//
//  NotebookCellViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 09/02/2021.
//

import Foundation

class NotebookCellViewModel {
    let notebook: NotebookMO
    var textLabelText: String?
    var detailTextLabel: String?
    var notebookImageName: String?
    
    init(notebook: NotebookMO) {
        self.notebook = notebook
        textLabelText = notebook.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        detailTextLabel = formatter.string(from: notebook.createdAt ?? Date())
        
        notebookImageName = "notebook"
        
        
    }
    
}
