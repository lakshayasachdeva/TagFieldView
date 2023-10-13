//
//  TagView.swift
//  TagFieldView
//
//  Created by Lakshaya Sachdeva on 13/10/23.
//

import SwiftUI

struct TagField: View {
    @Binding var tags: [Tag]
    var body: some View {
        TagLayout(alignment: .leading){
            ForEach($tags) { $tag in
                TagView(tag: $tag, allTags: $tags)
                    .onChange(of: tag.value) { oldValue, newValue in
                        if newValue.last == "," {
                            // removing comma
                            tag.value.removeLast()
                            // inserting new tag
                            if !tag.value.isEmpty {
                                // safe check
                                tags.append(.init(value: ""))
                            }
                        }
                    }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(.bar, in: .rect(cornerRadius: 12))
        .onAppear(perform: {
            if tags.isEmpty {
                tags.append(.init(value: "", isInitial: true))
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
            if let lastTag = tags.last, !lastTag.value.isEmpty {
                // inserting empty tag in list
                tags.append(.init(value: "", isInitial: true))
            }
        })
    }
}

fileprivate struct TagView: View {
    @Binding var tag: Tag
    @Binding var allTags: [Tag]
    @FocusState private var isFocussed: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        
        BackspaceListenerTextField(placeholderText: "Tag", text: $tag.value) {
            if allTags.count > 1 {
                if tag.value.isEmpty {
                    allTags.removeAll (where:{ $0.id == tag.id })
                    if let lastIndex = allTags.indices.last {
                        allTags[lastIndex].isInitial = false
                    }
                }
            }
        }
        .focused($isFocussed)
        .padding(.horizontal, isFocussed || tag.value.isEmpty ? 0 : 10)
        .padding(.vertical, 10)
        .background((colorScheme == .dark ? Color.black : Color.blue).opacity(isFocussed || tag.value.isEmpty ? 0 : 1), in: .rect(cornerRadius: 5))
        .disabled(tag.isInitial)
        .onChange(of: allTags, { oldValue, newValue in
            if newValue.last?.id == tag.id && !(newValue.last?.isInitial ?? false) && !isFocussed {
                isFocussed = true
            }
        })
        .overlay {
            if tag.isInitial {
                Rectangle()
                    .fill(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        // activating only for last tag
                        if tag.id == allTags.last?.id {
                            tag.isInitial = false
                            isFocussed = true
                        }
                    }
            }
        }
        .onChange(of: isFocussed) { _, _ in
            if !isFocussed {
                tag.isInitial = true
            }
        }
    }
}


fileprivate struct BackspaceListenerTextField: UIViewRepresentable {
    var placeholderText: String = "Tag"
    @Binding var text: String
    var onBackPressed: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> CustomTextField {
    
        let textField = CustomTextField()
        textField.onBackPressed = onBackPressed
        textField.delegate = context.coordinator
        textField.placeholder = placeholderText
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .clear
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChange(textField:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CustomTextField, context: Context) -> CGSize? {
        // This will maintain the textfield to take the required space rather than the whole available space
        return uiView.intrinsicContentSize
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }
        // text change
        @objc
        func textChange(textField: UITextField) {
            text = textField.text ?? ""
        }
        
        // closing on return button tap
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
        
        
        
    }
}

fileprivate class CustomTextField: UITextField {
    open var onBackPressed: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        // This will be called whenever keyboard back button pressed
        onBackPressed?()
        super.deleteBackward()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}


#Preview {
    ContentView()
}
