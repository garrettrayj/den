//
//  BlocklistPreset.swift
//  Den
//
//  Created by Garrett Johnson on 10/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

enum BlocklistPreset: CaseIterable {
    case easyList
    case easyPrivacy
    case easyListCookieList
    case fanboysSocialBlockingList
    case fanboysAnnoyanceList
    case antiPaywall

    var url: URL {
        switch self {
        case .easyList:
            return URL(string: "https://easylist.to/easylist/easylist.txt")!
        case .easyPrivacy:
            return URL(string: "https://easylist.to/easylist/easyprivacy.txt")!
        case .easyListCookieList:
            return URL(string: "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt")!
        case .fanboysSocialBlockingList:
            return URL(string: "https://easylist.to/easylist/fanboy-social.txt")!
        case .fanboysAnnoyanceList:
            return URL(string: "https://secure.fanboy.co.nz/fanboy-annoyance.txt")!
        case .antiPaywall:
            return URL(string: "https://raw.githubusercontent.com/liamengland1/miscfilters/master/antipaywall.txt")!
        }
    }

    var name: String {
        switch self {
        case .easyList:
            return "EasyList"
        case .easyPrivacy:
            return "EasyPrivacy"
        case .easyListCookieList:
            return "EasyList Cookie List"
        case .fanboysSocialBlockingList:
            return "Fanboy's Social Blocking List"
        case .fanboysAnnoyanceList:
            return "Fanboy's Annoyance List"
        case .antiPaywall:
            return "Anti Paywall"
        }
    }
}
