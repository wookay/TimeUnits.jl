module test_unitful_time

using Test
using Unitful: unit, minute, s, ms

@test 3.2s == 3.2 * s == ms(3.2s) == 3200ms
@test minute(226_279.5ms) == 3.771_325minute

@test unit(3.2s)   === s
@test unit(3200ms) === ms

end # module test_unitful_time
