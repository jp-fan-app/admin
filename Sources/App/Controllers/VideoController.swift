//
//  VideoController.swift
//  App
//
//  Created by Christoph Pageler on 03.03.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class VideoController {

    // MARK: - Index

    struct VideoIndexContext: Codable {

        let videos: [JPFanAppClient.YoutubeVideo]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().videosIndex().flatMap { videos in
            let context = DefaultContext(.videos,
                                         VideoIndexContext(videos: videos),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/videos/index", context)
        }
    }

    // MARK: - Find

    struct FindFlags: Content {

        let addToVideoSerieID: String?
        let addToStageID: String?

    }

    struct VideoFindForm: Codable {

        let query: String

    }

    struct VideoFindContext: Codable {

        let query: String?
        let videos: [JPFanAppClient.YoutubeVideo]
        let flags: FindFlags?
        let addTo: AddButtons
        let form: VideoFindForm?
        var videoSerie: JPFanAppClient.VideoSerie?
        var model: JPFanAppClient.CarModel?
        var stage: JPFanAppClient.CarStage?

        struct AddButtons: Codable {

            let stage: Bool
            let videoSerie: Bool

            static func from(flags: FindFlags?) -> AddButtons {
                return AddButtons(stage: flags?.addToStageID?.count ?? 0 > 0,
                                  videoSerie: flags?.addToVideoSerieID?.count ?? 0 > 0)
            }

        }

        func addToVideoSerieID() -> Int? {
            guard let stringValue = flags?.addToVideoSerieID else { return nil }
            return Int(stringValue)
        }

        func addToStageID() -> Int? {
            guard let stringValue = flags?.addToStageID else { return nil }
            return Int(stringValue)
        }

    }

    func find(_ req: Request) throws -> EventLoopFuture<View> {
        let flags = try? req.query.decode(FindFlags.self)
        let context = DefaultContext(.videos,
                                     VideoFindContext(query: nil, videos: [], flags: flags,
                                                      addTo: .from(flags: flags), form: nil,
                                                      videoSerie: nil, stage: nil),
                                     isAdmin: req.isAdmin(),
                                     username: req.username())
        return req.view.render("pages/videos/find", context)
    }

    func findPOST(_ req: Request) throws -> EventLoopFuture<View> {
        let form = try req.content.decode(VideoFindForm.self)
        let search = JPFanAppClient.YoutubeVideoSearchRequest(query: form.query)
        let flags = try? req.query.decode(FindFlags.self)
        return req.client().videosSearch(search).flatMap { videos in
            var findVideoContext = VideoFindContext(query: nil, videos: videos, flags: flags,
                                                    addTo: .from(flags: flags), form: form,
                                                    videoSerie: nil, stage: nil)

            var resolveFutures: [EventLoopFuture<Void>] = []

            if let stageID = findVideoContext.addToStageID() {
                let done = req.client().stagesShow(id: stageID).flatMap { stage -> EventLoopFuture<Void> in
                    findVideoContext.stage = stage
                    return req.client().modelsShow(id: stage.carModelID).map { carModel in
                        findVideoContext.model = carModel
                    }
                }
                resolveFutures.append(done)
            }
            if let videoSerieID = findVideoContext.addToVideoSerieID() {
                let done = req.client().videoSeriesShow(id: videoSerieID).map { videoSerie -> Void in
                    findVideoContext.videoSerie = videoSerie
                }
                resolveFutures.append(done)
            }

            return resolveFutures.flatten(on: req.eventLoop).flatMap { _ in
                let context = DefaultContext(.videos, findVideoContext,
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/videos/find", context)
            }
        }
    }

}
