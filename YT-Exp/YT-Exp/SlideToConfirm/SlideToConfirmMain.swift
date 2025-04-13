//
//  SlideToConfirmMain.swift
//  YT-Exp
//
//  Created by Malith Madhushanka on 2025-04-13.
//

import SwiftUI

struct SlideToConfirmMain: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                let config = SlideToConfirm.Config(
                    idelText: "Swipe to pay",
                    onSwipeText: "Confirms payment",
                    confirmationText: "Success!",
                    tint: .green,
                    foregroundColor: .white
                )
                
                SlideToConfirm(config: config) {
                    print("swiped...")
                }
            }
            .padding(15)
            .navigationBarTitle("Slide to Confirm")
        }
    }
}

#Preview {
    SlideToConfirmMain()
}
