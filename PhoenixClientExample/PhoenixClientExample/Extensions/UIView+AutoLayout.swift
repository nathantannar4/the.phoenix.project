/*
 MIT License
 
 Copyright © 2017 Nathan Tannar.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

public extension UIView {
    
    func fillSuperview(inSafeArea: Bool = false) {
        
        guard let superview = self.superview else {
            print("💥 Could not constraints for \(self), did you add it to the view?")
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        
        if inSafeArea, #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
                rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor),
                topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
                bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                leftAnchor.constraint(equalTo: superview.leftAnchor),
                rightAnchor.constraint(equalTo: superview.rightAnchor),
                topAnchor.constraint(equalTo: superview.topAnchor),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    func anchorAspectRatio() {
        let aspectRatioConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .width,
                                                       multiplier: 1,
                                                       constant: 0)
        
        self.addConstraint(aspectRatioConstraint)
    }
    
    @discardableResult
    func anchor(_ top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        
        guard superview != nil else {
            print("💥 Could not constraints for \(self), did you add it to the view?")
            return []
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            let constraint = topAnchor.constraint(equalTo: top, constant: topConstant)
            constraint.identifier = "top"
            anchors.append(constraint)
        }
        
        if let left = left {
            let constraint = leftAnchor.constraint(equalTo: left, constant: leftConstant)
            constraint.identifier = "left"
            anchors.append(constraint)
        }
        
        if let bottom = bottom {
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant)
            constraint.identifier = "bottom"
            anchors.append(constraint)
        }
        
        if let right = right {
            let constraint = rightAnchor.constraint(equalTo: right, constant: -rightConstant)
            constraint.identifier = "right"
            anchors.append(constraint)
        }
        
        if widthConstant > 0 {
            let constraint = widthAnchor.constraint(equalToConstant: widthConstant)
            constraint.identifier = "width"
            anchors.append(constraint)
        }
        
        if heightConstant > 0 {
            let constraint = heightAnchor.constraint(equalToConstant: heightConstant)
            constraint.identifier = "height"
            anchors.append(constraint)
        }
        
        NSLayoutConstraint.activate(anchors)
        return anchors
    }
    
    @discardableResult
    func anchorAbove(_ view: UIView, top: NSLayoutYAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        return anchor(topAnchor, left: view.leftAnchor, bottom: view.topAnchor, right: view.rightAnchor, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: 0, heightConstant: heightConstant)
    }
    
    @discardableResult
    func anchorBelow(_ view: UIView, bottom: NSLayoutYAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, heightConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        return anchor(view.bottomAnchor, left: view.leftAnchor, bottom: bottom, right: view.rightAnchor, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: 0, heightConstant: heightConstant)
    }
    
    @discardableResult
    func anchorLeftOf(_ view: UIView, left: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        return anchor(view.topAnchor, left: left, bottom: view.bottomAnchor, right: view.leftAnchor, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: 0)
    }
    
    @discardableResult
    func anchorRightOf(_ view: UIView, right: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, leftConstant: CGFloat = 0, bottomConstant: CGFloat = 0, rightConstant: CGFloat = 0, widthConstant: CGFloat = 0) -> [NSLayoutConstraint] {
        return anchor(view.topAnchor, left: view.rightAnchor, bottom: view.bottomAnchor, right: right, topConstant: topConstant, leftConstant: leftConstant, bottomConstant: bottomConstant, rightConstant: rightConstant, widthConstant: widthConstant, heightConstant: 0)
    }
    
    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        
        guard let superview = self.superview else {
            print("💥 Could not constraints for \(self), did you add it to the view?")
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: constant).isActive = true
    }
    
    func anchorCenterYToSuperview(constant: CGFloat = 0) {
        
        guard let superview = self.superview else {
            print("💥 Could not constraints for \(self), did you add it to the view?")
            return
        }
      
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: constant).isActive = true
    }
    
    func anchorCenterToSuperview() {
        anchorCenterYToSuperview()
        anchorCenterXToSuperview()
    }
    
    func constraint(withIdentifier identifier: String) -> NSLayoutConstraint? {
        let constraints = self.constraints.filter { $0.identifier == identifier }
        return constraints.first
    }
    
    func anchorWidthToItem(_ item: UIView) {
        let widthConstraint = widthAnchor.constraint(equalTo: item.widthAnchor, multiplier: 1)
        widthConstraint.isActive = true
    }
    
    func anchorHeightToItem(_ item: UIView) {
        let widthConstraint = heightAnchor.constraint(equalTo: item.heightAnchor, multiplier: 1)
        widthConstraint.isActive = true
    }
    
    func removeAllConstraints() {
        var view: UIView? = self
        while let currentView = view {
            currentView.removeConstraints(currentView.constraints.filter {
                return $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
            })
            view = view?.superview
        }
    }
}
