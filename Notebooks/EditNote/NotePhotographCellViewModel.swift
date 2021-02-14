//
//  NotePhotographCellViewModel.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 14/02/2021.
//

import Foundation
import UIKit

class NotePhotographCellViewModel {
    let photograph: PhotographMO
    var image: UIImage?
    
    init(photograph: PhotographMO) {
        self.photograph = photograph
        guard let imageData = photograph.imageData else {return}
        self.image = UIImage(data: imageData)
    }
}
