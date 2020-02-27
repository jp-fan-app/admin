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

    // MARK: - Index

    struct ManufacturerIndexContext: Codable {

        let manufacturers: [JPFanAppClient.ManufacturerModel]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().manufacturersIndex().flatMap { manufacturers in
            let context = DefaultContext(.manufacturers,
                                         ManufacturerIndexContext(manufacturers: manufacturers),
                                         isAdmin: req.isAdmin())
            return req.view.render("pages/manufacturers/index", context)
        }
    }

    // MARK: - Show

    struct ManufacturerShowContext: Codable {

        let manufacturer: JPFanAppClient.ManufacturerModel
        let models: [JPFanAppClient.CarModel]

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

    // MARK: - Create

    struct CreateForm: Codable {

        let name: String

    }

    struct ManufacturerCreateContext: Codable {

        let form: CreateForm

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

    // MARK: - Update

    struct EditForm: Codable {

        let name: String

    }

    struct ManufacturerEditContext: Codable {

        let form: EditForm
        let manufacturer: JPFanAppClient.ManufacturerModel

    }

    func edit(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/manufacturers"))
        }

        return req.client().manufacturersShow(id: id).flatMap { manufacturer in
            let context = DefaultContext(.manufacturers,
                                         ManufacturerEditContext(form: ManufacturerController.EditForm(name: manufacturer.name),
                                                                 manufacturer: manufacturer),
                                         isAdmin: req.isAdmin())
            return req.view.render("pages/manufacturers/edit", context).encodeResponse(for: req)
        }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/manufacturers"))
        }

        let editForm = try req.content.decode(EditForm.self)

        return req
            .client()
            .manufacturersPatch(id: id, manufacturer: JPFanAppClient.ManufacturerEdit(name: editForm.name))
            .map
        { manufacturer in
            guard let id = manufacturer.id else {
                return req.redirect(to: "/manufacturers")
            }
            return req.redirect(to: "/manufacturers/\(id)")
        }
    }

    // MARK: - Delete

    struct ManufacturerDeleteContext: Codable {

        var manufacturer: JPFanAppClient.ManufacturerModel

    }

    func delete(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/manufacturers"))
        }

        return req.client().manufacturersShow(id: id).flatMap { manufacturer in
            let context = DefaultContext(.manufacturers,
                                         ManufacturerDeleteContext(manufacturer: manufacturer),
                                         isAdmin: req.isAdmin())
            return req.view.render("pages/manufacturers/delete", context).encodeResponse(for: req)
        }
    }

    func deletePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/manufacturers"))
        }

        return req.client().manufacturersDelete(id: id).map { _ in
            return req.redirect(to: "/manufacturers")
        }
    }

}
