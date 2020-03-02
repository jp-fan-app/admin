//
//  VideoSeriesController.swift
//  App
//
//  Created by Christoph Pageler on 29.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class VideoSeriesController {

    // MARK: - Index

    struct VideoSerieIndexContext: Codable {

        let videoSeries: [JPFanAppClient.VideoSerie]
        let hasDrafts: Bool
        let drafts: [JPFanAppClient.VideoSerie]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().videoSeriesIndex().flatMap { videoSeries in
            return req.client().videoSeriesIndexDraft().flatMap { drafts in
                let sortedVideoSeries = videoSeries.sorted(by: { $0.updatedAt ?? Date() > $1.updatedAt ?? Date() })
                let context = DefaultContext(.videoSeries,
                                             VideoSerieIndexContext(videoSeries: sortedVideoSeries,
                                                                    hasDrafts: drafts.count > 0,
                                                                    drafts: drafts),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/videoSeries/index", context)
            }
        }
    }

    // MARK: - Show

    struct VideoSerieShowContext: Codable {

        let videoSerie: JPFanAppClient.VideoSerie
        let videos: [JPFanAppClient.VideoSerieYoutubeVideo]
        let hasVideoDrafts: Bool
        let videoDrafts: [JPFanAppClient.VideoSerieYoutubeVideo]

    }

    func show(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            return req.client().videoSeriesVideos(id: id).flatMap { videos in
                return req.client().videoSeriesVideosDraft(id: id).flatMap { videoDrafts in
                    let context = DefaultContext(.videoSeries,
                                                 VideoSerieShowContext(videoSerie: videoSerie,
                                                                       videos: videos,
                                                                       hasVideoDrafts: videoDrafts.count > 0,
                                                                       videoDrafts: videoDrafts),
                                                 isAdmin: req.isAdmin(),
                                                 username: req.username())
                    return req.view.render("pages/videoSeries/show", context).encodeResponse(for: req)
                }
            }
        }
    }

    // MARK: - Create

    struct CreateForm: Codable {

        let title: String
        let description: String
        let isPublic: String?

    }

    struct VideoSerieCreateContext: Codable {

        let form: CreateForm

    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let createForm = try req.content.decode(CreateForm.self)
        return req
            .client()
            .videoSeriesCreate(videoSerie: JPFanAppClient.VideoSerie(title: createForm.title,
                                                                     description: createForm.description,
                                                                     isPublic: createForm.isPublic != nil))
            .map
        { newVideoSerie in
            guard let id = newVideoSerie.id else {
                return req.redirect(to: "/videoSeries")
            }
            return req.redirect(to: "/videoSeries/\(id)")
        }
    }

    // MARK: - Update

    struct EditForm: Codable {

        let title: String
        let description: String
        let isPublic: String?

    }

    struct VideoSerieEditContext: Codable {

        let form: EditForm
        let videoSerie: JPFanAppClient.VideoSerie

    }

    func edit(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            let context = DefaultContext(.videoSeries,
                                         VideoSerieEditContext(form: EditForm(title: videoSerie.title,
                                                                              description: videoSerie.description,
                                                                              isPublic: videoSerie.isPublic ? "true" : "false"),
                                                               videoSerie: videoSerie),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/videoSeries/edit", context).encodeResponse(for: req)
        }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        let editForm = try req.content.decode(EditForm.self)

        return req
            .client()
            .videoSeriesPatch(id: id, videoSerie: JPFanAppClient.VideoSerie(title: editForm.title,
                                                                            description: editForm.description,
                                                                            isPublic: editForm.isPublic != nil))
            .map
        { videoSerie in
            guard let id = videoSerie.id else {
                return req.redirect(to: "/videoSeries")
            }
            return req.redirect(to: "/videoSeries/\(id)")
        }
    }

    // MARK: - Delete

    struct VideoSerieDeleteContext: Codable {

        var videoSerie: JPFanAppClient.VideoSerie

    }

    func delete(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            let context = DefaultContext(.videoSeries,
                                         VideoSerieDeleteContext(videoSerie: videoSerie),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/videoSeries/delete", context).encodeResponse(for: req)
        }
    }

    func deletePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesDelete(id: id).map { _ in
            return req.redirect(to: "/videoSeries")
        }
    }

    // MARK: - Publish

    struct VideoSeriePublishContext: Codable {

        var videoSerie: JPFanAppClient.VideoSerie

    }

    func publish(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            let context = DefaultContext(.videoSeries,
                                         VideoSeriePublishContext(videoSerie: videoSerie),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/videoSeries/publish", context).encodeResponse(for: req)
        }
    }

    func publishPOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesPublish(id: id).map { _ in
            return req.redirect(to: "/videoSeries/\(id)")
        }
    }

    // MARK: - Add Video

    struct AddVideoContext: Codable {

        var videoSerie: JPFanAppClient.VideoSerie

    }

    struct AddVideoForm: Codable {

        let videoID: String

    }

    func addVideo(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            let context = DefaultContext(.manufacturers,
                                         AddVideoContext(videoSerie: videoSerie),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/videoSeries/videos/add", context).encodeResponse(for: req)
        }
    }

    func addVideoPOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }

        let form = try req.content.decode(AddVideoForm.self)
        return req.client().videosShow(videoID: form.videoID).flatMap { videos in
            guard let videoID = videos.first?.id else {
                return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)/"))
            }
            return req.client().videoSeriesVideosAdd(id: id, videoID: videoID).flatMap { _ in
                return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)/"))
            }
        }
    }

    // MARK: - Delete Video

    struct VideoSerieDeleteVideoContext: Codable {

        var videoSerie: JPFanAppClient.VideoSerie
        let video: JPFanAppClient.YoutubeVideo

    }

    func deleteVideo(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }
        guard let videoID = req.parameters.get("videoID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            return req.client().videosShow(id: videoID).flatMap { video in
                let context = DefaultContext(.manufacturers,
                                             VideoSerieDeleteVideoContext(videoSerie: videoSerie, video: video),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/videoSeries/videos/delete", context).encodeResponse(for: req)
            }
        }
    }

    func deleteVideoPOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }
        guard let videoID = req.parameters.get("videoID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)"))
        }

        return req.client().videoSeriesVideosRemove(id: id, videoID: videoID).map { _ in
            return req.redirect(to: "/videoSeries/\(id)")
        }
    }

    // MARK: - Publish Video

    struct VideoSeriePublishVideoContext: Codable {

        var videoSerie: JPFanAppClient.VideoSerie
        let video: JPFanAppClient.YoutubeVideo

    }

    func publishVideo(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }
        guard let videoID = req.parameters.get("videoID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)"))
        }

        return req.client().videoSeriesShow(id: id).flatMap { videoSerie in
            return req.client().videosShow(id: videoID).flatMap { video in
                let context = DefaultContext(.manufacturers,
                                             VideoSeriePublishVideoContext(videoSerie: videoSerie, video: video),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/videoSeries/videos/publish", context).encodeResponse(for: req)
            }
        }
    }

    func publishVideoPOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries"))
        }
        guard let videoID = req.parameters.get("videoID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/videoSeries/\(id)"))
        }

        return req.client().videoSeriesVideosPublish(id: id, videoID: videoID).map { _ in
            return req.redirect(to: "/videoSeries/\(id)")
        }
    }

}
