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

    @Binding var browserZoom: PageZoomLevel
    @Binding var readerZoom: PageZoomLevel

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
                ToggleReaderButton(browserViewModel: browserViewModel)
                ZoomControlGroup(
                    zoomLevel: browserViewModel.showingReader ? $readerZoom : $browserZoom
                )
            } label: {
                Group {
                    if browserViewModel.showingReader {
                        Label {
                            Text("Formatting", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.plaintext")
                                .foregroundStyle(.tint)
                                .padding(.horizontal, 3)
                        }
                    } else {
                        Label {
                            Text("Formatting", comment: "Button label.")
                        } icon: {
                            if browserViewModel.isReaderable {
                                Image(systemName: "doc.plaintext").padding(.horizontal, 3)
                            } else {
                                Image(systemName: "textformat.size")
                            }
                        }
                    }
                }
                .font(.body.weight(.medium))
                .imageScale(.large)
                .padding(4)
                .contentShape(.rect)
            } primaryAction: {
                browserViewModel.toggleReader()
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
