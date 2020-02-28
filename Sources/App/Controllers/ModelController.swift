//
//  ModelController.swift
//  App
//
//  Created by Christoph Pageler on 21.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class ModelController {

    // MARK: - Index

    struct ModelIndexContext: Codable {

        let models: [JPFanAppClient.CarModel]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().modelsIndex().flatMap { models in
            let context = DefaultContext(.models,
                                         ModelIndexContext(models: models),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/index", context)
        }
    }

    // MARK: - Show

    struct ModelShowContext: Codable {

        var model: JPFanAppClient.CarModel
        var stages: [JPFanAppClient.CarStage]
        var images: [JPFanAppClient.CarImage]

    }

    func show(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            req.client().modelsStages(id: id).flatMap { stages in
                req.client().modelsImages(id: id).flatMap { images in
                    let context = DefaultContext(.models,
                                                 ModelShowContext(model: model,
                                                                  stages: stages,
                                                                  images: images),
                                                 isAdmin: req.isAdmin(),
                                                 username: req.username())
                    return req.view.render("pages/models/show", context).encodeResponse(for: req)
                }
            }
        }
    }

    // MARK: - New

    struct ModelEditForm: Codable {

        let name: String
        var manufacturerID: Int?
        let transmissionType: JPFanAppClient.CarModel.TransmissionType?
        let axleType: JPFanAppClient.CarModel.AxleType?

    }

    struct ModelEditContext: Codable {

        let manufacturers: [JPFanAppClient.ManufacturerModel]
        let model: JPFanAppClient.CarModel?
        let form: ModelEditForm?

    }

    struct ModelNewFlags: Content {

         var manufacturer_id: Int?

    }

    func new(_ req: Request) throws -> EventLoopFuture<Response> {
        let modelNewFlags = try? req.query.decode(ModelNewFlags.self)

        return req.client().allManufacturers().flatMap { manufacturers in
            var form = ModelEditForm(name: "", manufacturerID: nil, transmissionType: nil, axleType: nil)
            if let manufacturerID = modelNewFlags?.manufacturer_id {
                if manufacturers.contains(where: { $0.id == manufacturerID }) {
                    form.manufacturerID = manufacturerID
                }
            }
            let context = DefaultContext(.models,
                                         ModelEditContext(manufacturers: manufacturers, model: nil, form: form),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/new", context).encodeResponse(for: req)
        }
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let form = try req.content.decode(ModelEditForm.self)
        if let manufacturerID = form.manufacturerID,
            let transmissionType = form.transmissionType,
            let axleType = form.axleType
        {
            let model = JPFanAppClient.CarModel(name: form.name,
                                                manufacturerID: manufacturerID,
                                                transmissionType: transmissionType,
                                                axleType: axleType,
                                                mainImageID: nil)
            return req.client().modelsCreate(model: model).map { model in
                guard let id = model.id else {
                    return req.redirect(to: "/models")
                }
                return req.redirect(to: "/models/\(id)")
            }
        } else {
            return req.client().allManufacturers().flatMap { manufacturers in
                let context = DefaultContext(.models,
                                             ModelEditContext(manufacturers: manufacturers, model: nil, form: form),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/new", context).encodeResponse(for: req)
            }
        }
    }

    // MARK: - Update

    func edit(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            return req.client().allManufacturers().flatMap { manufacturers in
                let form = ModelEditForm(name: model.name,
                                         manufacturerID: model.manufacturerID,
                                         transmissionType: model.transmissionType,
                                         axleType: model.axleType)
                let context = DefaultContext(.models,
                                             ModelEditContext(manufacturers: manufacturers, model: model, form: form),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/edit", context).encodeResponse(for: req)
            }
        }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        let editForm = try req.content.decode(ModelEditForm.self)

        return req.client().modelsShow(id: id).flatMap { carModel in
            let patchModel = JPFanAppClient.CarModel(name: editForm.name,
                                                     manufacturerID: editForm.manufacturerID ?? carModel.manufacturerID,
                                                     transmissionType: editForm.transmissionType ?? carModel.transmissionType,
                                                     axleType: editForm.axleType ?? carModel.axleType,
                                                     mainImageID: carModel.mainImageID)
            return req.client().modelsPatch(id: id, model: patchModel).map { carModel in
                guard let id = carModel.id else {
                    return req.redirect(to: "/models")
                }
                return req.redirect(to: "/models/\(id)")
            }
        }
    }

    // MARK: - Delete

    struct ModelDeleteContext: Codable {

        var model: JPFanAppClient.CarModel

    }

    func delete(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            let context = DefaultContext(.manufacturers,
                                         ModelDeleteContext(model: model),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/delete", context).encodeResponse(for: req)
        }
    }

    func deletePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsDelete(id: id).map { _ in
            return req.redirect(to: "/models")
        }
    }

}
