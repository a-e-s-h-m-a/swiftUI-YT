//
//  PopoutView.swift
//  YT-Exp
//
//  Created by Malith Madhushanka on 2025-04-12.
//
import SwiftUI

struct PopoutView<Header: View, Content: View>: View {
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content
    
    @State private var sourceRect: CGRect = .zero
    @State private var showFullScreenCover = false
    @State private var animateView = false
    
    @State private var haptics: Bool = false
    var body: some View {
        ZStack {
            header(animateView)
                .background(solidBackground(color: .gray, opacity: 0.1))
                .clipShape(.rect(cornerRadius: 10))
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .global)
                } action: { newValue in
                    sourceRect = newValue
                }
                .contentShape(.rect)
                .opacity(showFullScreenCover ? 0 : 1)
                .onTapGesture {
                    haptics.toggle()
                    toggleFullScreenCover()
                }
                .fullScreenCover(isPresented: $showFullScreenCover) {
                    PopupOverlay(
                        sourceRect: $sourceRect,
                        animateView: $animateView,
                        header: header,
                        content: content) {
                            withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
                                animateView = false
                            } completion: {
                                toggleFullScreenCover()
                            }
                        }
                }
                .sensoryFeedback(.impact, trigger: haptics)
        }
    }
    
    private func toggleFullScreenCover() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showFullScreenCover.toggle()
        }
    }
}

fileprivate struct PopupOverlay<Header: View, Content: View>: View {
    @Binding var sourceRect: CGRect
    @Binding var animateView: Bool
    
    @ViewBuilder var header: (Bool) -> Header
    @ViewBuilder var content: (Bool) -> Content
    var dismiss: () -> Void
    
    @State private var edgeInsets: EdgeInsets = .init()
    @State private var scale: CGFloat = 1
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                if animateView {
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.primary)
                            .contentShape(.rect)
                    }
                }
                header(animateView)
            }
            
            if animateView {
                content(animateView)
                    .transition(.blurReplace)
            }
        }
        .frame(maxWidth: animateView ? .infinity : nil)
        .padding(animateView ? 15 : 0)
        .background {
            ZStack {
                solidBackground(color: .gray, opacity: 0.1)
                    .opacity(!animateView ? 1 : 0)
                Rectangle()
                    .fill(.background)
                    .opacity(animateView ? 1 : 0)
            }
        }
        .clipShape(.rect(cornerRadius: animateView ? 20 : 10))
        .scaleEffect(scale, anchor: .top)
        .frame(
            width: animateView ? nil : sourceRect.width,
            height: animateView ? nil : sourceRect.height
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .offset(
            x: animateView ? 0 : sourceRect.minX,
            y: animateView ? 0 : sourceRect.minY
        )
        .padding(animateView ? 15 : 0)
        .padding(.top, animateView ? edgeInsets.top : 0)
        .ignoresSafeArea()
        .presentationBackground {
            GeometryReader {
                let size = $0.size
                Rectangle()
                    .fill(.black.opacity(animateView ? 0.5 : 0))
                    .onTapGesture {
                        dismiss()
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                let height = value.translation.height
                                let scale = height / size.height
                                let applyingRatio: CGFloat = 0.1
                                self.scale = 1 + (scale * applyingRatio)
                            }).onEnded({ value in
                                let velocityHeight = value.velocity.height / 5
                                let height = value.translation.height + velocityHeight
                                let scale = height / size.height
                                let applyingRatio: CGFloat = 0.1
      
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    self.scale = 1
                                }
                                
                                if -scale > 0.5 {
                                    dismiss()
                                }
                            })
                    )
            }
        }
        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { newValue in
            guard !animateView else { return }
            edgeInsets = newValue
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.25)) {
                    animateView = true
                }
            }
        }

    }
}

#Preview {
    ContentView()
}

extension View {
    func solidBackground(color: Color, opacity: CGFloat) -> some View {
        Rectangle()
            .fill(.background)
            .overlay {
                Rectangle()
                    .fill(color.opacity(opacity))
            }
    }
}
