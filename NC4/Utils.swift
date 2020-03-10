//
//  Utils.swift
//  NC4
//
//  Created by Bruno Pastre on 04/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static func -(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
    }
}


func clamp<T: Comparable>(_ value: T, _ floor: T, _ roof: T) -> T {
    return min(max(value, floor), roof)
}

extension CGSize {
    static func * (_ a: CGSize, _ b: CGFloat) -> CGSize {
        return CGSize(width: a.width * (b), height: a.height * CGFloat(b))
    }
}

extension SKTexture {
    /// https://augmentedcode.io/2017/11/12/drawing-gradients-in-spritekit/
    convenience init(radialGradientWithColors colors: [UIColor], locations: [CGFloat], size: CGSize)
    {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (context) in
            let colorSpace = context.cgContext.colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map({ $0.cgColor }) as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: UnsafePointer<CGFloat>(locations)) else {
                fatalError("Failed creating gradient.")
            }
            
            let radius = max(size.width, size.height) / 2.0
            let midPoint = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
            context.cgContext.drawRadialGradient(gradient, startCenter: midPoint, startRadius: 0, endCenter: midPoint, endRadius: radius, options: [])
        }
        
        self.init(image: image)
    }
    
    
    convenience init(linearGradientWithAngle angleInRadians: CGFloat, colors: [UIColor], locations: [CGFloat], size: CGSize)
    {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (context) in
            let colorSpace = context.cgContext.colorSpace ?? CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map({ $0.cgColor }) as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors, locations: UnsafePointer<CGFloat>(locations)) else {
                fatalError("Failed creating gradient.")
            }
            
            let angles = [angleInRadians + .pi, angleInRadians]
            let radius = (pow(size.width / 2.0, 2.0) + pow(size.height / 2.0, 2.0)).squareRoot()
            let points = angles.map { (angle) -> CGPoint in
                let dx = radius * cos(-angle) + size.width / 2.0
                let dy = radius * sin(-angle) + size.height / 2.0
                return CGPoint(x: dx, y: dy)
            }
            
            context.cgContext.drawLinearGradient(gradient, start: points[0], end: points[1], options: [])
        }
        
        self.init(image: image)
    }
}


// MARK: - Random Bezier Path
func randomBezierPath(_ width: CGFloat, height: CGFloat) -> UIBezierPath {
    // Create a path
    let path = UIBezierPath()
    
    // Starting point
//    path.move(to: offScreenPoint(width, height))
    
    // Random curves
    let numberOfCurves = Int.random(in: 0..<4)
    for _ in 0...numberOfCurves {
//        path.add
        
        path.addArc(withCenter: randomPoint(width, height), radius: .random(in: 5...30), startAngle: .random(in: (-CGFloat.pi / 2)...CGFloat.pi/2), endAngle: .random(in: (-CGFloat.pi / 2)...CGFloat.pi/2), clockwise: .random())
        
    }
    
    // Ending point
//    path.addQuadCurve(to: offScreenPoint(width, height), controlPoint: offScreenPoint(width, height))
    path.close()
    return path
}

// MARK: - Random Point Helpers
func randomPoint(_ width: CGFloat, _ height: CGFloat) -> CGPoint {
    let xPoint = CGFloat.random(in: 0.0..<width)
    let yPoint = CGFloat.random(in: 0.0..<height)
    return CGPoint(x: xPoint, y: yPoint)
}

func offScreenPoint(_ width: CGFloat, _ height: CGFloat) -> CGPoint {
    var xPoint = CGFloat.random(in: 0.0..<width)
    var yPoint = CGFloat.random(in: 0.0..<height)
    
    let midWidth: CGFloat = width / 2.0
    xPoint = xPoint >= midWidth
        ? xPoint + midWidth
        : xPoint - midWidth

    
    let midHeight: CGFloat = height / 2.0
    yPoint = yPoint >= midHeight
        ? yPoint + midHeight
        : yPoint - midHeight
    
    return CGPoint(x: xPoint, y: yPoint)
}


func abs(_ f: CGFloat) -> CGFloat{
    return f * (f < 0 ? -1 : 1)
}
