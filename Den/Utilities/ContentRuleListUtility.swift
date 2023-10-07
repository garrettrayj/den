//
//  ContentRuleListUtility.swift
//  Den
//
//  Created by Garrett Johnson on 10/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import WebKit

final class ContentRuleListUtility {
    var contentRuleList: WKContentRuleList?

    static let shared = ContentRuleListUtility()

    func getContentRuleList() async -> WKContentRuleList? {
        if contentRuleList != nil {
            return contentRuleList
        }

        guard
            let path = Bundle.main.path(forResource: "EasyListMinContentBlocker", ofType: "json"),
            let ruleListString = try? String(contentsOfFile: path)
        else {
            return nil
        }

        contentRuleList = try? await WKContentRuleListStore
            .default()
            .compileContentRuleList(
                forIdentifier: "EasyList",
                encodedContentRuleList: ruleListString
            )

        return contentRuleList
    }
}
