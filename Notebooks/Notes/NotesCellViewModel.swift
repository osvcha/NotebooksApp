//
//  NotesCellViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 11/02/2021.
//

import Foundation

class NoteCellViewModel {
    let note: NoteMO
    var textLabelText: String?
    var detailTextLabel: String?
    
    init(note: NoteMO) {
        self.note = note
        textLabelText = note.title
        detailTextLabel = note.content
    }
    
}
