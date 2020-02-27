//
//  Context.swift
//  App
//
//  Created by Christoph Pageler on 21.02.20.
//


import Foundation
import Vapor


struct DefaultContext<Context: Codable>: Encodable {

    let navigation: NavigationContext
    let context: Context?
    let isAdmin: Bool

    init(_ page: NavigationContext.Page?, _ context: Context, isAdmin: Bool) {
        self.navigation = NavigationContext(page, isAdmin: isAdmin)
        self.context = context
        self.isAdmin = isAdmin
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
        case users

    }

    class NavigationItem: Encodable {

        let page: Page
        let title: String
        var isActive: Bool
        let svg: SVG

        struct SVG: Codable {

            let viewBox: String
            let elementsString: String

        }

        init(_ page: Page, title: String, svg: SVG) {
            self.page = page
            self.title = title
            self.isActive = false
            self.svg = svg
        }

    }

    init(_ page: Page?, isAdmin: Bool) {
        let homeSVG = NavigationItem.SVG(viewBox: "0 0 24 24", elementsString: """
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline>
        """)
        let youtubeSVG = NavigationItem.SVG(viewBox: "0 0 576 512", elementsString: """
        <path fill="currentColor" d="M549.655 124.083c-6.281-23.65-24.787-42.276-48.284-48.597C458.781 64 288 64 288 64S117.22 64 74.629 75.486c-23.497 6.322-42.003 24.947-48.284 48.597-11.412 42.867-11.412 132.305-11.412 132.305s0 89.438 11.412 132.305c6.281 23.65 24.787 41.5 48.284 47.821C117.22 448 288 448 288 448s170.78 0 213.371-11.486c23.497-6.321 42.003-24.171 48.284-47.821 11.412-42.867 11.412-132.305 11.412-132.305s0-89.438-11.412-132.305zm-317.51 213.508V175.185l142.739 81.205-142.739 81.201z"></path>
        """)
        let phoneSVG = NavigationItem.SVG(viewBox: "0 0 320 512", elementsString: """
        <path fill="currentColor" d="M272 0H48C21.5 0 0 21.5 0 48v416c0 26.5 21.5 48 48 48h224c26.5 0 48-21.5 48-48V48c0-26.5-21.5-48-48-48zM160 480c-17.7 0-32-14.3-32-32s14.3-32 32-32 32 14.3 32 32-14.3 32-32 32zm112-108c0 6.6-5.4 12-12 12H60c-6.6 0-12-5.4-12-12V60c0-6.6 5.4-12 12-12h200c6.6 0 12 5.4 12 12v312z" class=""></path>
        """)
        let listSVG = NavigationItem.SVG(viewBox: "0 0 512 512", elementsString: """
        <path fill="currentColor" d="M464 32H48C21.49 32 0 53.49 0 80v352c0 26.51 21.49 48 48 48h416c26.51 0 48-21.49 48-48V80c0-26.51-21.49-48-48-48zm-6 400H54a6 6 0 0 1-6-6V86a6 6 0 0 1 6-6h404a6 6 0 0 1 6 6v340a6 6 0 0 1-6 6zm-42-92v24c0 6.627-5.373 12-12 12H204c-6.627 0-12-5.373-12-12v-24c0-6.627 5.373-12 12-12h200c6.627 0 12 5.373 12 12zm0-96v24c0 6.627-5.373 12-12 12H204c-6.627 0-12-5.373-12-12v-24c0-6.627 5.373-12 12-12h200c6.627 0 12 5.373 12 12zm0-96v24c0 6.627-5.373 12-12 12H204c-6.627 0-12-5.373-12-12v-24c0-6.627 5.373-12 12-12h200c6.627 0 12 5.373 12 12zm-252 12c0 19.882-16.118 36-36 36s-36-16.118-36-36 16.118-36 36-36 36 16.118 36 36zm0 96c0 19.882-16.118 36-36 36s-36-16.118-36-36 16.118-36 36-36 36 16.118 36 36zm0 96c0 19.882-16.118 36-36 36s-36-16.118-36-36 16.118-36 36-36 36 16.118 36 36z" class=""></path>
        """)
        let industryIcon = NavigationItem.SVG(viewBox: "0 0 512 512", elementsString: """
        <path fill="currentColor" d="M475.115 163.781L336 252.309v-68.28c0-18.916-20.931-30.399-36.885-20.248L160 252.309V56c0-13.255-10.745-24-24-24H24C10.745 32 0 42.745 0 56v400c0 13.255 10.745 24 24 24h464c13.255 0 24-10.745 24-24V184.029c0-18.917-20.931-30.399-36.885-20.248z" class=""></path>
        """)
        let carIcon = NavigationItem.SVG(viewBox: "0 0 640 512", elementsString: """
        <path fill="currentColor" d="M544 192h-16L419.22 56.02A64.025 64.025 0 0 0 369.24 32H155.33c-26.17 0-49.7 15.93-59.42 40.23L48 194.26C20.44 201.4 0 226.21 0 256v112c0 8.84 7.16 16 16 16h48c0 53.02 42.98 96 96 96s96-42.98 96-96h128c0 53.02 42.98 96 96 96s96-42.98 96-96h48c8.84 0 16-7.16 16-16v-80c0-53.02-42.98-96-96-96zM160 432c-26.47 0-48-21.53-48-48s21.53-48 48-48 48 21.53 48 48-21.53 48-48 48zm72-240H116.93l38.4-96H232v96zm48 0V96h89.24l76.8 96H280zm200 240c-26.47 0-48-21.53-48-48s21.53-48 48-48 48 21.53 48 48-21.53 48-48 48z" class=""></path>
        """)
        let userIcon = NavigationItem.SVG(viewBox: "0 0 640 512", elementsString: """
        <path fill="currentColor" d="M192 256c61.9 0 112-50.1 112-112S253.9 32 192 32 80 82.1 80 144s50.1 112 112 112zm76.8 32h-8.3c-20.8 10-43.9 16-68.5 16s-47.6-6-68.5-16h-8.3C51.6 288 0 339.6 0 403.2V432c0 26.5 21.5 48 48 48h288c26.5 0 48-21.5 48-48v-28.8c0-63.6-51.6-115.2-115.2-115.2zM480 256c53 0 96-43 96-96s-43-96-96-96-96 43-96 96 43 96 96 96zm48 32h-3.8c-13.9 4.8-28.6 8-44.2 8s-30.3-3.2-44.2-8H432c-20.4 0-39.2 5.9-55.7 15.4 24.4 26.3 39.7 61.2 39.7 99.8v38.4c0 2.2-.5 4.3-.6 6.4H592c26.5 0 48-21.5 48-48 0-61.9-50.1-112-112-112z" class=""></path>
        """)
        items = [
            NavigationItem(.dashboard, title: "Dashboard", svg: homeSVG),
            NavigationItem(.manufacturers, title: "Manufacturers", svg: industryIcon),
            NavigationItem(.models, title: "Models", svg: carIcon),
            NavigationItem(.videos, title: "Videos", svg: youtubeSVG),
            NavigationItem(.videoSeries, title: "Video Series", svg: listSVG),
        ]
        if isAdmin {
            items.append(NavigationItem(.devices, title: "Devices", svg: phoneSVG))
            items.append(NavigationItem(.users, title: "Users", svg: userIcon))
        }
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
