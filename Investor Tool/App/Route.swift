//
//  Route.swift
//  Investor Tool
//
//  Navigation route definitions
//

import Foundation

enum Route: Hashable {
    case home
    case settings
    case tickerDetail(String)
    case tickerSearch
    case assumptions
    case forecast
}
