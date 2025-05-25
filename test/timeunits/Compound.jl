module test_timeunits_Compound

using Test
using TimeUnits # Compound
using Unitful: minute, s, ms, μs, ns, ps, fs, as

@test 1fs == 1000as == (1/1000)ps
@test Compound(0.0s)                   == Compound(0s)
@test Compound(3.141_592s)             == Compound(3s, 141ms, 592μs)
@test Compound(3.141_592_653_589_793s) == Compound(3s, 141ms, 592μs, 653ns, 589ps, 793fs)
@test Compound(3.141_000_653_589_793s) == Compound(3s, 141ms,        653ns, 589ps, 793fs)
@test Compound(6.283_185_307_179_586s) == Compound(6s, 283ms, 185μs, 307ns, 179ps, 586fs)

@test Compound(60s)                    == Compound(1minute)
@test Compound(63s)                    == Compound(1minute, 3s)
@test Compound(63s).periods            == [63s]
@test Compound(1minute, 3s).periods    == [63s] 
@test Compound(63.141s)                == Compound(1minute, 3s, 141ms)

@test Compound(141.592ms).periods      == [141ms, 592μs]

end # module test_timeunits_Compound
