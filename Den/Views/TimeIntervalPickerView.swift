//
//  TimeIntervalPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 11/6/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimeIntervalPickerView: View {
    @Binding var duration: Int // seconds
    
    let minimum: Int
    let maximum: Int
    
    var step: Int {
        if duration < 5 * 60 {
            return 60
        }
        
        if duration < 15 * 60 {
            return 5 * 60
        }
        
        if duration < 60 * 60 {
            return 15 * 60
        }
        
        if duration < 2 * 60 * 60 {
            return 30 * 60
        }
        
        if duration < 6 * 60 * 60 {
            return 60 * 60
        }
        
        if duration < 24 * 60 * 60 {
            return 6 * 60 * 60
        }
        
        return 24 * 60 * 60
    }
    
    var days: Int {
        (duration / 60 / 60 / 24)
    }
    
    var hours: Int {
        (duration / 60 / 60) % 24
    }
    
    var minutes: Int {
        (duration % (60 * 60)) / 60
    }
    
    var body: some View {
        HStack {
            Stepper(value: $duration, in: minimum...maximum, step: step) {
                HStack(spacing: 4) {
                    if days > 1 {
                        Text("\(days) days")
                    } else if days > 0 {
                        Text("\(days) day")
                    }
                    
                    if hours > 1 {
                        Text("\(hours) hours")
                    } else if hours > 0 {
                        Text("\(hours) hour")
                    }
                    
                    if minutes > 1 {
                        Text("\(minutes) minutes")
                    } else if minutes > 0 {
                        Text("\(minutes) minute")
                    }
                }
            }
        }
    }
    
    private func updateDuration() {
        duration = (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)
    }
}

