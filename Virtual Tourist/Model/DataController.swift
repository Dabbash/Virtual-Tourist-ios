//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Ahmed AlKharraz on 20/07/2021.
//

import Foundation
import CoreData

class DataController {
    
 let persistentContainer: NSPersistentContainer
 var viewContext: NSManagedObjectContext {
     return persistentContainer.viewContext
 }
 
 init(modelName: String) {
     persistentContainer = NSPersistentContainer(name: modelName)
 }
 
 func load(completion: (()->Void)? = nil) {
     persistentContainer.loadPersistentStores { storeDescription, error in
         guard error == nil else {
             fatalError(error!.localizedDescription)
         }
         completion?()
         
         
     }
 }
}
