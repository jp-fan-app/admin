//
//  configure.swift
//  App
//
//  Created by Christoph Pageler on 19.02.20.
//


import Vapor
import Leaf

public func configure(_ app: Application) throws {

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.middleware.use(HTTPErrorMiddleware())
    app.middleware.use(NotFoundMiddleware())

    app.views.use(.leaf)

    try routes(app)
}
