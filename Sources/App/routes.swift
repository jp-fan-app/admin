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

    app.get("signin", use: { $0.view.render("pages/signin") })
    app.post("signin", use: AuthController().signIn)

    app.group(authMiddleware) { router in

        router.get("dashboard", use: { $0.view.render("pages/dashboard", DefaultContext(.dashboard, NoContext())) })

        let manufacturerController = ManufacturerController()
        router.get("manufacturers", use: manufacturerController.index)
        router.get("manufacturers", ":id", use: manufacturerController.show)

        let modelController = ModelController()
        router.get("models", use: modelController.index)
        router.get("models", ":id", use: modelController.show)

        router.get("videos", use: { $0.view.render("pages/videos", DefaultContext(.videos, NoContext())) })
        router.get("videoSeries", use: { $0.view.render("pages/videoSeries", DefaultContext(.videoSeries, NoContext())) })
        router.get("devices", use: { $0.view.render("pages/devices", DefaultContext(.devices, NoContext())) })

        router.get("signout", use: AuthController().signOut)

    }

}
