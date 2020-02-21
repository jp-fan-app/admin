//
//  Context.swift
//  App
//
//  Created by Christoph Pageler on 21.02.20.
//


import Foundation
import Vapor


struct DefaultContext<Context: Codable>: Encodable {

    var navigation: NavigationContext
    var context: Context?

    init(_ page: NavigationContext.Page, _ context: Context) {
        self.navigation = NavigationContext(page)
        self.context = context
    }

}

struct NoContext: Codable { }

struct NavigationContext: Encodable {

    var items: [NavigationItem]

    var current: NavigationItem?

    enum Page: String, Encodable {

        case dashboard
        case manufacturers
        case models
        case videos
        case videoSeries
        case devices

    }

    class NavigationItem: Encodable {

        var page: Page
        var title: String
        var isActive: Bool

        init(_ page: Page, title: String) {
            self.page = page
            self.title = title
            self.isActive = false
        }

    }

    init(_ page: Page) {
        items = [
            NavigationItem(.dashboard, title: "Dashboard"),
            NavigationItem(.manufacturers, title: "Manufacturers"),
            NavigationItem(.models, title: "Models"),
            NavigationItem(.videos, title: "Videos"),
            NavigationItem(.videoSeries, title: "Video Series"),
            NavigationItem(.devices, title: "Devices")
        ]
        setup(for: page)
    }

    private mutating func setup(for page: Page?) {
        for navigationItem in items {
            let isActive = page == navigationItem.page
            navigationItem.isActive = isActive
            if isActive {
                self.current = navigationItem
            }
        }
    }

}
