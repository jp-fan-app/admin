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
        admin.get("manufacturers", ":id", "publish", use: manufacturerController.publish)
        admin.post("manufacturers", ":id", "publish", use: manufacturerController.publishPOST)

        let modelController = ModelController()
        router.get("models", use: modelController.index)
        router.get("models", ":id", use: modelController.show)
        router.get("models", "new", use: modelController.new)
        router.post("models", "new", use: modelController.create)
        admin.get("models", ":id", "edit", use: modelController.edit)
        admin.post("models", ":id", "edit", use: modelController.update)
        admin.get("models", ":id", "delete", use: modelController.delete)
        admin.post("models", ":id", "delete", use: modelController.deletePOST)
        admin.get("models", ":id", "publish", use: modelController.publish)
        admin.post("models", ":id", "publish", use: modelController.publishPOST)
        // Images
        router.get("models", ":id", "add-image", use: modelController.addImage)
        router.post("models", ":id", "add-image", use: modelController.addImagePOST)
        router.get("models", ":id", "images", ":imageID", "upload-image", use: modelController.uploadImage)
        router.post("models", ":id", "images", ":imageID","upload-image", use: modelController.uploadImagePOST)
        admin.get("models", ":id", "images", ":imageID", "delete", use: modelController.deleteImage)
        admin.post("models", ":id", "images", ":imageID", "delete", use: modelController.deleteImagePOST)
        admin.get("models", ":id", "images", ":imageID", "publish", use: modelController.publishImage)
        admin.post("models", ":id", "images", ":imageID", "publish", use: modelController.publishImagePOST)
        // Stages
        router.get("models", ":id", "add-stage", use: modelController.addStage)
        router.post("models", ":id", "add-stage", use: modelController.addStagePOST)
        router.get("models", ":id", "stages", ":stageID", "edit", use: modelController.editStage)
        router.post("models", ":id", "stages", ":stageID", "edit", use: modelController.editStagePOST)
        router.get("models", ":id", "stages", ":stageID", "delete", use: modelController.deleteStage)
        router.post("models", ":id", "stages", ":stageID", "delete", use: modelController.deleteStagePOST)
        router.get("models", ":id", "stages", ":stageID", "publish", use: modelController.publishStage)
        router.post("models", ":id", "stages", ":stageID", "publish", use: modelController.publishStagePOST)

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
        admin.get("videoSeries", ":id", "publish", use: videoSeriesController.publish)
        admin.post("videoSeries", ":id", "publish", use: videoSeriesController.publishPOST)

        let devicesController = DevicesController()
        admin.get("devices", use: devicesController.index)

        let userController = UserController()
        admin.get("users", use: userController.index)
        admin.get("users", ":id", use: userController.show)
        admin.get("users", "new", use: { try defaultController.view($0, view: "pages/users/new", page: .users) })
        admin.post("users", "new", use: userController.create)
        admin.get("users", ":id", "edit", use: userController.edit)
        admin.post("users", ":id", "edit", use: userController.update)
        admin.get("users", ":id", "change-password", use: userController.changePassword)
        admin.post("users", ":id", "change-password", use: userController.changePasswordPOST)
        admin.get("users", ":id", "remove-all-tokens", use: userController.removeAllTokens)
        admin.post("users", ":id", "remove-all-tokens", use: userController.removeAllTokensPOST)
        admin.get("users", ":id", "delete", use: userController.delete)
        admin.post("users", ":id", "delete", use: userController.deletePOST)


        router.get("signout", use: AuthController().signOut)

    }

}
