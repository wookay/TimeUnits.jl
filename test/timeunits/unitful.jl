module test_timeunits_unitful

using Test
using Unitful: unit, s, ms

@test 3.2s == 3200ms
@test unit(3.2s) == s
@test unit(3200ms) == ms

end # module test_timeunits_unitful
