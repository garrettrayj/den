//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import CoreData
import OSLog
import SwiftUI
import BackgroundTasks

import SDWebImageSwiftUI
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var activeProfile: Profile?
    @State private var refreshing: Bool = false
    
    @AppStorage("AutoRefreshEnabled") var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") var autoRefreshCooldown: Int = 30
    @AppStorage("AutoRefreshDate") var autoRefreshDate: Double = 0.0
    @AppStorage("BackgroundRefreshEnabled") var backgroundRefreshEnabled: Bool = false
    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    var body: some Scene {
        WindowGroup {
            RootView(
                activeProfile: $activeProfile,
                refreshing: $refreshing,
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                uiStyle: $uiStyle
            )
            .preferredColorScheme(ColorScheme(uiStyle))
            .environment(\.persistentContainer, container)
            .environment(\.managedObjectContext, container.viewContext)
            .onOpenURL { url in
                SubscriptionUtility.showSubscribe(for: url.absoluteString)
            }
            .modifier(URLDropTargetModifier())
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            await handleRefresh(background: true)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
                if activeProfile == nil {
                    loadProfile()
                }
                if autoRefreshEnabled && !refreshing && (
                    autoRefreshDate == 0.0 ||
                    Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                ) {
                    Task {
                        await handleRefresh()
                    }
                    autoRefreshDate = Date.now.timeIntervalSinceReferenceDate
                }
            case .inactive:
                Logger.main.debug("Scene phase: inactive")
            case .background:
                Logger.main.debug("Scene phase: background")
                if backgroundRefreshEnabled {
                    scheduleAppRefresh()
                }
            @unknown default:
                Logger.main.debug("Scene phase: unknown")
            }
        }
    }

    private var container: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "Den")
        
        guard let appSupportDirectory = FileManager.default.appSupportDirectory else {
            preconditionFailure("Storage directory not available")
        }

        var cloudStoreLocation = appSupportDirectory.appendingPathComponent("Den.sqlite")
        var localStoreLocation = appSupportDirectory.appendingPathComponent("Den-Local.sqlite")

        if CommandLine.arguments.contains("--reset") {
            // Use in memory storage
            cloudStoreLocation = URL(fileURLWithPath: "/dev/null/1")
            localStoreLocation = URL(fileURLWithPath: "/dev/null/2")
        }

        // Create a store description for a CloudKit-backed store
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.net.devsci.den"
        )

        // Create a store description for a local store
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"

        // Create container
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]

        // Load both stores
        container.loadPersistentStores { _, error in
            guard error == nil else {
                /*
                Typical reasons for an error here include:
                 
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection
                  when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                CrashUtility.handleCriticalError(error! as NSError)
                return
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.undoManager = nil
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }

        return container
    }()
    
    init() {
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")

        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 256 // 256 MB
    }

    private func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = .now + 10 * 60
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("""
            Background refresh task scheduled with earliest begin date \
            \(request.earliestBeginDate?.formatted() ?? "NA")
            """)
        } catch {
            Logger.main.warning("Background refresh not scheduled")
        }
        // Break here to simulate background task
    }
    
    private func handleRefresh(background: Bool = false) async {
        guard !refreshing, let profile = activeProfile else { return }
        await RefreshUtility.refresh(container: container, profile: profile)
    }
    
    private func loadProfile() {
        activeProfile = ProfileUtility.loadProfile(context: container.viewContext)
        WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
    }
}
