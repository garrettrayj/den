//
//  IconPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct IconPickerView: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var activeIcon: String

    // swiftlint:disable:next line_length
    let icons: [String] = ["square.grid.2x2", "4k.tv", "a.magnify", "abc", "airplane", "alarm", "alt", "amplifier", "ant", "archivebox", "aspectratio", "at", "atom", "bag", "bandage", "banknote", "barcode", "barcode.viewfinder", "barometer", "bed.double", "bell", "bicycle", "binoculars", "bolt", "bolt.car", "bolt.heart", "bolt.horizontal", "book", "book.closed", "bookmark", "books.vertical", "briefcase", "building", "building.2", "building.columns", "burn", "burst", "bus", "bus.doubledecker", "calendar", "camera", "camera.aperture", "camera.filters", "camera.viewfinder", "candybarphone", "car", "car.2", "cart", "case", "character", "character.book.closed", "chart.bar", "chart.bar.doc.horizontal", "chart.bar.xaxis", "chart.pie", "checkmark", "checkmark.seal", "checkmark.shield", "cloud", "cloud.bolt", "cloud.bolt.rain", "cloud.drizzle", "cloud.fog", "cloud.hail", "cloud.heavyrain", "cloud.moon", "cloud.moon.bolt", "cloud.moon.rain", "cloud.rain", "cloud.sleet", "cloud.snow", "cloud.sun", "cloud.sun.bolt", "cloud.sun.rain", "comb", "command", "cone", "control", "cpu", "creditcard", "cross", "cross.case", "crown", "cube", "cube.transparent", "curlybraces", "cylinder", "cylinder.split.1x2", "delete.right", "desktopcomputer", "dial.max", "dial.min", "diamond", "directcurrent", "display", "display.2", "divide", "doc", "doc.on.clipboard", "doc.on.doc", "doc.zipper", "dot.radiowaves.right", "dpad", "drop", "drop.triangle", "ear", "eject", "ellipsis", "envelope", "envelope.open", "equal", "escape", "esim", "externaldrive", "eye", "eyebrow", "eyeglasses", "eyes", "eyes.inverse", "f.cursive", "face.dashed", "face.smiling", "faxmachine", "fiberchannel", "figure.stand", "figure.walk", "figure.walk.diamond", "figure.wave", "filemenu.and.selection", "film", "flag", "flame", "flipphone", "flowchart", "fn", "folder", "function", "fx", "gamecontroller", "gauge", "gear", "gearshape", "gearshape.2", "gift", "giftcard", "globe", "graduationcap", "greaterthan", "greetingcard", "grid", "guitars", "gyroscope", "hammer", "hare", "headphones", "hearingaid.ear", "heart", "helm", "hexagon", "highlighter", "hourglass", "house", "hurricane", "infinity", "info", "internaldrive", "iphone.homebutton.landscape", "iphone.landscape", "k", "key", "keyboard", "ladybug", "laptopcomputer", "lasso", "lasso.sparkles", "latch.2.case", "leaf", "lessthan", "level", "lifepreserver", "light.max", "light.min", "lightbulb", "link", "loupe", "lungs", "macwindow", "magnifyingglass", "mail", "mail.stack", "map", "megaphone", "memories", "memorychip", "metronome", "mic", "moon", "moon.stars", "moon.zzz", "mosaic", "mount", "mouth", "move.3d", "multiply", "music.mic", "music.note", "music.note.house", "music.quarternote.3", "mustache", "network", "newspaper", "nose", "nosign", "note", "number", "octagon", "opticaldisc", "opticaldiscdrive", "option", "paintbrush", "paintbrush.pointed", "paintpalette", "pano", "paperclip", "paperplane", "paragraphsign", "pause", "pc", "pencil", "percent", "person", "person.2", "person.3", "person.and.arrow.left.and.arrow.right", "personalhotspot", "perspective", "phone", "phone.connection", "phone.down", "photo", "photo.tv", "pianokeys", "pianokeys.inverse", "pills", "pin", "play", "play.tv", "playpause", "power", "powersleep", "printer", "printer.dotmatrix", "projective", "purchased", "puzzlepiece", "pyramid", "qrcode", "qrcode.viewfinder", "questionmark", "questionmark.diamond", "questionmark.folder", "radio", "rays", "recordingtape", "restart", "return", "rhombus", "rosette", "ruler", "scale.3d", "scalemass", "scanner", "scissors", "scope", "scribble", "scribble.variable", "scroll", "sdcard", "seal", "selection.pin.in.out", "server.rack", "shadow", "shield", "shield.checkerboard", "shift", "shippingbox", "shuffle", "signature", "signpost.right", "simcard", "simcard.2", "skew", "sleep", "slider.horizontal.3", "slider.vertical.3", "slowmo", "smoke", "snow", "sparkle", "sparkles", "speedometer", "sportscourt", "star", "staroflife", "stethoscope", "stop", "stopwatch", "strikethrough", "studentdesk", "suit.club", "suit.diamond", "suit.heart", "suit.spade", "sum", "sun.dust", "sun.haze", "sun.max", "sun.min", "sunrise", "sunset", "switch.2", "tag", "target", "terminal", "thermometer", "thermometer.snowflake", "thermometer.sun", "ticket", "timelapse", "timer", "togglepower", "tornado", "tortoise", "torus", "tram", "trash", "tray", "tray.2", "tray.full", "triangle", "tropicalstorm", "tuningfork", "tv", "tv.and.mediabox", "tv.music.note", "umbrella", "view.2d", "view.3d", "viewfinder", "wake", "wallet.pass", "wand.and.rays", "wand.and.rays.inverse", "wand.and.stars", "wand.and.stars.inverse", "wave.3.right", "waveform", "waveform.path", "waveform.path.ecg", "wifi", "wind", "wind.snow", "wrench", "wrench.and.screwdriver", "zzz"]

    let columns = [
        GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 16, alignment: .top)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(icons, id: \.self) { icon in
                        Image(systemName: icon)
                            .tag(icon)
                            .frame(width: 32, height: 32, alignment: .center)
                            .imageScale(.large)
                            .onTapGesture {
                                activeIcon = icon
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4).strokeBorder(
                                    Color.accentColor,
                                    lineWidth: icon == activeIcon ? 2 : 0
                                )
                            )
                            .padding(.vertical, 4)

                    }
                }.padding(.top)
            }
            .navigationTitle("Select Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle")
                    }.buttonStyle(ActionButtonStyle())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
