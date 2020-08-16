//
//  ImportViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/15/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class ImportViewModel: ObservableObject {
    enum ImportStage {
        case pickFile, folderSelection, error, importing
    }
    
    @Published var stage: ImportStage = .pickFile
    @Published var importProgress: Double = 0
    @Published var opmlFolders: [OPMLFolder] = []
    @Published var selectedFolders: [OPMLFolder] = []
    @Published var pickedURL: URL?
    
    var allSelected: Bool {
        selectedFolders.count == opmlFolders.count
    }
    
    var noneSelected: Bool {
        selectedFolders.count == 0
    }
    
    func reset() {
        self.stage = .pickFile
        self.importProgress = 0
        self.opmlFolders = []
        self.selectedFolders = []
        self.pickedURL = nil
    }
    
    func toggleFolder(_ folder: OPMLFolder) {
        if selectedFolders.contains(folder) {
            selectedFolders.removeAll { $0 == folder }
        } else {
            selectedFolders.append(folder)
        }
    }
    
    func selectAll() {
        opmlFolders.forEach { folder in
            if !selectedFolders.contains(folder) {
                selectedFolders.append(folder)
            }
        }
    }
    
    func selectNone() {
        selectedFolders.removeAll()
    }
}
