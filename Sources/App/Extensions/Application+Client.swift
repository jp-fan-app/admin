//
//  Request+Client.swift
//  App
//
//  Created by Christoph Pageler on 20.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


extension Request {

    var client: JPFanAppClient {
        JPFanAppClient.production(accessToken: "4C53F705-A66F-474A-AFC7-B2D3E6F53E5B")
    }

}
