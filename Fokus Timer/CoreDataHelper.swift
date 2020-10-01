//
//  CoreDataHelper.swift
//  Fokus Timer
//
//  Created by Indra Permana on 23/09/20.
//

import Foundation
import CoreData

class CoreDataHelper {
    let persistentContainer: NSPersistentContainer = {
        return NSPersistentContainer(name: "Fokus_Timer")
    }()
    
    
}
