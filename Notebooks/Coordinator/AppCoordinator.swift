//
//  AppCoordinator.swift
//  Notebooks
//
//  Created by Osvaldo Chaparro on 07/02/2021.
//

import UIKit

class AppCoordinator: Coordinator {
    
    var dataManager: DataManagerCoreData
    var window: UIWindow
    
    init(window: UIWindow, dataManager: DataManagerCoreData) {
        self.window = window
        self.dataManager = dataManager
    }
    
    override func start() {
        
        let notebooksNavigationController = UINavigationController()
        let notebooksCoordinator = NotebooksCoordinator(presenter: notebooksNavigationController,
                                                        notebooksDataManager: dataManager,
                                                        addNotebookDataManager: dataManager,
                                                        notesDataManager: dataManager,
                                                        addNoteDataManager: dataManager,
                                                        editNoteDataManager: dataManager)
        
        addChildCoordinator(notebooksCoordinator)
        notebooksCoordinator.start()
        
        window.rootViewController = notebooksNavigationController
        window.makeKeyAndVisible()
    }
    
    override func finish() {}
    
}
