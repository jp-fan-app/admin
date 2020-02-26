//
//  ManufacturerController.swift
//  App
//
//  Created by Christoph Pageler on 21.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class ManufacturerController {

    struct ManufacturerIndexContext: Codable {

        var manufacturers: [JPFanAppClient.ManufacturerModel]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().manufacturersIndex().flatMap { manufacturers in
            let context = DefaultContext(.manufacturers,
                                         ManufacturerIndexContext(manufacturers: manufacturers),
                                         isAdmin: req.isAdmin())
            return req.view.render("pages/manufacturers/index", context)
        }
    }

    struct ManufacturerShowContext: Codable {

        var manufacturer: JPFanAppClient.ManufacturerModel
        var models: [JPFanAppClient.CarModel]

    }

    func show(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/manufacturers"))
        }

        return req.client().manufacturersShow(id: id).flatMap { manufacturer in
            req.client().manufacturersModels(id: id).flatMap { models in
                let context = DefaultContext(.manufacturers,
                                             ManufacturerShowContext(manufacturer: manufacturer,
                                                                     models: models),
                                             isAdmin: req.isAdmin())
                return req.view.render("pages/manufacturers/show", context).encodeResponse(for: req)
            }
        }
    }

    struct CreateForm: Codable {

        var name: String

    }

    struct ManufacturerCreateContext: Codable {

        var form: CreateForm

    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let createForm = try req.content.decode(CreateForm.self)
        return req
            .client()
            .manufacturersCreate(JPFanAppClient.ManufacturerEdit(name: createForm.name))
            .map
        { newManufacturer in
            guard let id = newManufacturer.id else {
                return req.redirect(to: "/manufacturers")
            }
            return req.redirect(to: "/manufacturers/\(id)")
        }
    }

}
