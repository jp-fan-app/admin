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
            let newClient: JPFanAppClient
            if environment == .production {
                newClient = JPFanAppClient(accessToken: accessToken,
                                           baseURL: URL(string: "http://api:8080")!,
                                           carImagesBaseURL: URL(string: "https://car-images.jp-fan-app.de")!)
            } else {
//                newClient = JPFanAppClient.production(accessToken: accessToken)
                newClient = JPFanAppClient(accessToken: accessToken,
                                           baseURL: URL(string: "http://0.0.0.0:8081")!,
                                           carImagesBaseURL: URL(string: "https://car-images.jp-fan-app.de")!)
            }
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
