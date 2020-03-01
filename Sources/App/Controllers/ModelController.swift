//
//  ModelController.swift
//  App
//
//  Created by Christoph Pageler on 21.02.20.
//


import Foundation
import Vapor
import JPFanAppClient


final class ModelController {

    // MARK: - Index

    struct ModelIndexContext: Codable {

        let models: [JPFanAppClient.CarModel]
        let hasDrafts: Bool
        let drafts: [JPFanAppClient.CarModel]

    }

    func index(_ req: Request) throws -> EventLoopFuture<View> {
        return req.client().modelsIndex().flatMap { models in
            return req.client().modelsIndexDraft().flatMap { drafts in
                let context = DefaultContext(.models,
                                             ModelIndexContext(models: models,
                                                               hasDrafts: drafts.count > 0,
                                                               drafts: drafts),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/index", context)
            }
        }
    }

    // MARK: - Show

    struct ModelShowContext: Codable {

        struct ModelDetails: Codable {

            let transmissionType: String
            let axleType: String

            static func from(model: JPFanAppClient.CarModel) -> ModelDetails {
                let transmission: String
                switch model.transmissionType {
                case .automatic: transmission = "Automatic"
                case .manual: transmission = "Manual"
                }

                let axleType: String
                switch model.axleType {
                case .all: axleType = "All"
                case .front: axleType = "Front"
                case .rear: axleType = "Rear"
                }

                return ModelDetails(transmissionType: transmission, axleType: axleType)
            }

        }

        let model: JPFanAppClient.CarModel
        let modelDetails: ModelDetails
        let manufacturer: JPFanAppClient.ManufacturerModel
        let stages: [JPFanAppClient.CarStage]
        let hasDraftStages: Bool
        let draftStages: [JPFanAppClient.CarStage]
        let images: [JPFanAppClient.CarImage]
        let hasDraftImages: Bool
        let draftImages: [JPFanAppClient.CarImage]

    }

    func show(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            return req.client().manufacturersShow(id: model.manufacturerID).flatMap { manufacturer in
                return req.client().modelsStages(id: id).flatMap { stages in
                    return req.client().modelsStagesDraft(id: id).flatMap { draftStages in
                        return req.client().modelsImages(id: id).flatMap { images in
                            return req.client().modelsImagesDraft(id: id).flatMap { draftImages in
                                let context = DefaultContext(.models,
                                                             ModelShowContext(model: model,
                                                                              modelDetails: .from(model: model),
                                                                              manufacturer: manufacturer,
                                                                              stages: stages,
                                                                              hasDraftStages: draftStages.count > 0,
                                                                              draftStages: draftStages,
                                                                              images: images,
                                                                              hasDraftImages: draftImages.count > 0,
                                                                              draftImages: draftImages),
                                                             isAdmin: req.isAdmin(),
                                                             username: req.username())
                                return req.view.render("pages/models/show", context).encodeResponse(for: req)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - New

    struct ModelEditForm: Codable {

        let name: String
        var manufacturerID: Int?
        let transmissionType: JPFanAppClient.CarModel.TransmissionType?
        let axleType: JPFanAppClient.CarModel.AxleType?

    }

    struct ModelEditContext: Codable {

        let manufacturers: [JPFanAppClient.ManufacturerModel]
        let model: JPFanAppClient.CarModel?
        let form: ModelEditForm?

    }

    struct ModelNewFlags: Content {

         let manufacturer_id: Int?

    }

    func new(_ req: Request) throws -> EventLoopFuture<Response> {
        let modelNewFlags = try? req.query.decode(ModelNewFlags.self)

        return req.client().allManufacturers().flatMap { manufacturers in
            var form = ModelEditForm(name: "", manufacturerID: nil, transmissionType: nil, axleType: nil)
            if let manufacturerID = modelNewFlags?.manufacturer_id {
                if manufacturers.contains(where: { $0.id == manufacturerID }) {
                    form.manufacturerID = manufacturerID
                }
            }
            let context = DefaultContext(.models,
                                         ModelEditContext(manufacturers: manufacturers, model: nil, form: form),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/new", context).encodeResponse(for: req)
        }
    }

    func create(_ req: Request) throws -> EventLoopFuture<Response> {
        let form = try req.content.decode(ModelEditForm.self)
        if let manufacturerID = form.manufacturerID,
            let transmissionType = form.transmissionType,
            let axleType = form.axleType
        {
            let model = JPFanAppClient.CarModel(name: form.name,
                                                manufacturerID: manufacturerID,
                                                transmissionType: transmissionType,
                                                axleType: axleType,
                                                mainImageID: nil)
            return req.client().modelsCreate(model: model).map { model in
                guard let id = model.id else {
                    return req.redirect(to: "/models")
                }
                return req.redirect(to: "/models/\(id)")
            }
        } else {
            return req.client().allManufacturers().flatMap { manufacturers in
                let context = DefaultContext(.models,
                                             ModelEditContext(manufacturers: manufacturers, model: nil, form: form),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/new", context).encodeResponse(for: req)
            }
        }
    }

    // MARK: - Update

    func edit(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            return req.client().allManufacturers().flatMap { manufacturers in
                let form = ModelEditForm(name: model.name,
                                         manufacturerID: model.manufacturerID,
                                         transmissionType: model.transmissionType,
                                         axleType: model.axleType)
                let context = DefaultContext(.models,
                                             ModelEditContext(manufacturers: manufacturers, model: model, form: form),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/edit", context).encodeResponse(for: req)
            }
        }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        let editForm = try req.content.decode(ModelEditForm.self)

        return req.client().modelsShow(id: id).flatMap { carModel in
            let patchModel = JPFanAppClient.CarModel(name: editForm.name,
                                                     manufacturerID: editForm.manufacturerID ?? carModel.manufacturerID,
                                                     transmissionType: editForm.transmissionType ?? carModel.transmissionType,
                                                     axleType: editForm.axleType ?? carModel.axleType,
                                                     mainImageID: carModel.mainImageID)
            return req.client().modelsPatch(id: id, model: patchModel).map { carModel in
                guard let id = carModel.id else {
                    return req.redirect(to: "/models")
                }
                return req.redirect(to: "/models/\(id)")
            }
        }
    }

    // MARK: - Delete

    struct ModelDeleteContext: Codable {

        let model: JPFanAppClient.CarModel

    }

    func delete(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            let context = DefaultContext(.manufacturers,
                                         ModelDeleteContext(model: model),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/delete", context).encodeResponse(for: req)
        }
    }

    func deletePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsDelete(id: id).map { _ in
            return req.redirect(to: "/models")
        }
    }

    // MARK: - Add Image

    struct AddImageContext: Codable {

        let model: JPFanAppClient.CarModel

    }

    struct AddImageForm: Codable {

        let copyrightInformation: String
        var file: File

    }

    func addImage(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            let context = DefaultContext(.manufacturers,
                                         AddImageContext(model: model),
                                         isAdmin: req.isAdmin(),
                                         username: req.username())
            return req.view.render("pages/models/add-image", context).encodeResponse(for: req)
        }
    }

    func addImagePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        var form = try req.content.decode(AddImageForm.self)
        guard form.file.contentType == .some(.jpeg) else {
            return req.eventLoop.future(req.redirect(to: "/models/\(id)/add-image"))
        }

        let image = JPFanAppClient.CarImage(carModelID: id, copyrightInformation: form.copyrightInformation)
        return req.client().imagesCreate(image: image).flatMap { carImage in
            guard let imageID = carImage.id else {
                return req.eventLoop.future(req.redirect(to: "/models/\(id)/add-image"))
            }
            let data = form.file.data.readData(length: form.file.data.readableBytes) ?? Data()
            return req.client().imagesUpload(id: imageID, imageData: data).flatMap { _ in
                return req.eventLoop.future(req.redirect(to: "/models/\(id)"))
            }
        }
    }

    // MARK: - Upload Image

    struct UploadImageContext: Codable {

        let model: JPFanAppClient.CarModel
        let image: JPFanAppClient.CarImage

    }

    struct UploadImageForm: Codable {

        var file: File

    }

    func uploadImage(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }
        guard let imageID = req.parameters.get("imageID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models/\(id)"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            return req.client().imagesShow(id: imageID).flatMap { carImage in
                let context = DefaultContext(.manufacturers,
                                             UploadImageContext(model: model, image: carImage),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/upload-image", context).encodeResponse(for: req)
            }
        }
    }

    func uploadImagePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }
        guard let imageID = req.parameters.get("imageID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models/\(id)"))
        }

        var form = try req.content.decode(UploadImageForm.self)
        guard form.file.contentType == .some(.jpeg) else {
            return req.eventLoop.future(req.redirect(to: "/models/\(id)/images/\(imageID)/upload-image"))
        }

        let data = form.file.data.readData(length: form.file.data.readableBytes) ?? Data()
        return req.client().imagesUpload(id: imageID, imageData: data).flatMap { _ in
            return req.eventLoop.future(req.redirect(to: "/models/\(id)"))
        }
    }

    // MARK: - Delete Image

    struct ModelDeleteImageContext: Codable {

        let model: JPFanAppClient.CarModel
        let image: JPFanAppClient.CarImage

    }

    func deleteImage(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }
        guard let imageID = req.parameters.get("imageID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models/\(id)"))
        }

        return req.client().modelsShow(id: id).flatMap { model in
            return req.client().imagesShow(id: imageID).flatMap { carImage in
                let context = DefaultContext(.manufacturers,
                                             ModelDeleteImageContext(model: model, image: carImage),
                                             isAdmin: req.isAdmin(),
                                             username: req.username())
                return req.view.render("pages/models/delete-image", context).encodeResponse(for: req)
            }
        }
    }

    func deleteImagePOST(_ req: Request) throws -> EventLoopFuture<Response> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }
        guard let imageID = req.parameters.get("imageID", as: Int.self) else {
            return req.eventLoop.future(req.redirect(to: "/models"))
        }

        return req.client().imagesDelete(id: imageID).map { _ in
            return req.redirect(to: "/models/\(id)")
        }
    }


}
