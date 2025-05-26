module test_timeunits_Compound

using Test
using TimeUnits # Compound
using Unitful: minute, s, ms, μs, ns, ps, fs, as

using TimeUnits: base_thousand, canonical_fractional_part, canonical_floating_parts

@test base_thousand(3,   false) == [(1, 300)]
@test base_thousand(37,  false) == [(1, 370)]
@test base_thousand(370, false) == [(1, 370)]

@test base_thousand(545_454_545_47, false) == [(1, 545), (2, 454), (3, 545), (4, 470)]
@test base_thousand(545_454_545_47, true)  == [(2, -545), (3, -454), (4, -545), (5, -470)]

@test canonical_fractional_part(123, 0) == [123ms]
@test canonical_fractional_part(123, 1) == [123μs]

@test canonical_floating_parts(0.123, s)               == [123ms]
@test canonical_floating_parts(0.123_456, s)           == [123ms, 456μs]
@test canonical_floating_parts(123.0, ms)              == [123ms]
@test canonical_floating_parts(123.456, ms)            == [123ms, 456μs]
@test canonical_floating_parts(123.456_789, ms)        == [123ms, 456μs, 789ns]

@test canonical_floating_parts(226_279.545_454_545, ms)    == [3minute, 46s, 279ms, 545μs, 454ns, 545ps]
@test canonical_floating_parts(226_279.545_454_545_47, ms) == [3minute, 46s, 279ms, 545μs, 454ns, 545ps, 470fs]

@test 1fs == 1000as == (1/1000)ps

@test Compound()                       == Compound()

@test Compound(0.0s)                   == Compound(0s)
@test Compound(3.141_592s)             == Compound(3s, 141ms, 592μs)
@test Compound(3.141_592_653_589_793s) == Compound(3s, 141ms, 592μs, 653ns, 589ps, 793fs)
@test Compound(3.141_000_653_589_793s) == Compound(3s, 141ms,        653ns, 589ps, 793fs)
@test Compound(6.283_185_307_179_586s) == Compound(6s, 283ms, 185μs, 307ns, 179ps, 586fs)

@test Compound(60s)                    == Compound(1minute)
@test Compound(63s)                    == Compound(1minute, 3s)
@test Compound(63s).periods            == [1minute, 3s]
@test Compound(1minute, 3s).periods    == [1minute, 3s]
@test Compound(63.141s)                == Compound(1minute, 3s, 141ms)

@test Compound(141.592ms)              == Compound(141ms, 592μs)
@test Compound(141.592ms).periods      == [141ms, 592μs]
@test Compound(0as)                    == Compound(0as)

@test Compound(620ms, 004μs, 545ns, 454ps, 545fs, 455as) == Compound(620ms, 004μs, 545ns, 454ps, 545fs, 455as)
@test Compound(226_279.545_454_545_47ms)                 == Compound(3minute, 46s, 279ms, 545μs, 454ns, 545ps, 470fs)
@test Compound(620.454_545_454_545_5ms) == Compound(620ms, 454μs, 545ns, 454ps, 545fs, 500as)

end # module test_timeunits_Compound
