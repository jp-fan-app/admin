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
    let adminMiddleware = AdminMiddleware()

    app.get { $0.redirect(to: "/dashboard") }

    app.get("signin", use: AuthController().signInGET)
    app.post("signin", use: AuthController().signIn)

    app.group(authMiddleware) { router in

        let admin = router.grouped(adminMiddleware)

        let defaultController = DefaultController()

        router.get("dashboard", use: DashboardController().index)

        let manufacturerController = ManufacturerController()
        router.get("manufacturers", use: manufacturerController.index)
        router.get("manufacturers", ":id", use: manufacturerController.show)
        router.get("manufacturers", "new", use: { try defaultController.view($0, view: "pages/manufacturers/new", page: .manufacturers) })
        router.post("manufacturers", "new", use: manufacturerController.create)
        admin.get("manufacturers", ":id", "edit", use: manufacturerController.edit)
        admin.post("manufacturers", ":id", "edit", use: manufacturerController.update)
        admin.get("manufacturers", ":id", "delete", use: manufacturerController.delete)
        admin.post("manufacturers", ":id", "delete", use: manufacturerController.deletePOST)

        let modelController = ModelController()
        router.get("models", use: modelController.index)
        router.get("models", ":id", use: modelController.show)
        router.get("models", "new", use: modelController.new)
        router.post("models", "new", use: modelController.create)
        admin.get("models", ":id", "edit", use: modelController.edit)
        admin.post("models", ":id", "edit", use: modelController.update)
        admin.get("models", ":id", "delete", use: modelController.delete)
        admin.post("models", ":id", "delete", use: modelController.deletePOST)

        router.get("videos", use: { try defaultController.view($0, view: "pages/videos", page: .videos) })

        let videoSeriesController = VideoSeriesController()
        router.get("videoSeries", use: videoSeriesController.index)
        router.get("videoSeries", ":id", use: videoSeriesController.show)
        router.get("videoSeries", "new", use: { try defaultController.view($0, view: "pages/videoSeries/new", page: .videoSeries) })
        router.post("videoSeries", "new", use: videoSeriesController.create)
        admin.get("videoSeries", ":id", "edit", use: videoSeriesController.edit)
        admin.post("videoSeries", ":id", "edit", use: videoSeriesController.update)
        admin.get("videoSeries", ":id", "delete", use: videoSeriesController.delete)
        admin.post("videoSeries", ":id", "delete", use: videoSeriesController.deletePOST)

        admin.get("devices", use: { try defaultController.view($0, view: "pages/devices", page: .devices) })

        let userController = UserController()
        admin.get("users", use: userController.index)
        admin.get("users", ":id", use: userController.show)
        admin.get("users", "new", use: { try defaultController.view($0, view: "pages/users/new", page: .users) })
        admin.post("users", "new", use: userController.create)
        admin.get("users", ":id", "edit", use: userController.edit)
        admin.post("users", ":id", "edit", use: userController.update)
        admin.get("users", ":id", "change-password", use: userController.changePasswordGET)
        admin.post("users", ":id", "change-password", use: userController.changePasswordPOST)


        router.get("signout", use: AuthController().signOut)

    }

}
