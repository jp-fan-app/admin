//
//  NotFoundMiddleware.swift
//  App
//
//  Created by Christoph Pageler on 25.02.20.
//


import Foundation
import Vapor


final class NotFoundMiddleware: Middleware {

    init() { }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapError { (error) -> EventLoopFuture<Response> in
            if let vaporAbort = error as? Vapor.Abort, vaporAbort.status == .notFound {
                return request.view.render("pages/404",
                                           DefaultContext(.dashboard, NoContext(),
                                                          isAdmin: request.isAdmin()))
                    .encodeResponse(for: request)
            }

            return request.eventLoop.makeFailedFuture(error)
        }
    }

}
