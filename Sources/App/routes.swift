//
//  routes.swift
//  App
//
//  Created by Christoph Pageler on 19.02.20.
//


import Vapor
import Leaf


func routes(_ app: Application) throws {

    let authMiddleware = AuthMiddleware()

    app.get { $0.redirect(to: "/dashboard") }

    app.get("signin", use: AuthController().signInGET)
    app.post("signin", use: AuthController().signIn)

    app.group(authMiddleware) { router in

        let defaultController = DefaultController()

        router.get("dashboard", use: { try defaultController.view($0, view: "pages/dashboard", page: .dashboard) })

        let manufacturerController = ManufacturerController()
        router.get("manufacturers", use: manufacturerController.index)
        router.get("manufacturers", ":id", use: manufacturerController.show)
        router.get("manufacturers", "new", use: { try defaultController.view($0, view: "pages/manufacturers/new", page: .manufacturers) })
        router.post("manufacturers", "new", use: manufacturerController.create)

        let modelController = ModelController()
        router.get("models", use: modelController.index)
        router.get("models", ":id", use: modelController.show)

        router.get("videos", use: { try defaultController.view($0, view: "pages/videos", page: .videos) })
        router.get("videoSeries", use: { try defaultController.view($0, view: "pages/videoSeries", page: .videoSeries) })
        router.get("devices", use: { try defaultController.view($0, view: "pages/devices", page: .devices) })

        let userController = UserController()
        router.get("users", use: userController.index)
        router.get("users", ":id", use: userController.show)
        router.get("users", "new", use: { try defaultController.view($0, view: "pages/users/new", page: .users) })
        router.post("users", "new", use: userController.create)
        router.get("users", ":id", "edit", use: userController.edit)
        router.post("users", ":id", "edit", use: userController.update)
        router.get("users", ":id", "change-password", use: userController.changePasswordGET)
        router.post("users", ":id", "change-password", use: userController.changePasswordPOST)


        router.get("signout", use: AuthController().signOut)

    }

}
