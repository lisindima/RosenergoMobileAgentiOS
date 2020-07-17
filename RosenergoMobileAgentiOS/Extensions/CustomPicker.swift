//
//  CustomPicker.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 17.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct CustomPicker: UIViewRepresentable {
    
    @Binding var selectionIndex: Int?
    
    init<S>(_ title: S, data: [String], selectionIndex: Binding<Int?>) where S: StringProtocol {
        self.placeholder = String(title)
        self.data = data
        self._selectionIndex = selectionIndex
        
        textField = PickerTextField(data: data, selectionIndex: selectionIndex)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CustomPicker>) -> UITextField {
        textField.placeholder = placeholder
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomPicker>) {
        if let index = selectionIndex {
            uiView.text = data[index]
        } else {
            uiView.text = ""
        }
    }
    
    private var placeholder: String
    private var data: [String]
    private let textField: PickerTextField
}

class PickerTextField: UITextField {
    
    var data: [String]
    @Binding var selectionIndex: Int?
    
    init(data: [String], selectionIndex: Binding<Int?>) {
        self.data = data
        self._selectionIndex = selectionIndex
        super.init(frame: .zero)
        
        self.inputView = pickerView
        self.tintColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    @objc
    private func donePressed() {
        self.selectionIndex = self.pickerView.selectedRow(inComponent: 0)
        self.endEditing(true)
    }
}

extension PickerTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectionIndex = row
    }
}
