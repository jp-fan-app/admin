//
//  DefaultController.swift
//  App
//
//  Created by Christoph Pageler on 25.02.20.
//


import Foundation
import Vapor


final class DefaultController {

    func view(_ req: Request, view: String, page: NavigationContext.Page) throws -> EventLoopFuture<View> {
        req.view.render(view, DefaultContext(page, NoContext(), isAdmin: req.isAdmin(), username: req.username()))
    }

}
