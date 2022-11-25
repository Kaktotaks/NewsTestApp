//
//  CountriesModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

struct CountriesModel {
    static var countriesList: [Country] = [Country(name: "us", isSelected: true),
                                           Country(name: "de", isSelected: false),
                                           Country(name: "it", isSelected: false),
                                           Country(name: "fr", isSelected: false),
                                           Country(name: "ro", isSelected: false),
                                           Country(name: "ua", isSelected: false),
                                           Country(name: "lt", isSelected: false),
                                           Country(name: "lv", isSelected: false),
                                           Country(name: "in", isSelected: false),
                                           Country(name: "bg", isSelected: false),
                                           Country(name: "au", isSelected: false),
                                           Country(name: "at", isSelected: false),
                                           Country(name: "ch", isSelected: false)
    ]
}

struct Country {
    let name: String?
    var isSelected: Bool
}
