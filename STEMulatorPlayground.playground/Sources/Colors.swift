import UIKit

public struct HSBColor {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
}

public class Colors {

    static let dullerGreen = UIColor(hue:0.333, saturation:0.5, brightness:0.90, alpha:1)
    static let dullerRed = UIColor(hue:1, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerBlue = UIColor(hue:0.666, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerIndigo = UIColor(hue:0.75, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerMagenta = UIColor(hue:0.9, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerYellow = UIColor(hue:0.167, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerOrange = UIColor(hue:0.082, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerLightBlue = UIColor(hue:0.587, saturation:0.5, brightness:0.9, alpha:1)
    static let dullerPurple = UIColor(hue:0.79, saturation:0.5, brightness:0.9, alpha:1)

    static let colors = [dullerGreen, dullerRed, dullerBlue, dullerIndigo, dullerMagenta, dullerYellow, dullerOrange, dullerLightBlue, dullerPurple]

    static public func pickRandomDullerColor() -> CGColor {
        let randomColorIndex = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[randomColorIndex].cgColor
    }

    static public func pickRandomBrighterColor() -> CGColor {
        let dullerVersion = pickRandomDullerColor()
        let dullerHSB = getCurrentHSB(from: dullerVersion)
        return makeBrighterColor(from: dullerHSB)
    }

    static public func getCurrentHSB(from color: CGColor) -> HSBColor {
        let hue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1) // allocate memory for one object
        hue.initialize(to: 0) // initialize with a value of 0
        let saturation = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        saturation.initialize(to: 0)
        let brightness = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        brightness.initialize(to: 0)
        let alpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        alpha.initialize(to: 0)

        UIColor(cgColor: color).getHue(hue, saturation: saturation, brightness: brightness, alpha: alpha)

        let hsbColor = HSBColor(hue: hue.move(), saturation: saturation.move(), brightness: brightness.move(), alpha: alpha.move())
        // move also deinitializes

        hue.deallocate(capacity: 1) // deallocate the memory so that the object can go out of memory
        saturation.deallocate(capacity: 1)
        brightness.deallocate(capacity: 1)
        alpha.deallocate(capacity: 1)

        return hsbColor
    }

    static public func makeBrighterColor(from color: HSBColor) -> CGColor {
        let uiColor = UIColor(hue: color.hue, saturation: 1, brightness: color.brightness, alpha: color.alpha)
        return uiColor.cgColor
    }

    static public func makeDullerColor(from color: HSBColor) -> CGColor {
        let uiColor = UIColor(hue: color.hue, saturation: 0.5, brightness: color.brightness, alpha: color.alpha)
        return uiColor.cgColor
    }
}

