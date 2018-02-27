//
//  ViewController.swift
//  custom progress bar
//
//  Created by Mengying Feng on 25/2/18.
//  Copyright © 2018 Emily Fung. All rights reserved.
//

import UIKit

protocol ProgressBarViewDelegate {
    func didDrag(at point: CGPoint)
}

class ProgressBarView: UIView {
    
    var delegate: ProgressBarViewDelegate?
    var drag: UIPanGestureRecognizer!
    
    /// progress: 0...10
    private var _progress: CGFloat = 0.0
    var progress: CGFloat {
        set (new) {
            if new < 0 {
                _progress = 0
                setNeedsDisplay()
            } else if new > 10 {
                _progress = 10
                setNeedsDisplay()
            } else {
                let old = _progress
                _progress = new
                if Int(new) != Int(old) {
                    setNeedsDisplay()
                }
            }
        }
        get {
            return _progress
        }
    }
    
    override func draw(_ rect: CGRect) {
        ProgressBar.drawProgressBar(frame: frame, progress: progress)
        if drag == nil {
            drag = UIPanGestureRecognizer(target: self, action: #selector(thumbDragged(sender:)))
            drag.maximumNumberOfTouches = 1
            self.addGestureRecognizer(drag)
        }
    }
    
    @objc func thumbDragged(sender: UIPanGestureRecognizer) {
        delegate?.didDrag(at: sender.translation(in: self))
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
}

class ProgressBar: NSObject {
    
    var thumb: UIBezierPath?
    
    public class func drawProgressBar(frame: CGRect/* = CGRect(x: 6, y: 22, width: 377, height: 22)*/, progress: CGFloat = 90) {
        /// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { return print("The current graphics context is nil") }
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        /// Color Declarations
        let color = UIColor.white
        let color2 = UIColor(red: 0.737, green: 0.596, blue: 0.400, alpha: 1.000)
        let color3 = UIColor(red: 0.847, green: 0.847, blue: 0.847, alpha: 1.000)
        let fillColor3 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let textForeground = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let fillColor2 = UIColor(red: 0.737, green: 0.596, blue: 0.400, alpha: 1.000)
        let shadowTint = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let color4 = UIColor(red: 0.408, green: 0.408, blue: 0.408, alpha: 1.000)
        
        /// Shadow Declarations
        let shadow = NSShadow()
        shadow.shadowColor = shadowTint.withAlphaComponent(0.5 * shadowTint.cgColor.alpha)
        shadow.shadowOffset = CGSize(width: 74, height: 2)
        shadow.shadowBlurRadius = 4
        
        /// Variable Declarations
        let progressOutlineWidth: CGFloat = 6
        let progressBarX: CGFloat = 10
        let inactiveBarWidth = frame.width - progressOutlineWidth - progressBarX * 2
        let progressPathHeight: CGFloat = 16
        let progressPathRadius = progressPathHeight / 2
        let labelTextFontSize: CGFloat = 16
        let labelHeight: CGFloat = 15
        let labelWidth: CGFloat = 21
        let labelTextY: CGFloat = 36
        let startTextX: CGFloat = 13
        let shadowClipPathSize: CGFloat = 37
        let ovalPathSize: CGFloat = 29
        let shadowOvalX: CGFloat = -70
        let ovalY: CGFloat = 2
        let thumbLabelX: CGFloat = 8
        let thumbLabelY: CGFloat = 5
        let thumbLabelHeight: CGFloat = 23
        let thumbOvalX: CGFloat = 4
        let thumbX: CGFloat = progress / 10 * (inactiveBarWidth - progressBarX)
        let thumbTextValue: String = "\(Int(frame.width * progress / (frame.width - progressOutlineWidth - progressBarX)))"
        let activeProgress: CGFloat = progress / 10 * inactiveBarWidth
        
        /// Progress Inactive Drawing
        let progressInactivePath = UIBezierPath(roundedRect: CGRect(x: progressBarX, y: progressBarX, width: inactiveBarWidth, height: progressPathHeight), cornerRadius: progressPathRadius)
        color3.setFill()
        progressInactivePath.fill()
        
        /// Progress Active Drawing
        let progressActivePath = UIBezierPath(roundedRect: CGRect(x: progressBarX, y: progressBarX, width: activeProgress, height: progressPathHeight), cornerRadius: progressPathRadius)
        color2.setFill()
        progressActivePath.fill()
        
        /// Progress Outline Drawing
        let progressOutlinePath = UIBezierPath(roundedRect: CGRect(x: progressBarX, y: progressBarX, width: inactiveBarWidth, height: progressPathHeight), cornerRadius: progressPathRadius)
        color.setStroke()
        progressOutlinePath.lineWidth = progressOutlineWidth
        progressOutlinePath.stroke()
        
        /// Start Text Drawing
        let startTextRect = CGRect(x: startTextX, y: labelTextY, width: labelWidth, height: labelHeight)
        let startTextTextContent = "0"
        let startTextStyle = NSMutableParagraphStyle()
        startTextStyle.alignment = .left
        let startTextFontAttributes = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: labelTextFontSize)!,
            NSAttributedStringKey.foregroundColor: color4,
            NSAttributedStringKey.paragraphStyle: startTextStyle
        ]
        
        let startTextTextHeight: CGFloat = startTextTextContent.boundingRect(with: CGSize(width: startTextRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: startTextFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: startTextRect)
        startTextTextContent.draw(in: CGRect(x: startTextRect.minX, y: startTextRect.minY + (startTextRect.height - startTextTextHeight) / 2, width: startTextRect.width, height: startTextTextHeight), withAttributes: startTextFontAttributes)
        context.restoreGState()
        
        
        /// End Text Drawing
        let endTextRect = CGRect(x: inactiveBarWidth - progressBarX, y: labelTextY, width: labelWidth, height: labelHeight)
        let endTextTextContent = "10"
        let endTextStyle = NSMutableParagraphStyle()
        endTextStyle.alignment = .right
        let endTextFontAttributes = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: labelTextFontSize)!,
            NSAttributedStringKey.foregroundColor: color4,
            NSAttributedStringKey.paragraphStyle: endTextStyle
        ]
        
