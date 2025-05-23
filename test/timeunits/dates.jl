module test_timeunits_dates

using Test
using Dates: Second, Millisecond, seconds, toms
using Dates: CompoundPeriod, Period

@test seconds(Millisecond(200)) === 0.2
@test toms(Millisecond(200)) === 200

@test CompoundPeriod(Second(3)) == Period(Second(3)) == Second(3)
@test CompoundPeriod(Second(3)) isa CompoundPeriod
@test CompoundPeriod(Second(3), Millisecond(200)) > CompoundPeriod(Second(3), Millisecond(100))
@test toms(CompoundPeriod(Second(3), Millisecond(200))) === 3200.0

end # module test_timeunits_dates
