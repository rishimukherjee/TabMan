//
//  TableImageView.swift
//  TabMan
//
//  Created by Rishi Mukherjee on 11/02/16.
//  Copyright © 2016 rishimukherjee. All rights reserved.
//

import UIKit

enum TableOn: Int {
    case Floor = 0
    case PickerContainer = 1
}

class TableImageView: UIImageView, UITextFieldDelegate {

    private var _type: TableType!
    private var idField: UITextField!
    var id: Int? {
        get {
            if let text = idField.text {
                return Int(text) ?? nil
            } else {
                return nil
            }
        }
        set {
            idField.text = newValue == nil ? nil : String(newValue!)
        }
    }

    var onFloor: Bool {
        set {
            idField.hidden = !newValue
        }
        get {
            return !idField.hidden
        }
    }

    var type: TableType {
        set {
            self.image = UIImage(named: newValue.imageName)
            _type = newValue
        }
        get {
            return self._type
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
        createIdTextField()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        createIdTextField()
    }

    convenience init(frame: CGRect, type: TableType) {
        self.init(frame: frame)
        self.type = type
    }

    func createIdTextField() {
        idField = UITextField()
        idField.delegate = self
        idField.backgroundColor = UIColor.clearColor()
        idField.textColor = UIColor.whiteColor()
        idField.tintColor = UIColor.whiteColor()
        idField.textAlignment = .Center
        idField.keyboardType = .NumberPad
        onFloor = true
        addSubview(idField)
    }

    override func layoutSubviews() {
        idField.frame = CGRect(x: 0, y: 0, width: CGRectGetWidth(frame) / 2.5, height: CGRectGetWidth(frame) / 3.5)
        idField.center = CGPoint(x:  CGRectGetWidth(frame) / 2.0, y: CGRectGetHeight(frame) / 2.0)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }

        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 3 // Bool
    }

}