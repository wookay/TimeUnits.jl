# module TimeUnits

using Unitful: Unitful
using .Unitful: Quantity, FreeUnits, unit
using .Unitful: d, hr, minute, s, ms, μs, ns, ps, fs, as

const fractional_si_units = (s, ms, μs, ns, ps, fs, as)

unit_base(::typeof(hr))     = 24
unit_base(::typeof(minute)) = 60
unit_base(::typeof(s))      = 60
unit_base(::typeof(ms))     = 1000
unit_base(::typeof(μs))     = 1000
unit_base(::typeof(ns))     = 1000
unit_base(::typeof(ps))     = 1000
unit_base(::typeof(fs))     = 1000
unit_base(::typeof(as))     = 1000

parent_unit(::typeof(hr))     = d
parent_unit(::typeof(minute)) = hr
parent_unit(::typeof(s))      = minute
parent_unit(::typeof(ms))     = s
parent_unit(::typeof(μs))     = ms
parent_unit(::typeof(ns))     = μs
parent_unit(::typeof(ps))     = ns
parent_unit(::typeof(fs))     = ps
parent_unit(::typeof(as))     = fs

# original code from julia/base/intfuncs.jl
# function _base(base::Integer, x::Integer, pad::Int, neg::Bool)
function base_thousand(x::Integer, neg::Bool)
    b = 1000
    (x >= 0) | (b < 0) || throw(DomainError(x, "For negative `x`, `base` must be negative."))
    pad = 0

    n10 = ndigits(x, base=10, pad=pad)
    remainder = 3 - rem(n10, 3)
    if remainder != 3
        x = x * 10 ^ remainder
    end

    n = ndigits(x, base=b, pad=pad)
    i = neg + n
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

function canonical_fractional_part(x::Int, distance::Int)::Vector{Quantity{Int}}
    neg = signbit(x)
    periods = Vector{Quantity{Int}}()
    for (i, num) in base_thousand(neg ? -x : x, neg)
        U = fractional_si_units[distance + 1 + i - neg]
        push!(periods, (num)U)
    end
    periods
end

function canonical_compound_periods(compound_periods::Vector{Quantity{Int}})::Vector{Quantity{Int}}
    one_more_time = false
    periods = Vector{Quantity{Int}}()
    for q in compound_periods
        x = q.val
        iszero(x) && continue
        U = unit(q)
        P = parent_unit(U)
        base = unit_base(U)
        if x >= base
            quotient  = div(x, base)
            remainder = rem(x, base)
            push!(periods, (quotient)P)
            if !iszero(remainder)
                push!(periods, (remainder)U)
            end
            if quotient >= unit_base(P)
                one_more_time = true
            end
        else
            push!(periods, q)
        end
    end
    if one_more_time
        canonical_compound_periods(periods)
    else
        periods
    end
end

function canonical_floating_parts(val::Float64, U::FreeUnits)::Vector{Quantity{Int}}
    integral = Int(div(val, 1))
    neg = signbit(val)
    n = neg + ndigits(integral, base=10)
    str = string(val)
    p = length(str) - n - 1
    fractional = val - integral
    x = round(Int, fractional * ^(10, p))
    compound_periods = Vector{Quantity{Int}}()
    if !neg && integral > 0
        push!(compound_periods, (integral)U)
    elseif neg && integral < 0
        push!(compound_periods, (integral)U)
    end
    if !iszero(x)
        distance = ndigits(U(1s).val, base=1000) - 1
        part = canonical_fractional_part(x, distance)
        append!(compound_periods, part)
    end
    canonical_compound_periods(compound_periods)
end

function canonical_floating_parts(r::Rational{Int}, U::FreeUnits)::Vector{Quantity{Int}}
    canonical_floating_parts(Float64(r), U)
end

struct Compound{T}
    periods::Vector{Quantity{T}}
    function Compound(q::Quantity{Float64})
        periods = canonical_floating_parts(q.val, unit(q))
        if isempty(periods)
            new{Int}([0s])
        else
            new{Int}(periods)
        end
    end
    function Compound(qs::Quantity{Int}...)
        if isempty(qs)
            new{Int}([])
        else
            compound_periods = Vector{Quantity{Int}}(collect(qs))
            periods = canonical_compound_periods(compound_periods)
            if length(qs) == 1 && isempty(periods)
                new{Int}([0s])
            else
                new{Int}(periods)
            end
        end
    end
    function Compound{T}(periods::Vector{Quantity{T}}) where T
        new{T}(periods)
    end
end

function Base.:(==)(lhs::Compound{T}, rhs::Compound{T}) where T
    lhs.periods == rhs.periods
end

# module TimeUnits
