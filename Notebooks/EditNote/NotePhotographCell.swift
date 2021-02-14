//
//  NotePhotographCell.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 14/02/2021.
//

import UIKit

class NotePhotographCell: UICollectionViewCell {
    
    private let photoImage: UIImageView = {
        let photoImage = UIImageView()
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        photoImage.clipsToBounds = true
        photoImage.layer.cornerRadius = 10
        photoImage.contentMode = .scaleAspectFill
        
        return photoImage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(photoImage)
        
        photoImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        photoImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        photoImage.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        photoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder not been implemented")
    }
    
    var viewModel: NotePhotographCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            photoImage.image = viewModel.image
        }
    }
}