        let endTextTextHeight: CGFloat = endTextTextContent.boundingRect(with: CGSize(width: endTextRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: endTextFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: endTextRect)
        endTextTextContent.draw(in: CGRect(x: endTextRect.minX, y: endTextRect.minY + (endTextRect.height - endTextTextHeight) / 2, width: endTextRect.width, height: endTextTextHeight), withAttributes: endTextFontAttributes)
        context.restoreGState()
        
        /// Thumb Group
        context.saveGState()
        context.translateBy(x: thumbX, y: 0)
        
        /// Thumb
        /// Shadow Group
        context.saveGState()
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        /// Clip Shadow Clip
        let clipPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: shadowClipPathSize, height: shadowClipPathSize))
        clipPath.addClip()
        
        /// Shadow Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: shadowOvalX, y: ovalY, width: ovalPathSize, height: ovalPathSize))
        context.saveGState()
        context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
        fillColor3.setFill()
        ovalPath.fill()
        context.restoreGState()
        
        context.endTransparencyLayer()
        context.restoreGState()
        
        /// Thumb Oval Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: thumbOvalX, y: ovalY, width: ovalPathSize, height: ovalPathSize))
        fillColor2.setFill()
        oval2Path.fill()
        
        /// Label Drawing
        let labelRect = CGRect(x: thumbLabelX, y: thumbLabelY, width: labelWidth, height: thumbLabelHeight)
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center
        let labelFontAttributes = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: labelTextFontSize)!,
            NSAttributedStringKey.foregroundColor: textForeground,
            NSAttributedStringKey.paragraphStyle: labelStyle,
            ]
        
        let labelTextHeight: CGFloat = thumbTextValue.boundingRect(with: CGSize(width: labelRect.width, height: CGFloat.infinity), options: .usesLineFragmentOrigin, attributes: labelFontAttributes, context: nil).height
        context.saveGState()
        context.clip(to: labelRect)
        thumbTextValue.draw(in: CGRect(x: labelRect.minX, y: labelRect.minY + (labelRect.height - labelTextHeight) / 2, width: labelRect.width, height: labelTextHeight), withAttributes: labelFontAttributes)
        context.restoreGState()
    }
}

class ViewController: UIViewController {
    
    var sliderProgress: Int = 0 {
        didSet {
            progressContainerView.progress = CGFloat(sliderProgress)
        }
    }

    @IBOutlet weak var progressContainerView: ProgressBarView!
    
    override func viewDidLoad() {
        progressContainerView.delegate = self
        progressContainerView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sliderProgress = 4
    }
}

extension ViewController: ProgressBarViewDelegate {
    func didDrag(at point: CGPoint) {
        let previousProgress = progressContainerView.progress
        let newProgress = previousProgress + point.x / ((progressContainerView.frame.width - 36)/10) /* some values are constants because they are only relative to the custom progress bar container view */
        if previousProgress != newProgress {
            progressContainerView.progress = newProgress
        }
    }
}
