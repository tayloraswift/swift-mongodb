import Heartbeats
import Testing

@main 
enum Main:AsynchronousTests
{
    static
    func run(tests:inout Tests) async
    {
        let clock:ContinuousClock = .init()

        await tests.do(name: "intervals")
        {
            var last:ContinuousClock.Instant = .now
            let t:(ContinuousClock.Instant, ContinuousClock.Instant)

            t.0 = last

            let heartbeat:Heartbeat = .init(interval: .milliseconds(50))
            var count:Int = 0

            heartbeats:
            for try await _:Void in heartbeat
            {
                defer
                {
                    count += 1
                    last = .now
                }
                switch count
                {
                case 0:
                    // first heartbeat should appear immediately
                    $0.assert(.milliseconds(0) ... .milliseconds(10) ~=? last.duration(to: .now),
                        name: count.description)
                case 1 ..< 20:
                    // first heartbeat should appear immediately
                    $0.assert(.milliseconds(45) ... .milliseconds(55) ~=? last.duration(to: .now),
                        name: count.description)
                case _:
                    break heartbeats
                }
            }

            t.1 = .now

            // accuracy should be within 1 percent
            $0.assert(.milliseconds(990) ... .milliseconds(1010) ~=? t.0.duration(to: t.1),
                name: "elapsed-time")
        }

        await tests.do(name: "buffering")
        {
            let t:(ContinuousClock.Instant, ContinuousClock.Instant)

            t.0 = .now
                
            let heartbeat:Heartbeat = .init(interval: .milliseconds(250))

            // heartbeat should be buffered
            try await Task.sleep(for: .milliseconds(125))

            $0.assert(.milliseconds(120) ... .milliseconds(130) ~=? t.0.duration(to: .now),
                name: "sleep")

            var last:ContinuousClock.Instant = .now
            var count:Int = 0
            heartbeats:
            for try await _:Void in heartbeat
            {
                defer
                {
                    count += 1
                    last = .now
                }
                switch count
                {
                case 0:
                    // first heartbeat should be immediately available
                    $0.assert(.milliseconds(0) ... .milliseconds(10) ~=? last.duration(to: .now),
                        name: count.description)
                case 1:
                    // second heartbeat should appear on normal schedule (not delayed)
                    $0.assert(.milliseconds(245) ... .milliseconds(255) ~=? t.0.duration(to: .now),
                        name: count.description)
                case _:
                    break heartbeats
                }
            }

            t.1 = .now

            $0.assert(.milliseconds(495) ... .milliseconds(505) ~=? t.0.duration(to: t.1),
                name: "elapsed-time")
        }

        await tests.do(name: "skipping")
        {
            let t:(ContinuousClock.Instant, ContinuousClock.Instant)

            t.0 = .now

            let heartbeat:Heartbeat = .init(interval: .milliseconds(100))

            var last:ContinuousClock.Instant = .now
            var count:Int = 0
            heartbeats:
            for try await _:Void in heartbeat
            {
                defer
                {
                    count += 1
                    last = .now
                }
                switch count
                {
                case 0:
                    /// only one heartbeat should be buffered
                    try await Task.sleep(for: .milliseconds(350))
                    $0.assert(.milliseconds(345) ... .milliseconds(355) ~=? t.0.duration(to: .now),
                        name: "sleep")
                
                case 1:
                    // second heartbeat should be immediately available
                    $0.assert(.milliseconds(0) ... .milliseconds(10) ~=? last.duration(to: .now),
                        name: count.description)
                case 2:
                    // third heartbeat should appear on normal schedule (not immediate, and not delayed)
                    $0.assert(.milliseconds(395) ... .milliseconds(405) ~=? t.0.duration(to: .now),
                        name: count.description)
                case _:
                    break heartbeats
                }
            }

            t.1 = .now

            $0.assert(.milliseconds(495) ... .milliseconds(505) ~=? t.0.duration(to: t.1),
                name: "elapsed-time")
        }

        await tests.do(name: "manual")
        {
            let t:(ContinuousClock.Instant, ContinuousClock.Instant)

            t.0 = .now

            let heartbeat:Heartbeat = .init(interval: .milliseconds(100))

            Task<Void, Never>.init
            {
                try? await Task.sleep(for: .milliseconds(150))
                heartbeat.heart.beat()
            }

            var last:ContinuousClock.Instant = .now
            var count:Int = 0
            heartbeats:
            for try await _:Void in heartbeat
            {
                defer
                {
                    count += 1
                    last = .now
                }
                switch count
                {
                case 0:
                    // first heartbeat should be immediately available
                    $0.assert(.milliseconds(0) ... .milliseconds(10) ~=? last.duration(to: .now),
                        name: count.description)
                
                case 1:
                    $0.assert(.milliseconds(95) ... .milliseconds(105) ~=? last.duration(to: .now),
                        name: count.description)
                case 2:
                    // manual heartbeat should appear immediately
                    $0.assert(.milliseconds(145) ... .milliseconds(155) ~=? t.0.duration(to: .now),
                        name: count.description)
                case 3:
                    // fourth (automatic) heartbeat should appear on normal schedule
                    $0.assert(.milliseconds(195) ... .milliseconds(205) ~=? t.0.duration(to: .now),
                        name: count.description)
                case _:
                    break heartbeats
                }
            }

            t.1 = .now

            $0.assert(.milliseconds(295) ... .milliseconds(305) ~=? t.0.duration(to: t.1),
                name: "elapsed-time")
        }
    }
}
