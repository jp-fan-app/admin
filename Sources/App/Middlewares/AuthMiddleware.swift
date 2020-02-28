//
//  AuthMiddleware.swift
//  App
//
//  Created by Christoph Pageler on 19.02.20.
//


import Foundation
import Vapor


final class AuthMiddleware: Middleware {

    public init() { }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // restore auth token from cookie if in development mode
        if request.application.environment == .development {
            if let authToken = request.headers.cookie["authToken"]?.string, authToken.count > 0 {
                request.session.data["authToken"] = authToken
            }
            if let isAdmin = request.headers.cookie["isAdmin"]?.string, isAdmin.count > 0 {
                request.session.data["isAdmin"] = isAdmin
            }
            if let username = request.headers.cookie["username"]?.string, username.count > 0 {
                request.session.data["username"] = username
            }
        }

        guard request.session.data["authToken"] != nil else {
            return request.eventLoop.future(request.redirect(to: "/signin"))
        }

        return next.respond(to: request)
    }

}
