module test_timeunits_negatives

using Test
using TimeUnits # Compound
using Unitful: minute, s, ms, μs, ns, ps, fs, as

@test Compound(-1s)                    == Compound(-1s)
@test Compound(-1s).periods            ==         [-1s]
@test Compound(-3.141_592s)            == Compound(-3s, -141ms, -592μs)
@test Compound(-3.141_592s).periods    ==         [-3s, -141ms, -592μs]

end # module test_timeunits_negatives
