//
//  Profile+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Profile)
public class Profile: NSManagedObject {
    public var wrappedName: String {
        get { name ?? "Untitled" }
        set { name = newValue }
    }
    
    public var wrappedHistoryRetention: Int {
        get { Int(historyRetention) }
        set { historyRetention = Int16(newValue) }
    }
    
    public var historyArray: [History] {
        get {
            guard let history = self.history else { return [] }
            return history.sortedArray(using: [NSSortDescriptor(key: "visited", ascending: false)]) as! [History]
        }
        set {
            history = NSSet(array: newValue)
        }
    }
    
    public var pagesArray: [Page] {
        get {
            guard let pages = self.pages else { return [] }
            return pages.sortedArray(using: [NSSortDescriptor(key: "userOrder", ascending: true)]) as! [Page]
        }
        set {
            pages = NSSet(array: newValue)
        }
    }
    
    public var pagesUserOrderMin: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder < result {
                return page.userOrder
            }
            return result
        }
    }
    
    public var pagesUserOrderMax: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder > result {
                return page.userOrder
            }
            return result
        }
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext) -> Profile {
        let newProfile = self.init(context: managedObjectContext)
        newProfile.id = UUID()
        newProfile.name = "New Profile"
        
        return newProfile
    }
}

extension Collection where Element == Profile, Index == Int {
    func delete(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
 
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
