import SwiftUI

/// Where every stop in a world stands on screen, and the trail that joins them up.
///
/// The first stop is at the bottom and the world climbs from there, so unlocking a level
/// takes the player further up the meadow. Everything is worked out from the width the
/// map is given; the height falls out of how many stops there are.
struct WorldTrail {
    let map: WorldMap
    let width: CGFloat

    /// The climb from one stop to the next.
    static let climb: CGFloat = 188
    /// Meadow kept below the first stop and above the last, so neither is jammed against
    /// the end of the world.
    static let apron: CGFloat = 130
    static let headroom: CGFloat = 168
    /// How close to the side of the screen a signpost may stand.
    static let verge: CGFloat = 62
    /// How far a length of trail bows out to the side, as a fraction of its own length.
    static let bow: CGFloat = 0.16

    var height: CGFloat {
        Self.apron + CGFloat(map.reach) * Self.climb + Self.headroom
    }

    /// Where a stop stands.
    func point(of index: Int) -> CGPoint {
        let node = map[min(max(index, 0), map.count - 1)]
        return CGPoint(
            x: Self.verge + CGFloat(node.across) * max(width - Self.verge * 2, 1),
            y: height - Self.apron - CGFloat(node.up) * Self.climb
        )
    }

    /// Where something walking the trail stands when it is `progress` stops along it.
    func point(at progress: Double) -> CGPoint {
        guard map.count > 1 else { return point(of: 0) }
        let walked = min(max(progress, 0), Double(map.count - 1))
        let leg = min(Int(walked.rounded(.down)), map.count - 2)
        return curve(from: leg).point(at: walked - Double(leg))
    }

    /// One length of trail. Consecutive lengths bow opposite ways, which is the whole of
    /// why the trail winds rather than zigzags.
    func curve(from index: Int) -> TrailCurve {
        let start = point(of: index)
        let end = point(of: index + 1)
        let lean: CGFloat = index.isMultiple(of: 2) ? 1 : -1
        let run = CGPoint(x: end.x - start.x, y: end.y - start.y)
        return TrailCurve(
            start: start,
            control: CGPoint(
                x: (start.x + end.x) / 2 - run.y * Self.bow * lean,
                y: (start.y + end.y) / 2 + run.x * Self.bow * lean
            ),
            end: end
        )
    }

    /// The trail from the start of the world up to `progress` stops along it.
    func path(upTo progress: Double) -> Path {
        var path = Path()
        guard map.count > 1, progress > 0 else { return path }

        let walked = min(progress, Double(map.count - 1))
        path.move(to: point(of: 0))
        var leg = 0
        while Double(leg) < walked {
            let length = curve(from: leg).clipped(to: walked - Double(leg))
            path.addQuadCurve(to: length.end, control: length.control)
            leg += 1
        }
        return path
    }

    /// Points strung along the whole trail, for placing scenery that has to keep out of
    /// the way of it.
    func waymarks(every step: Double = 0.05) -> [CGPoint] {
        guard map.count > 1 else { return [point(of: 0)] }
        let end = Double(map.count - 1)
        var marks: [CGPoint] = []
        var walked = 0.0
        while walked < end {
            marks.append(point(at: walked))
            walked += step
        }
        marks.append(point(at: end))
        return marks
    }
}

/// A single bowed length of trail, and the two things a map needs to do with one: find a
/// point along it, and cut it short where a walk has got to.
struct TrailCurve {
    let start: CGPoint
    let control: CGPoint
    let end: CGPoint

    func point(at fraction: Double) -> CGPoint {
        let along = CGFloat(min(max(fraction, 0), 1))
        let left = 1 - along
        return CGPoint(
            x: left * left * start.x + 2 * left * along * control.x + along * along * end.x,
            y: left * left * start.y + 2 * left * along * control.y + along * along * end.y
        )
    }

    /// The first `fraction` of the length, as a bowed length in its own right.
    func clipped(to fraction: Double) -> TrailCurve {
        let along = CGFloat(min(max(fraction, 0), 1))
        return TrailCurve(
            start: start,
            control: CGPoint(
                x: start.x + (control.x - start.x) * along,
                y: start.y + (control.y - start.y) * along
            ),
            end: point(at: fraction)
        )
    }
}
