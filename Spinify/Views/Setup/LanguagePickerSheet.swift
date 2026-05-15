//
//  LanguagePickerSheet.swift
//  Spinify
//
//  Created by Muslim Mirzajonov on 15/05/26.
//

import SwiftUI

struct LanguagePickerSheet: View {
    @ObservedObject var vm: SpinifyViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(L10n.supported, id: \.code) { lang in
                    Button(action: {
                        vm.langCode = lang.code
                        isPresented = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lang.nativeName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(lang.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if vm.langCode == lang.code {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(vm.t("language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
}
