//
//  AdvancedTextField.swift
//  Den
//
//  Created by Garrett Johnson on 6/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//
//  Sourced from the great answer on allowing text selection at https://stackoverflow.com/a/59667107

import SwiftUI

/// This subclass is needed since we want to customize the cursor and the context menu
class CustomUITextField: UITextField, UITextFieldDelegate {

    /// Binding from the `CustomTextField` so changes of the text can be observed by `SwiftUI`
    fileprivate var _textBinding: Binding<String>!

    /// If it is `true` the text field behaves normally.
    /// If it is `false` the text cannot be modified only selected, copied and so on.
    fileprivate var _isEditable = true {
        didSet {
            // set the input view so the keyboard does not show up if it is edited
            self.inputView = self._isEditable ? nil : UIView()
            // do not show autocorrection if it is not editable
            self.autocorrectionType = self._isEditable ? .default : .no
        }
    }


    // change the cursor to have zero size
    override func caretRect(for position: UITextPosition) -> CGRect {
        return self._isEditable ? super.caretRect(for: position) : .zero
    }

    // override this method to customize the displayed items of 'UIMenuController' (the context menu when selecting text)
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        // disable 'cut', 'delete', 'paste','_promptForReplace:'
        // if it is not editable
        if (!_isEditable) {
            switch action {
            case #selector(cut(_:)),
                 #selector(delete(_:)),
                 #selector(paste(_:)):
                return false
            default:
                // do not show 'Replace...' which can also replace text
                // Note: This selector is private and may change
                if (action == Selector("_promptForReplace:")) {
                    return false
                }
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }


    // === UITextFieldDelegate methods

    func textFieldDidChangeSelection(_ textField: UITextField) {
        // update the text of the binding
        self._textBinding.wrappedValue = textField.text ?? ""
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow changing the text depending on `self._isEditable`
        return self._isEditable
    }

}

struct AdvancedTextField: UIViewRepresentable {

    @Binding private var text: String
    private var isEditable: Bool
    private var textAlignment: NSTextAlignment

    init(text: Binding<String>, isEditable: Bool = true, textAlignment: NSTextAlignment = .left) {
        self._text = text
        self.isEditable = isEditable
        self.textAlignment = textAlignment
    }

    func makeUIView(context: UIViewRepresentableContext<AdvancedTextField>) -> CustomUITextField {
        let textField = CustomUITextField(frame: .zero)
        textField.delegate = textField
        textField.text = self.text
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return textField
    }

    func updateUIView(_ uiView: CustomUITextField, context: UIViewRepresentableContext<AdvancedTextField>) {
        uiView.text = self.text
        uiView._textBinding = self.$text
        uiView._isEditable = self.isEditable
        uiView.textAlignment = self.textAlignment
    }

    func isEditable(editable: Bool) -> AdvancedTextField {
        return AdvancedTextField(text: self.$text, isEditable: editable)
    }
}

struct SelectableText: UIViewRepresentable {

    private var text: String
    private var selectable: Bool
    private var textAlignment: NSTextAlignment

    init(_ text: String, selectable: Bool = true, textAlignment: NSTextAlignment = .left) {
        self.text = text
        self.selectable = selectable
        self.textAlignment = textAlignment
    }

    func makeUIView(context: Context) -> CustomUITextField {
        let textField = CustomUITextField(frame: .zero)
        textField.delegate = textField
        textField.text = self.text
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: CustomUITextField, context: Context) {
        uiView.text = self.text
        uiView._textBinding = .constant(self.text)
        uiView._isEditable = false
        uiView.isEnabled = self.selectable
        uiView.textAlignment = self.textAlignment
    }

    func selectable(_ selectable: Bool) -> SelectableText {
        return SelectableText(self.text, selectable: selectable)
    }

}
