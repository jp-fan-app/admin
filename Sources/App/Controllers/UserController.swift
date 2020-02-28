//
//  UserController.swift
//  App
//
//  Created by Christoph Pageler on 25.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class UserController {

    struct UserIndexContext: Codable {

        var users: [JPFanAppClient.User]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().usersIndex().flatMap { users in
            let context = DefaultContext(.users,
                                         UserIndexContext(users: users),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/users/index", context)
        }
    }

    // MARK: - Show

    struct UserShowContext: Codable {

        let user: JPFanAppClient.User
        let tokens: [JPFanAppClient.UserToken]

    }

    func show(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/users"))
        }

        return req.client().usersShow(id: id).flatMap { user in
            return req.client().usersShowTokens(id: id).flatMap { tokens in
                let context = DefaultContext(.users,
                                             UserShowContext(user: user,
                                                             tokens: tokens),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/users/show", context).encodeResponse(for: req)
            }
        }
    }

    // MARK: - Create

    struct CreateForm: Codable {

        let name: String
        let email: String
        let password: String
        let isAdmin: String?

    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let createForm = try req.content.decode(CreateForm.self)
        return req
            .client()
            .usersCreate(user: JPFanAppClient.EditUser.forCreate(name: createForm.name,
                                                                 email: createForm.email,
                                                                 password: createForm.password,
                                                                 isAdmin: createForm.isAdmin != nil))
            .map
        { newUser in    
            return req.redirect(to: "/users/\(newUser.id)")
        }
    }

    // MARK: - Update

    struct EditForm: Codable {

        let name: String
        let email: String
        let isAdmin: String?

    }

    struct UserEditContext: Codable {

        let user: JPFanAppClient.User
        let form: EditForm

    }

    func edit(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/users"))
        }

        return req.client().usersShow(id: id).flatMap { user in
            let context = UserEditContext(user: user,
                                          form: UserController.EditForm(name: user.name,
                                                                        email: user.email,
                                                                        isAdmin: user.isAdmin ? "checked" : nil))
            return req.view.render("pages/users/edit",
                                   DefaultContext(.users,
                                                  context,
                                                  isAdmin: req.isAdmin(),
                                                  username: req.username()))
                .encodeResponse(for: req)
        }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/users"))
        }

        let editForm = try req.content.decode(EditForm.self)
        let editUser = JPFanAppClient.EditUser.forPatch(name: editForm.name,
                                                        email: editForm.email,
                                                        isAdmin: editForm.isAdmin != nil )

        return req.client().usersPatch(id: id, user: editUser).map { user in
            return req.redirect(to: "/users/\(user.id)")
        }
    }

    // MARK: - Change Password

    struct ChangePasswordForm: Codable {

        let password: String

    }

    struct ChangePasswordContext: Codable {

        let user: JPFanAppClient.User
        let form: ChangePasswordForm

    }

    func changePasswordGET(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/users"))
        }

        return req.client().usersShow(id: id).flatMap { user in
            let context = ChangePasswordContext(user: user, form: UserController.ChangePasswordForm(password: ""))
            return req.view.render("pages/users/change-password",
                                   DefaultContext(.users,
                                                  context,
                                                  isAdmin: req.isAdmin(),
                                                  username: req.username()))
                .encodeResponse(for: req)
        }
    }

    func changePasswordPOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/users"))
        }

        let form = try req.content.decode(ChangePasswordForm.self)
        return req.client().usersChangePassword(id: id, newPassword: form.password).map { user in
            return req.redirect(to: "/users/\(user.id)")
        }
    }

}
