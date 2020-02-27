//
//  AdminMiddleware.swift
//  App
//
//  Created by Christoph Pageler on 27.02.20.
//


import Foundation
import Vapor


final class AdminMiddleware: Middleware {

    public init() { }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let isAdmin = request.session.data["isAdmin"], isAdmin == "true" else {
            return request.view.render("pages/404",
                                       DefaultContext(nil,
                                                      NoContext(),
                                                      isAdmin: false)).encodeResponse(for: request)
        }

        return next.respond(to: request)
    }

}
