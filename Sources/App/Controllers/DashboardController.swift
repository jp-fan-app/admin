//
//  DashboardController.swift
//  App
//
//  Created by Christoph Pageler on 28.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class DashboardController {

    struct DashboardIndexContext: Codable {

        let manufacturerDrafts: [JPFanAppClient.ManufacturerModel]
        let modelDrafts: [JPFanAppClient.CarModel]
        let videoSerieDrafts: [JPFanAppClient.VideoSerie]
        let imageDrafts: [JPFanAppClient.CarImage]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().manufacturersIndexDraft().flatMap { manufacturerDrafts in
            return req.client().modelsIndexDraft().flatMap { modelDrafts in
                return req.client().videoSeriesIndexDraft().flatMap { videoSerieDrafts in
                    return req.client().imagesIndexDraft().flatMap { imageDrafts in
                        let context = DefaultContext(.dashboard,
                                                     DashboardIndexContext(manufacturerDrafts: manufacturerDrafts,
                                                                           modelDrafts: modelDrafts,
                                                                           videoSerieDrafts: videoSerieDrafts,
                                                                           imageDrafts: imageDrafts),
                                                     isAdmin: req.isAdmin(),
                                                     username: req.username())
                        return req.view.render("pages/dashboard/index", context)
                    }
                }
            }
        }
    }

}
