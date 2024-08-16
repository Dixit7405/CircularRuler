//
//  ContentView.swift
//  RulerDemo
//
//  Created by Dixit Rathod on 15/08/24.
//

import SwiftUI

struct ContentView: View {
    let fillColor = Color(red: 46/255, green: 45/255, blue: 55/255)
    let bgColor = Color(red: 34/255, green: 34/255, blue: 44/255)
    let lineColor = Color(red: 63/255, green: 62/255, blue: 72/255)
    
    @State private var rotationAngle: Angle = .zero
    @State private var previousAngle: Angle = .zero
    @State private var initialAngle: Angle = .zero
    @State private var isDragging: Bool = false
    
    let circleRadius: CGFloat = 600
    let initialWeight: Int = 65
    
    var rulerLines: Int {
        return maxValue - minValue
    }
    let minValue: Int = 25
    let maxValue: Int = 200
    
    
    var body: some View {
        ZStack {
            bgColor
                .edgesIgnoringSafeArea(.all)
            
            let circleOffset = UIScreen.main.bounds.size.height/2 + circleRadius/4
            
            ZStack {
                Circle()
                    .fill(fillColor)
                    .overlay {
                        ZStack {
                            lineColor
                                .frame(width: 1)
                            
                            lineColor
                                .frame(width: 1)
                                .rotationEffect(.degrees(45))
                            
                            lineColor
                                .frame(width: 1)
                                .rotationEffect(.degrees(-45))
                            
                            lineColor
                                .frame(height: 1)
                        }
                    }
                    .padding(7)
                
                    .overlay {
                        RadialLayout {
                            let totalLines = rulerLines * 5
                            
                            ForEach(0..<totalLines, id: \.self) { index in
                                let angle = 360.0/CGFloat(totalLines)
                                
                                Rectangle()
                                    .fill(lineColor)
                                    .frame(width: 2, height: 10)
                                    .rotationEffect(.degrees(CGFloat(index) * angle))
                                
                            }
                        }
                    }
                    .padding(10)
                    .overlay {
                        
                        RadialLayout {
                            let totalLines = rulerLines * 5
                            
                            ForEach(0..<totalLines, id: \.self) { index in
                                let angle = 360.0/CGFloat(totalLines)
                                
                                Circle()
                                    .fill(lineColor)
                                    .frame(width: 2)
                                    .rotationEffect(.degrees(CGFloat(index) * angle))
                                
                            }
                        }
                    }
                    .padding(20)
                    .overlay {
                        RadialLayout {
                            let totalLines = rulerLines
                            
                            ForEach(0..<totalLines, id: \.self) { index in
                                let angle = 360.0/CGFloat(totalLines)
                                
                                Rectangle()
                                    .fill(lineColor)
                                    .frame(width: 2, height: 25)
                                    .rotationEffect(.degrees(CGFloat(index) * angle))
                                
                            }
                        }
                    }
                    .padding(40)
                    .overlay {
                        RadialLayout {
                            let totalLines = rulerLines
                            
                            ForEach(0..<totalLines, id: \.self) { index in
                                let angle = 360.0/CGFloat(totalLines)
                                let angleToRotate = CGFloat(index) * angle
                                
                                GeometryReader { geo in
                                    let color:Color = geo.frame(in: .global).midX >= UIScreen.main.bounds.size.width/2 ? .white : .gray
                                    
                                    if Double(index).remainder(dividingBy: 2) == 0 {
                                        Text(index/2 + minValue, format: .number)
                                            .foregroundStyle(color)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                                    }
                                    
                                }
                                .frame(width: 50, height: 20, alignment: .center)
//                                .background(Color.red.opacity(0.1))
                                .rotationEffect(.degrees(angleToRotate))
                                
                                
                            }
                        }
                    }
                
            }
            .rotationEffect(rotationAngle)
            
            .gesture(DragGesture()
                .onChanged({ value in
                    let vector = CGVector(dx: value.location.x - circleRadius, dy: value.location.y - circleRadius)
                    let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                    
                    if isDragging == false {
                        isDragging = true
                        initialAngle = Angle(degrees: Double(angle))
                    }
                    
                    let delta = Angle(degrees: Double(angle)) - initialAngle
                    rotationAngle = delta + previousAngle
                    
                    
                }).onEnded({ value in
                    previousAngle = rotationAngle
                    isDragging = false
                    
                }))
            .frame(width: circleRadius * 2, height: circleRadius * 2)
            .offset(y: circleOffset)
            
            
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.red)
                .frame(width: 2, height: 25)
                .offset(y: circleOffset)
                .offset(y: -circleRadius + 40)
            
            VStack(spacing: 10) {
                Text("YOUR WEIGHT")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                Text(formattedWeight)
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
            }
            .offset(y: -200)
            
            
        }
        .onAppear {
            //Set Initial Weight
            let weight = (initialWeight - minValue) * 2
            let angle = (360.0 * Double(weight))/Double(rulerLines)
            previousAngle = .degrees(-angle)
            rotationAngle = .degrees(-angle)
        }
    }
    
    var formattedWeight: String {
        let numeberFormatter = NumberFormatter()
        numeberFormatter.minimumFractionDigits = 1
        numeberFormatter.maximumFractionDigits = 1
        return numeberFormatter.string(from: NSNumber(value: selectedWeight)) ?? ""
    }
    
    func formatterWeight(for value: Double) -> String {
        let numeberFormatter = NumberFormatter()
        numeberFormatter.minimumFractionDigits = 0
        numeberFormatter.maximumFractionDigits = 0
        return numeberFormatter.string(from: NSNumber(value: selectedWeight)) ?? ""
    }
    
    var selectedWeight: Double {
        let angle = (rotationAngle.degrees * Double(self.rulerLines))/360.0
        return (-angle/2) + Double(minValue)
    }
}


struct RadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // calculate the radius of our bounds
        let radius = min(bounds.size.width, bounds.size.height) / 2
        
        // figure out the angle between each subview on our circle
        let angle = Angle.degrees(360 / Double(subviews.count)).radians
        
        for (index, subview) in subviews.enumerated() {
            // ask this view for its ideal size
            //            let viewSize = subview.sizeThatFits(.unspecified)
            
            // calculate the X and Y position so this view lies inside our circle's edge
            let xPos = cos(angle * Double(index) - .pi / 2) * (radius)
            let yPos = sin(angle * Double(index) - .pi / 2) * (radius)
            
            // position this view relative to our centre, using its natural size ("unspecified")
            let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

#Preview {
    ContentView()
}
