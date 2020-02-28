//
//  Request.swift
//  App
//
//  Created by Christoph Pageler on 25.02.20.
//


import Foundation
import Vapor


extension Request {

    func isAdmin() -> Bool {
        return session.data["isAdmin"] == "true"
    }

    func username() -> String? {
        return session.data["username"]
    }

}
