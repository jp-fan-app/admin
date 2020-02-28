//
//  HTTPErrorMiddleware.swift
//  App
//
//  Created by Christoph Pageler on 24.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class HTTPErrorMiddleware: Middleware {

    init() { }

    struct ClientErrorContext: Codable {

        let code: Int

    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let responsePromise = request.eventLoop.makePromise(of: Response.self)

        next.respond(to: request).whenComplete { result in
            switch result {
            case .success(let response):
                responsePromise.succeed(response)
            case .failure(let error):
                if let clientError = error as? JPFanAppClient.ClientError {
                    switch clientError {
                    case .httpError(let code):
                        if code == 401 {
                            if request.url.string.contains("/signin") {
                                responsePromise.succeed(request.redirect(to: "/signin?invalid_login=true"))
                            } else {
                                responsePromise.succeed(request.redirect(to: "/signout"))
                            }
                            return
                        } else {
                            let context = DefaultContext(nil,
                                                         ClientErrorContext(code: Int(code)),
                                                         isAdmin: request.isAdmin(),
                                                         username: request.username())
                            let renderResult = request.view.render("pages/client-error", context).encodeResponse(for: request)

                            renderResult.whenComplete { result in
                                switch result {
                                case .success(let response):
                                    responsePromise.succeed(response)
                                case .failure(let error):
                                    responsePromise.fail(error)
                                }
                            }

                            return
                        }
                    default: break
                    }
                }
                responsePromise.fail(error)
            }
        }

        return responsePromise.futureResult
    }

}
