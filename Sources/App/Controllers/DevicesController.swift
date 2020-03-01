//
//  DevicesController.swift
//  App
//
//  Created by Christoph Pageler on 29.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class DevicesController {

    // MARK: - Index

    struct DevicesIndexContext: Codable {

        let devices: [JPFanAppClient.Device]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().devicesIndex().flatMap { devices in
            let context = DefaultContext(.devices,
                                         DevicesIndexContext(devices: devices),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/devices/index", context)
        }
    }

}
