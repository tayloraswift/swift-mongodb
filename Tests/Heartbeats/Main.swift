import Heartbeats
import Testing

@main 
enum Main:AsyncTests
{
    static
    func run(tests:Tests) async
    {
        let clock:ContinuousClock = .init()
        do
        {
            let tests:TestGroup = tests / "drift"

            let t0:ContinuousClock.Instant = clock.now

            let interval:Duration = .microseconds(5000)
            let tolerance:Duration = .microseconds(3333)
            let heartbeat:Heartbeat = .init(interval: interval)

            await tests.do
            {
                var count:Int = 1
                for try await _:Void in heartbeat
                {
                    defer
                    {
                        count += 1
                    }
                    switch count
                    {
                    case 1 ..< 400:
                        //  heartbeats should not skew over time
                        let center:Duration = interval * count
                        let expected:ClosedRange<Duration> =
                            center - tolerance ... 
                            center + tolerance
                        
                        (tests / count.description).expect(expected ~=? t0.duration(to: .now))
                    case _:
                        return
                    }
                }
            }

            let t1:ContinuousClock.Instant = clock.now
            tests.expect(.milliseconds(1995) ... .milliseconds(2005) ~=? t0.duration(to: t1))
        }

        do
        {
            let tests:TestGroup = tests / "buffered"

            let t0:ContinuousClock.Instant = clock.now
            let heartbeat:Heartbeat = .init(interval: .milliseconds(250))

            await tests.do
            {
                // heartbeat should be buffered
                try await Task.sleep(until: t0.advanced(by: .milliseconds(375)), clock: clock)

                tests.expect(.milliseconds(370) ... .milliseconds(380) ~=?
                    t0.duration(to: .now))

                var last:ContinuousClock.Instant = .now
                var count:Int = 1
                for try await _:Void in heartbeat
                {
                    let tests:TestGroup = tests / count.description
                    defer
                    {
                        count += 1
                        last = .now
                    }
                    switch count
                    {
                    case 1:
                        // first heartbeat should be immediately available
                        tests.expect(.milliseconds(0) ... .milliseconds(5) ~=?
                            last.duration(to: .now))
                    case 2:
                        // second heartbeat should appear on normal schedule (not delayed)
                        tests.expect(.milliseconds(495) ... .milliseconds(505) ~=?
                            t0.duration(to: .now))
                    case _:
                        return
                    }
                }
            }

            let t1:ContinuousClock.Instant = clock.now

            tests.expect(.milliseconds(745) ... .milliseconds(755) ~=? t0.duration(to: t1))
        }

        do
        {
            let tests:TestGroup = tests / "skipped"

            let t0:ContinuousClock.Instant = clock.now
            let heartbeat:Heartbeat = .init(interval: .milliseconds(100))

            await tests.do
            {
                var last:ContinuousClock.Instant = .now
                var count:Int = 1
                for try await _:Void in heartbeat
                {
                    let tests:TestGroup = tests / count.description
                    defer
                    {
                        count += 1
                        last = .now
                    }
                    switch count
                    {
                    case 1:
                        /// only one heartbeat should be buffered
                        try await Task.sleep(until: t0.advanced(by: .milliseconds(350)),
                            clock: clock)
                        tests.expect(.milliseconds(345) ... .milliseconds(355) ~=?
                            t0.duration(to: .now))
                    
                    case 2:
                        // second heartbeat should be immediately available
                        tests.expect(.milliseconds(0) ... .milliseconds(5) ~=?
                            last.duration(to: .now))
                    case 3:
                        // third heartbeat should appear on normal schedule (not immediate, and not delayed)
                        tests.expect(.milliseconds(395) ... .milliseconds(405) ~=?
                            t0.duration(to: .now))
                    case _:
                        return
                    }
                }
            }

            let t1:ContinuousClock.Instant = clock.now

            tests.expect(.milliseconds(495) ... .milliseconds(505) ~=? t0.duration(to: t1))
        }

        do
        {
            let tests:TestGroup = tests / "manual"

            let t0:ContinuousClock.Instant = clock.now
            let heartbeat:Heartbeat = .init(interval: .milliseconds(100))
                heartbeat.heart.beat()

            Task<Void, Never>.init
            {
                try? await Task.sleep(until: t0.advanced(by: .milliseconds(150)), clock: clock)
                heartbeat.heart.beat()
            }
            Task<Void, Never>.init
            {
                try? await Task.sleep(until:  t0.advanced(by: .milliseconds(250)), clock: clock)
                heartbeat.heart.stop()
            }

            await tests.do
            {
                var last:ContinuousClock.Instant = .now
                var count:Int = 1
                heartbeats:
                for try await _:Void in heartbeat
                {
                    let tests:TestGroup = tests / count.description
                    defer
                    {
                        count += 1
                        last = .now
                    }
                    switch count
                    {
                    case 1:
                        // first heartbeat should be immediately available
                        tests.expect(.milliseconds(0) ... .milliseconds(5) ~=?
                            last.duration(to: .now))
                    
                    case 2:
                        tests.expect(.milliseconds(95) ... .milliseconds(105) ~=?
                            last.duration(to: .now))
                    case 3:
                        // manual heartbeat should appear immediately
                        tests.expect(.milliseconds(145) ... .milliseconds(155) ~=?
                            t0.duration(to: .now))
                    case 4:
                        // fourth (automatic) heartbeat should appear on normal schedule
                        tests.expect(.milliseconds(195) ... .milliseconds(205) ~=?
                            t0.duration(to: .now))
                    case _:
                        // we should never get here
                        tests.expect(true: false)
                    }
                }
            }

            let t1:ContinuousClock.Instant = clock.now

            tests.expect(.milliseconds(245) ... .milliseconds(255) ~=? t0.duration(to: t1))
        }
    }
}
