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

        let hasDrafts: Bool

        let hasManufacturerDrafts: Bool
        let manufacturerDrafts: [JPFanAppClient.ManufacturerModel]

        let hasModelDrafts: Bool
        let modelDrafts: [JPFanAppClient.CarModel]

        let hasVideoSerieDrafts: Bool
        let videoSerieDrafts: [JPFanAppClient.VideoSerie]

        let hasImageDrafts: Bool
        let imageDrafts: [JPFanAppClient.CarImage]

        let hasStageDrafts: Bool
        let stageDrafts: [JPFanAppClient.CarStage]

        let hasTimingDrafts: Bool
        let timingDrafts: [JPFanAppClient.StageTiming]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().manufacturersIndexDraft().flatMap { manufacturerDrafts in
            return req.client().modelsIndexDraft().flatMap { modelDrafts in
                return req.client().videoSeriesIndexDraft().flatMap { videoSerieDrafts in
                    return req.client().imagesIndexDraft().flatMap { imageDrafts in
                        return req.client().stagesIndexDraft().flatMap { stageDrafts in
                            return req.client().timingsIndexDraft().flatMap { timingDrafts in

                                let hasManufacturerDrafts = manufacturerDrafts.count > 0
                                let hasModelDrafts = modelDrafts.count > 0
                                let hasVideoSerieDrafts = videoSerieDrafts.count > 0
                                let hasImageDrafts = imageDrafts.count > 0
                                let hasStageDrafts = stageDrafts.count > 0
                                let hasTimingDrafts = timingDrafts.count > 0

                                let hasDrafts = [
                                    hasManufacturerDrafts,
                                    hasModelDrafts,
                                    hasVideoSerieDrafts,
                                    hasImageDrafts,
                                    hasStageDrafts,
                                    hasTimingDrafts
                                ].contains(true)

                                let context = DefaultContext(.dashboard,
                                                             DashboardIndexContext(
                                                                hasDrafts: hasDrafts,
                                                                hasManufacturerDrafts: hasManufacturerDrafts,
                                                                manufacturerDrafts: manufacturerDrafts,
                                                                hasModelDrafts: hasModelDrafts,
                                                                modelDrafts: modelDrafts,
                                                                hasVideoSerieDrafts: hasVideoSerieDrafts,
                                                                videoSerieDrafts: videoSerieDrafts,
                                                                hasImageDrafts: hasImageDrafts,
                                                                imageDrafts: imageDrafts,
                                                                hasStageDrafts: hasStageDrafts,
                                                                stageDrafts: stageDrafts,
                                                                hasTimingDrafts: hasTimingDrafts,
                                                                timingDrafts: timingDrafts),
                                                             isAdmin: req.isAdmin(),
                                                             username: req.username())
                                return req.view.render("pages/dashboard/index", context)
                            }
                        }
                    }
                }
            }
        }
    }

}
