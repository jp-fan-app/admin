//
//  AuthController.swift
//  App
//
//  Created by Christoph Pageler on 20.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class AuthController {

    struct SigninRequest: Content {

        let email: String
        let password: String

    }

    func signIn(_ req: Request) throws -> EventLoopFuture<Response> {
        let signIn = try req.content.decode(SigninRequest.self)
        return req.client().authLogin(email: signIn.email, password: signIn.password).flatMap { loginResult in
            req.session.data["authToken"] = loginResult.token

            let response = req.redirect(to: "/")

            if req.application.environment == .development {
                response.headers.setCookie = HTTPCookies(dictionaryLiteral: (
                    "authToken", HTTPCookies.Value(string: loginResult.token)
                    )
                )
            }

            return req.eventLoop.future(response)
        }
    }

    func signOut(_ req: Request) throws -> Response {
        req.destroySession()
        let response = req.redirect(to: "/dashboard")

        if req.application.environment == .development {
            response.headers.setCookie = HTTPCookies(dictionaryLiteral: ("authToken", ""))
        }

        return response
    }

}
