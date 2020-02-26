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

    struct SignInContext: Codable {

        let invalidLogin: Bool

    }

    struct SignInFlags: Content {

         var invalid_login: Bool?

    }

    func signInGET(_ req: Request) throws -> EventLoopFuture<View> {
        let loginFlags = try? req.query.decode(SignInFlags.self)
        let invalidLogin = loginFlags?.invalid_login ?? false
        return req.view.render("pages/signin", SignInContext(invalidLogin: invalidLogin))
    }

    func signIn(_ req: Request) throws -> EventLoopFuture<Response> {
        let signIn = try req.content.decode(SigninRequest.self)
        return req.client().authLogin(email: signIn.email, password: signIn.password).flatMap { loginResult in
            req.session.data["authToken"] = loginResult.token
            req.session.data["isAdmin"] = loginResult.isAdmin ? "true" : "false"

            let response = req.redirect(to: "/")

            if req.application.environment == .development {
                response.headers.setCookie = HTTPCookies(dictionaryLiteral:
                    ("authToken", HTTPCookies.Value(string: loginResult.token)),
                    ("isAdmin", loginResult.isAdmin ? "true" : "false")
                )
            }

            return req.eventLoop.future(response)
        }
    }

    func signOut(_ req: Request) throws -> Response {
        req.destroySession()
        let response = req.redirect(to: "/dashboard")

        if req.application.environment == .development {
            response.headers.setCookie = HTTPCookies(dictionaryLiteral: ("authToken", ""), ("isAdmin", "false"))
        }

        return response
    }

}
