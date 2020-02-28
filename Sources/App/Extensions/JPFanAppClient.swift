//
//  JPFanAppClient.swift
//  App
//
//  Created by Christoph Pageler on 28.02.20.
//


import Foundation
import JPFanAppClient
import NIO


extension JPFanAppClient {

    func allManufacturers() -> EventLoopFuture<[ManufacturerModel]> {
        return manufacturersIndex().and(manufacturersIndexDraft()).map { $0.0 + $0.1 }
    }

    func allModels() -> EventLoopFuture<[CarModel]> {
        return modelsIndex().and(modelsIndexDraft()).map { $0.0 + $0.1 }
    }

    func allImages() -> EventLoopFuture<[CarImage]> {
        return imagesIndex().and(imagesIndexDraft()).map { $0.0 + $0.1 }
    }

    func allStages() -> EventLoopFuture<[CarStage]> {
        return stagesIndex().and(stagesIndexDraft()).map { $0.0 + $0.1 }
    }

    func allTimings() -> EventLoopFuture<[StageTiming]> {
        return timingsIndex().and(timingsIndexDraft()).map { $0.0 + $0.1 }
    }

}
