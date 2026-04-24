import SwiftUI

private enum SortisActionIconMetrics {
    static let viewport: CGFloat = 24
    static let strokeWidth: CGFloat = 2
}

private func scaledMetrics(for canvasSize: CGSize, factor: CGFloat) -> (scale: CGFloat, offset: CGFloat) {
    let baseScale = min(canvasSize.width, canvasSize.height) / SortisActionIconMetrics.viewport
    let scaled = baseScale * factor
    let offset = (SortisActionIconMetrics.viewport * (baseScale - scaled)) / 2
    return (scaled, offset)
}

private func iconPoint(_ x: CGFloat, _ y: CGFloat, scale: CGFloat, offset: CGFloat) -> CGPoint {
    CGPoint(x: x * scale + offset, y: y * scale + offset)
}

private func strokeStyle(scale: CGFloat) -> StrokeStyle {
    StrokeStyle(
        lineWidth: SortisActionIconMetrics.strokeWidth * scale,
        lineCap: .round,
        lineJoin: .round
    )
}

struct SortisCreateIcon: View {
    var size: CGFloat = 18
    var color: Color = .accentColor

    var body: some View {
        Canvas { context, canvasSize in
            let metrics = scaledMetrics(for: canvasSize, factor: 0.85)
            var path = Path()
            path.move(to: iconPoint(12, 3, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(12, 21, scale: metrics.scale, offset: metrics.offset))
            path.move(to: iconPoint(3, 12, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(21, 12, scale: metrics.scale, offset: metrics.offset))
            context.stroke(path, with: .color(color), style: strokeStyle(scale: metrics.scale))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SortisSearchIcon: View {
    var size: CGFloat = 18
    var color: Color = .secondary

    var body: some View {
        Canvas { context, canvasSize in
            let metrics = scaledMetrics(for: canvasSize, factor: 0.9)
            let center = iconPoint(10, 10, scale: metrics.scale, offset: metrics.offset)
            let radius = 6 * metrics.scale
            let circleRect = CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )

            var path = Path(ellipseIn: circleRect)
            path.move(to: iconPoint(14.5, 14.5, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(19, 19, scale: metrics.scale, offset: metrics.offset))
            context.stroke(path, with: .color(color), style: strokeStyle(scale: metrics.scale))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SortisRefreshIcon: View {
    var size: CGFloat = 18
    var color: Color = .accentColor

    var body: some View {
        Canvas { context, canvasSize in
            let metrics = scaledMetrics(for: canvasSize, factor: 0.88)
            var path = Path()
            path.move(to: iconPoint(18.4721, 16.7023, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(13.8064, 19.7934, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(17.3398, 18.2608, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(15.6831, 19.3584, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(8.25656, 19.0701, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(11.9297, 20.2284, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(9.95909, 19.9716, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(4.53889, 14.8865, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(6.55404, 18.1687, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(5.23397, 16.6832, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(4.47295, 9.29011, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(3.84381, 13.0898, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(3.82039, 11.1027, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(8.09103, 5.02005, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(5.12551, 7.47756, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(6.41021, 5.96135, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(13.6223, 4.16623, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(9.77184, 4.07875, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(11.7359, 3.77558, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(18.3596, 7.14656, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(15.5087, 4.55689, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(17.1908, 5.61514, scale: metrics.scale, offset: metrics.offset)
            )
            path.addCurve(
                to: iconPoint(19.9842, 12.5023, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(19.5283, 8.67797, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(20.1052, 10.5797, scale: metrics.scale, offset: metrics.offset)
            )
            path.move(to: iconPoint(19.9842, 12.5023, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(21.4842, 11.0023, scale: metrics.scale, offset: metrics.offset))
            path.move(to: iconPoint(19.9842, 12.5023, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(18.4842, 11.0023, scale: metrics.scale, offset: metrics.offset))
            context.stroke(path, with: .color(color), style: strokeStyle(scale: metrics.scale))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SortisTimeFilterIcon: View {
    var size: CGFloat = 18
    var color: Color = .secondary

    var body: some View {
        Canvas { context, canvasSize in
            let metrics = scaledMetrics(for: canvasSize, factor: 1)
            let barRadius = metrics.scale
            let topBar = Path(
                roundedRect: CGRect(
                    x: 3 * metrics.scale + metrics.offset,
                    y: 5 * metrics.scale + metrics.offset,
                    width: 18 * metrics.scale,
                    height: 2 * metrics.scale
                ),
                cornerRadius: barRadius
            )
            let middleBar = Path(
                roundedRect: CGRect(
                    x: 6 * metrics.scale + metrics.offset,
                    y: 11 * metrics.scale + metrics.offset,
                    width: 12 * metrics.scale,
                    height: 2 * metrics.scale
                ),
                cornerRadius: barRadius
            )
            let bottomBar = Path(
                roundedRect: CGRect(
                    x: 9 * metrics.scale + metrics.offset,
                    y: 17 * metrics.scale + metrics.offset,
                    width: 6 * metrics.scale,
                    height: 2 * metrics.scale
                ),
                cornerRadius: barRadius
            )
            context.fill(topBar, with: .color(color))
            context.fill(middleBar, with: .color(color))
            context.fill(bottomBar, with: .color(color))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct SortisMessageFilterIcon: View {
    var size: CGFloat = 18
    var color: Color = .secondary

    var body: some View {
        Canvas { context, canvasSize in
            let metrics = scaledMetrics(for: canvasSize, factor: 0.94)
            var path = Path()
            path.move(to: iconPoint(17.8258, 5, scale: metrics.scale, offset: metrics.offset))
            path.addLine(to: iconPoint(6.17422, 5, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(5.41496, 6.65079, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(5.31987, 5, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(4.85896, 6.00212, scale: metrics.scale, offset: metrics.offset)
            )
            path.addLine(to: iconPoint(9.75926, 11.7191, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(10, 12.3699, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(9.91461, 11.9004, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(10, 12.1312, scale: metrics.scale, offset: metrics.offset)
            )
            path.addLine(to: iconPoint(10, 17.382, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(10.5528, 18.2764, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(10, 17.7607, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(10.214, 18.107, scale: metrics.scale, offset: metrics.offset)
            )
            path.addLine(to: iconPoint(12.5528, 19.2764, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(14, 18.382, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(13.2177, 19.6088, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(14, 19.1253, scale: metrics.scale, offset: metrics.offset)
            )
            path.addLine(to: iconPoint(14, 12.3699, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(14.2407, 11.7191, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(14, 12.1312, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(14.0854, 11.9004, scale: metrics.scale, offset: metrics.offset)
            )
            path.addLine(to: iconPoint(18.585, 6.65079, scale: metrics.scale, offset: metrics.offset))
            path.addCurve(
                to: iconPoint(17.8258, 5, scale: metrics.scale, offset: metrics.offset),
                control1: iconPoint(19.141, 6.00212, scale: metrics.scale, offset: metrics.offset),
                control2: iconPoint(18.6801, 5, scale: metrics.scale, offset: metrics.offset)
            )
            context.stroke(path, with: .color(color), style: strokeStyle(scale: metrics.scale))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
