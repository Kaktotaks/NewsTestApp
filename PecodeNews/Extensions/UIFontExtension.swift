//
//  UIFontExtension.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

extension UIFont {
    public enum FontType {
        enum RobotoType: String {
            case regular = "Regular"
            case medium = "Medium"
            case bold = "Bold"
            case light = "Light"
            case thin = "Thin"
        }

        enum GuardianType: String {
            case medium = "Medium"
            case bold = "Bold"
            case semibold = "Semibold"
        }
    }

    static func makeRoboto(
        _ type: FontType.RobotoType = .regular,
        size: CGFloat = UIFont.systemFontSize
    ) -> UIFont {
        UIFont(name: "Roboto-\(type.rawValue)", size: size) ?? .init()
    }

    static func makeGuardian(
        _ type: FontType.GuardianType = .medium,
        size: CGFloat = UIFont.systemFontSize
    ) -> UIFont {
        UIFont(name: "GHGuardianHeadline-\(type.rawValue)", size: size) ?? .init()
    }
}
