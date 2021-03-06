//
//  Application+Client.swift
//  App
//
//  Created by Christoph Pageler on 20.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


extension Application {

    var client: JPFanAppClient {
        if let existing = self.storage[ClientKey] {
            return existing
        } else {
            let accessToken = ProcessInfo.processInfo.environment["ACCESS_TOKEN"] ?? ""
            let newClient = JPFanAppClient.production(accessToken: accessToken)
            self.storage[ClientKey] = newClient
            return newClient
        }
    }

    private struct ClientKey: StorageKey {
        typealias Value = JPFanAppClient
    }

    func client(_ req: Request) -> JPFanAppClient {
        client.authToken = req.session.data["authToken"]
        return client
    }

}

extension Request {

    func client() -> JPFanAppClient {
        return application.client(self)
    }

}
