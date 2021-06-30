//
//  ProfileManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/27/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    
    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var mainViewModel: MainViewModel
    
    init(persistenceManager: PersistenceManager, crashManager: CrashManager, mainViewModel: MainViewModel) {
        self.viewContext = persistenceManager.container.viewContext
        self.crashManager = crashManager
        self.mainViewModel = mainViewModel
        
        loadProfiles()
    }
    
    public func loadProfiles() {
        do {
            profiles = try self.viewContext.fetch(Profile.fetchRequest()) as! [Profile]
            if profiles.count == 0 {
                profiles.append(createDefault())
            }
            mainViewModel.activeProfile = profiles.first
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
    
    public func createDefault() -> Profile {
        let defaultProfile = Profile.create(in: viewContext)
        
        // Adopt existing history
        do {
            let history = try self.viewContext.fetch(History.fetchRequest()) as! [History]
            history.forEach { visit in
                defaultProfile.addToHistory(visit)
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
        
        // Adopt existing pages
        do {
            let pages = try self.viewContext.fetch(Page.fetchRequest()) as! [Page]
            pages.forEach { page in
                defaultProfile.addToPages(page)
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
        
        do {
            try viewContext.save()
            profiles.append(defaultProfile)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
        
        return defaultProfile
    }
}
