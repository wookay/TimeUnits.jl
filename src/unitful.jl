# module TimeUnits

using Unitful: Unitful
using .Unitful: Quantity, unit
using .Unitful: s, ms, μs, ns, ps, fs, as

const fractional_si_units = (s, ms, μs, ns, ps, fs, as)

# original code from julia/base/intfuncs.jl
# function _base(base::Integer, x::Integer, pad::Int, neg::Bool)
function base_thousand(x::Integer, neg::Bool)
    b = 1000
    (x >= 0) | (b < 0) || throw(DomainError(x, "For negative `x`, `base` must be negative."))
    pad = 0
    n = neg + ndigits(x, base=b, pad=pad)
    i = n
    unit_nums = []
    @inbounds while i > neg
        if b > 0
            num = (rem(x, b) % Int)::Int
            x = div(x, b)
        else
            num = (mod(x, -b) % Int)::Int
            x = cld(x, b)
        end
        pushfirst!(unit_nums, (i, neg ? -num : num))
        i -= 1
    end
    unit_nums
end

function canonical_fractional_part(x::Int)::Vector{Quantity{Int}}
    neg = signbit(x)
    periods = Vector{Quantity{Int}}()
    for (i, num) in base_thousand(neg ? -x : x, neg)
        unit = fractional_si_units[1 + i - neg]
        push!(periods, (num)unit)
    end
    periods
end

# s
function canonical_floating_parts(val::Float64)::Vector{Quantity{Int}}
    integral = Int(div(val, 1))
    neg = signbit(val)
    n = neg + ndigits(integral, base=10)
    str = string(val)
    p = length(str) - n - 1
    fractional = val - integral
    x = round(Int, fractional * ^(10, p))
    periods = Vector{Quantity{Int}}()
    if !neg && integral >= 0
        push!(periods, (integral)s)
    elseif neg && integral < 0
        push!(periods, (integral)s)
    end
    if !iszero(x)
        part = canonical_fractional_part(x)
        append!(periods, part)
    end
    periods
end

function canonical_floating_parts(r::Rational{Int})::Vector{Quantity{Int}}
    canonical_floating_parts(Float64(r))
end

struct Compound{T}
    periods::Vector{Quantity{T}}
    function Compound(q::Quantity{Float64})
        periods = canonical_floating_parts(q)
        new{Int}(periods)
    end
    function Compound(qs::Quantity{Int}...)
        val = sum(q -> s(q).val, qs)
        if iszero(val)
            new{Int}([0s])
        elseif val isa Int
            new{Int}([(val)s])
        else
            periods = canonical_floating_parts(val)
            new{Int}(periods)
        end
    end
    function Compound{T}(periods::Vector{Quantity{T}}) where T
        new{T}(periods)
    end
end

function shift_down(compound::Vector{Quantity{Int}}, down::Int)::Vector{Quantity{Int}}
    periods = Vector{Quantity{Int}}()
    for q in compound
        u = unit(q)
        unit_index = findfirst(x -> x === u, fractional_si_units)
        down_u = fractional_si_units[unit_index + down]
        push!(periods, (q.val)down_u)
    end
    return periods
end

function canonical_floating_parts(q::Quantity{Float64})::Vector{Quantity{Int}}
    u = unit(q)
    if u === s
        canonical_floating_parts(q.val)
    else
        unit_index = findfirst(x -> x === u, fractional_si_units)
        periods = canonical_floating_parts(q.val)
        shift_down(periods, unit_index - 1)
    end
end

function Base.:(==)(lhs::Compound{T}, rhs::Compound{T}) where T
    lhs.periods == rhs.periods
end

# module TimeUnits
