//
//  HayyaWidgetBundle.swift
//  HayyaWidget
//
//  Created by Jafar Fathul Haq on 3/11/26.
//

import WidgetKit
import SwiftUI

@main
struct HayyaWidgetBundle: WidgetBundle {
    var body: some Widget {
        HayyaPrayerWidget()
        HayyaMediumWidget()
        HayyaLargeWidget()
    }
}
