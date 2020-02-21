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

    struct ModelIndexContext: Codable {

        var models: [JPFanAppClient.CarModel]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().modelsIndex().flatMap { models in
            let context = DefaultContext(.models, ModelIndexContext(models: models))
            return req.view.render("pages/models/index", context)
        }
    }

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
                    let context = DefaultContext(.models, ModelShowContext(model: model,
                                                                           stages: stages,
                                                                           images: images))
                    return req.view.render("pages/models/show", context).encodeResponse(for: req)
                }
            }
        }
    }

}
