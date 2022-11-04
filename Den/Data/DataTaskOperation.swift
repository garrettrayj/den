//
//  FetchOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

/**
 Operation for fetching feed XML (or JSON) data.
 */
final class DataTaskOperation: AsynchronousOperation {
    var url: URL?

    // Operation outputs
    weak var response: HTTPURLResponse?
    var data: Data?
    var error: Error?

    weak private var task: URLSessionTask?

    init(_ url: URL? = nil) {
        self.url = url
        super.init()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    override func main() {
        guard let requestUrl = url else {
            Logger.ingest.debug("DataTaskOperation missing URL")
            self.finish()
            return
        }

        var request = URLRequest(url: requestUrl)
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30

        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.data = data
            self?.error = error
            self?.response = response as? HTTPURLResponse
            self?.finish()
        }
        task?.resume()
    }
}
