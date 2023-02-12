//
//  Dropdown.swift
//  Saikou Beta
//
//  Created by Inumaki on 12.02.23.
//

import SwiftUI

struct DropdownOption: Hashable {
    let key: String
    let value: String
    
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}

struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption? = nil
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    private let buttonHeight: CGFloat = 58
    
    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            ZStack {
                HStack {
                    Image(systemName: "folder.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(hex: "#8b8789"))
                        .frame(width: 26)
                        .padding(.leading, 10)
                        .padding(.trailing, 12)
                    
                    Text(selectedOption == nil ? placeholder : selectedOption!.value)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(Color(hex: "#cbc4d1"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(hex: "#8b8789"))
                        .frame(width: 16)
                        .padding(.trailing, 10)
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity, maxHeight: 58)
                
                
            }
        }
        .padding(.horizontal)
        .cornerRadius(5)
        .frame(width: .infinity, height: self.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
        .overlay {
            ZStack {
                Color(.black)
                
                Text("Source")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color(hex: "#8b8789"))
                    .padding(.horizontal, 6)
            }
            .fixedSize()
            .padding(.trailing, 260)
            .padding(.bottom, 58)
        }
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 10)
                    Dropdown(options: self.options, onOptionSelected: { option in
                        shouldShowDropdown = false
                        selectedOption = option
                        self.onOptionSelected?(option)
                    })
                }
            }
            , alignment: .topLeading
        )
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(height: CGFloat(options.count) * 50 + 10)
        .frame(minHeight: CGFloat(options.count) * 50 + 10, maxHeight: 500)
        .padding(.vertical, 5)
        .background(Color(hex: "#1c1b1f"))
        .cornerRadius(5)
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    
    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(hex: "#cbc4d1"))
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
