//
//  BrowserToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    @Environment(\.openURL) private var openURL

    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                dismiss()
            } label: {
                Text("Done", comment: "Button label.")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 4)
            }
        }
        ToolbarItem(placement: .navigation) {
            Button {
                browserViewModel.goBack()
            } label: {
                Label {
                    Text("Go Back", comment: "Button label.")
                } icon: {
                    Image(systemName: "chevron.backward")
                }
                .padding(.horizontal, 3)
            }
            .disabled(!browserViewModel.canGoBack)
        }
        ToolbarItem(placement: .navigation) {
            Button {
                browserViewModel.goForward()
            } label: {
                Label {
                    Text("Go Forward", comment: "Button label.")
                } icon: {
                    Image(systemName: "chevron.forward")
                }
                .padding(.horizontal, 3)
            }
            .disabled(!browserViewModel.canGoForward)
        }
        ToolbarItem(placement: .navigation) {
            Menu {
                if browserViewModel.showingReader {
                    Button {
                        browserViewModel.hideReader()
                    } label: {
                        Label {
                            Text("Hide Reader", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.plaintext")
                        }
                    }
                } else {
                    Button {
                        browserViewModel.showReader()
                    } label: {
                        Label {
                            Text("Show Reader", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.plaintext")
                        }
                    }
                    .disabled(!browserViewModel.isReaderable)
                }
            } label: {
                Label {
                    Text("Formatting", comment: "Button label.")
                } icon: {
                    if browserViewModel.isReaderable {
                        Group {
                            if browserViewModel.showingReader {
                                Image(systemName: "doc.plaintext").foregroundStyle(.tint)
                            } else {
                                Image(systemName: "doc.plaintext")
                            }
                        }
                        .padding(.horizontal, 3)
                    } else {
                        Image(systemName: "textformat.size")
                    }
                }
                .font(.callout.weight(.medium))
                .imageScale(.large)
                .padding(4)
                .contentShape(.rect)
            } primaryAction: {
                if browserViewModel.showingReader {
                    browserViewModel.hideReader()
                } else if browserViewModel.isReaderable {
                    browserViewModel.showReader()
                }
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
        }
        ToolbarItem {
            if browserViewModel.isLoading {
                Button {
                    browserViewModel.stop()
                } label: {
                    Label {
                        Text("Stop Loading", comment: "Button label.")
                    } icon: {
                        Image(systemName: "xmark")
                    }
                }
            } else {
                Button {
                    browserViewModel.reload()
                } label: {
                    Label {
                        Text("Reload", comment: "Button label.")
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        ToolbarItem {
            if let url = browserViewModel.url {
                ShareButton(url: url)
            }
        }
        ToolbarItem {
            if let url = browserViewModel.url {
                Button {
                    openURL(url)
                } label: {
                    OpenInBrowserLabel()
                }
            }
        }
    }
}
