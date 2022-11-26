//
//  CountriesModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

struct CountriesModel {
    static var countriesList: [Country] = [Country(name: "us"),
                                           Country(name: "de"),
                                           Country(name: "it"),
                                           Country(name: "fr"),
                                           Country(name: "ro"),
                                           Country(name: "ua"),
                                           Country(name: "lt"),
                                           Country(name: "lv"),
                                           Country(name: "in"),
                                           Country(name: "bg"),
                                           Country(name: "au"),
                                           Country(name: "at"),
                                           Country(name: "ch")
    ]
}

struct Country {
    let name: String?
    var isSelected: Bool? = false
}
