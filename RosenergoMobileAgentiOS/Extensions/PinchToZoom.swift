//
//  PinchToZoom.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

#if !os(watchOS)
    class PinchZoomView: UIView {
        weak var delegate: PinchZoomViewDelgate?

        private(set) var scale: CGFloat = 0 {
            didSet {
                delegate?.pinchZoomView(self, didChangeScale: scale)
            }
        }

        private(set) var anchor: UnitPoint = .center {
            didSet {
                delegate?.pinchZoomView(self, didChangeAnchor: anchor)
            }
        }

        private(set) var offset: CGSize = .zero {
            didSet {
                delegate?.pinchZoomView(self, didChangeOffset: offset)
            }
        }

        private(set) var isPinching: Bool = false {
            didSet {
                delegate?.pinchZoomView(self, didChangePinching: isPinching)
            }
        }

        private var startLocation: CGPoint = .zero
        private var location: CGPoint = .zero
        private var numberOfTouches: Int = 0

        init() {
            super.init(frame: .zero)

            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
            pinchGesture.cancelsTouchesInView = false
            addGestureRecognizer(pinchGesture)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        @objc private func pinch(gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                isPinching = true
                startLocation = gesture.location(in: self)
                anchor = UnitPoint(x: startLocation.x / bounds.width, y: startLocation.y / bounds.height)
                numberOfTouches = gesture.numberOfTouches

            case .changed:
                if gesture.numberOfTouches != numberOfTouches {
                    let newLocation = gesture.location(in: self)
                    let jumpDifference = CGSize(width: newLocation.x - location.x, height: newLocation.y - location.y)
                    startLocation = CGPoint(x: startLocation.x + jumpDifference.width, y: startLocation.y + jumpDifference.height)

                    numberOfTouches = gesture.numberOfTouches
                }

                scale = gesture.scale

                location = gesture.location(in: self)
                offset = CGSize(width: location.x - startLocation.x, height: location.y - startLocation.y)

            case .ended, .cancelled, .failed:
                isPinching = false
                scale = 1.0
                anchor = .center
                offset = .zero
            default:
                break
            }
        }
    }

    protocol PinchZoomViewDelgate: AnyObject {
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
        func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
    }

    struct PinchZoom: UIViewRepresentable {
        @Binding var scale: CGFloat
        @Binding var anchor: UnitPoint
        @Binding var offset: CGSize
        @Binding var isPinching: Bool

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIView(context: Context) -> PinchZoomView {
            let pinchZoomView = PinchZoomView()
            pinchZoomView.delegate = context.coordinator
            return pinchZoomView
        }

        func updateUIView(_: PinchZoomView, context _: Context) {}

        class Coordinator: NSObject, PinchZoomViewDelgate {
            var pinchZoom: PinchZoom

            init(_ pinchZoom: PinchZoom) {
                self.pinchZoom = pinchZoom
            }

            func pinchZoomView(_: PinchZoomView, didChangePinching isPinching: Bool) {
                pinchZoom.isPinching = isPinching
            }

            func pinchZoomView(_: PinchZoomView, didChangeScale scale: CGFloat) {
                pinchZoom.scale = scale
            }

            func pinchZoomView(_: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
                pinchZoom.anchor = anchor
            }

            func pinchZoomView(_: PinchZoomView, didChangeOffset offset: CGSize) {
                pinchZoom.offset = offset
            }
        }
    }
#endif

#if os(watchOS)
    struct PinchToZoomWatch: ViewModifier {
        @State private var currentPosition: CGSize = .zero
        @State private var newPosition: CGSize = .zero
        @State private var scale: CGFloat = 1.0

        func body(content: Content) -> some View {
            content
                .scaleEffect(scale)
                .focusable(true)
                .digitalCrownRotation($scale, from: 1.0, through: 5.0, by: 0.1, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                .offset(x: currentPosition.width, y: currentPosition.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if self.scale != 1.0 {
                                self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                            } else {
                                self.currentPosition = .zero
                            }
                        }
                        .onEnded { value in
                            if self.scale != 1.0 {
                                self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                self.newPosition = self.currentPosition
                            } else {
                                self.currentPosition = .zero
                            }
                        }
                )
                .animation(.interactiveSpring())
        }
    }
#else
    struct PinchToZoom: ViewModifier {
        @State var scale: CGFloat = 1.0
        @State var anchor: UnitPoint = .center
        @State var offset: CGSize = .zero
        @State var isPinching: Bool = false

        func body(content: Content) -> some View {
            content
                .scaleEffect(scale, anchor: anchor)
                .offset(offset)
                .animation(isPinching ? .none : .spring())
                .overlay(PinchZoom(scale: $scale, anchor: $anchor, offset: $offset, isPinching: $isPinching))
        }
    }
#endif

extension View {
    func pinchToZoom() -> some View {
        #if os(watchOS)
            return modifier(PinchToZoomWatch())
        #else
            return modifier(PinchToZoom())
        #endif
    }
}
