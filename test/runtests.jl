using Base.Test, Nulls

@testset "Nulls" begin

    # test promote rules
    @test promote_type(Null, Null) == Null
    @test promote_type(Null, Int) == Union{Null, Int}
    @test promote_type(Int, Null) == Union{Null, Int}
    @test promote_type(Int, Any) == Any
    @test promote_type(Any, Any) == Any
    @test promote_type(Null, Any) == Any
    @test promote_type(Any, Null) == Any
    @test promote_type(Union{Int, Null}, Null) == Union{Int, Null}
    @test promote_type(Null, Union{Int, Null}) == Union{Int, Null}
    @test promote_type(Union{Int, Null}, Int) == Union{Int, Null}
    @test promote_type(Int, Union{Int, Null}) == Union{Int, Null}
    @test promote_type(Any, Union{Int, Null}) == Any
    @test promote_type(Union{Int, Null}, Union{Int, Null}) == Union{Int, Null}
    @test promote_type(Union{Float64, Null}, Union{String, Null}) == Any
    @test promote_type(Union{Float64, Null}, Union{Int, Null}) == Union{Float64, Null}
    @test promote_type(Union{Void, Null, Int}, Float64) == Any

    bit_operators = [&, |, ⊻]

    arithmetic_operators = [+, -, *, /, ^, Base.div, Base.mod, Base.fld, Base.rem]

    elementary_functions = [abs, abs2, sign,
                            acos, acosh, asin, asinh, atan, atanh, sin, sinh,
                            conj, cos, cosh, tan, tanh,
                            exp, exp2, expm1, log, log10, log1p, log2,
                            exponent, sqrt, gamma, lgamma,
                            identity, zero,
                            iseven, isodd, ispow2,
                            isfinite, isinf, isnan, iszero,
                            isinteger, isreal, isimag,
                            isempty, transpose, ctranspose]

    rounding_functions = [ceil, floor, round, trunc]

    # All unary operators return null when evaluating null
    for f in [!, +, -]
        @test isnull(f(null))
    end

    # All elementary functions return null when evaluating null
    for f in elementary_functions
        @test isnull(f(null))
    end

    # All rounding functions return null when evaluating null as first argument
    for f in rounding_functions
        @test isnull(f(null))
        @test isnull(f(null, 1))
        @test isnull(f(null, 1, 1))
        @test isnull(f(Union{Int, Null}, null))
        @test_throws NullException f(Int, null)
    end

    @test zero(Union{Int, Null}) === 0
    @test zero(Union{Float64, Null}) === 0.0

    for T in (subtypes(Dates.DatePeriod)...,
              subtypes(Dates.TimePeriod)...)
        @test zero(Union{T, Null}) === T(0)
    end

    # Comparison operators
    @test (null == null) === null
    @test (1 == null) === null
    @test (null == 1) === null
    @test (null != null) === null
    @test (1 != null) === null
    @test (null != 1) === null
    @test isequal(null, null)
    @test !isequal(1, null)
    @test !isequal(null, 1)
    @test (null < null) === null
    @test (null < 1) === null
    @test (1 < null) === null
    @test (null <= null) === null
    @test (null <= 1) === null
    @test (1 <= null) === null
    @test !isless(null, null)
    @test !isless(null, 1)
    @test isless(1, null)

    # All arithmetic operators return null when operating on two null's
    # All arithmetic operators return null when operating on a scalar and an null
    # All arithmetic operators return null when operating on an null and a scalar
    for f in arithmetic_operators
        @test isnull(f(null, null))
        @test isnull(f(1, null))
        @test isnull(f(null, 1))
    end

    # All bit operators return null when operating on two null's
    for f in bit_operators
        @test isnull(f(null, null))
    end

    @test isnull(null & true)
    @test isnull(true & null)
    @test !(null & false)
    @test !(false & null)
    @test isnull(null | false)
    @test isnull(false | null)
    @test null | true
    @test true | null
    @test isnull(xor(null, true))
    @test isnull(xor(true, null))
    @test isnull(xor(null, false))
    @test isnull(xor(false, null))

    @test isnull(null & 1)
    @test isnull(1 & null)
    @test isnull(null | 1)
    @test isnull(1 | null)
    @test isnull(xor(null, 1))
    @test isnull(xor(1, null))

    @test isnull("a" * null)
    @test isnull(null * "a")

    @test sprint(show, null) == "null"

    x = Nulls.replace([1, 2, null, 4], 3)
    @test eltype(x) === Int
    @test length(x) == 4
    @test size(x) == (4,)
    @test collect(x) == collect(1:4)
    @test collect(x) isa Vector{Int}
    x = Nulls.replace([1, 2, null, 4], 3.0)
    @test eltype(x) === Int
    @test length(x) == 4
    @test size(x) == (4,)
    @test collect(x) == collect(1:4)
    @test collect(x) isa Vector{Int}
    x = Nulls.replace([1 2; null 4], 3)
    @test eltype(x) === Int
    @test length(x) == 4
    @test size(x) == (2, 2)
    @test collect(x) == [1 2; 3 4]
    @test collect(x) isa Matrix{Int}
    x = Nulls.replace((v for v in [null, 1, null, 2, 4]), 0)
    @test length(x) == 5
    @test size(x) == (5,)
    @test eltype(x) === Any
    @test collect(x) == [0, 1, 0, 2, 4]
    @test collect(x) isa Vector{Int}

    x = Nulls.fail([1, 2, 3, 4])
    @test eltype(x) === Int
    @test length(x) == 4
    @test size(x) == (4,)
    @test collect(x) == [1, 2, 3, 4]
    @test collect(x) isa Vector{Int}
    x = Nulls.fail([1 2; 3 4])
    @test eltype(x) === Int
    @test length(x) == 4
    @test size(x) == (2, 2)
    @test collect(x) == [1 2; 3 4]
    @test collect(x) isa Matrix{Int}
    @test_throws NullException collect(Nulls.fail([1, 2, null, 4]))
    x = Nulls.fail(v for v in [1, 2, 4])
    @test eltype(x) === Any
    @test length(x) == 3
    @test size(x) == (3,)
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Int}

    x = Nulls.skip([1, 2, null, 4])
    @test eltype(x) === Int
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Int}
    x = Nulls.skip([1  2; null 4])
    @test eltype(x) === Int
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Int}
    x = collect(Nulls.skip([null]))
    @test eltype(x) === Union{}
    @test isempty(collect(x))
    @test collect(x) isa Vector{Union{}}
    x = collect(Nulls.skip(Union{Int, Null}[]))
    @test eltype(x) === Int
    @test isempty(collect(x))
    @test collect(x) isa Vector{Int}
    x = Nulls.skip([null, null, 1, 2, null, 4, null, null])
    @test eltype(x) === Int
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Int}
    x = Nulls.skip(v for v in [null, 1, null, 2, 4])
    @test eltype(x) === Any
    @test collect(x) == [1, 2, 4]
    @test collect(x) isa Vector{Int}

    @test Nulls.coalesce(null, 1) === 1
    @test Nulls.coalesce(1, null) === 1
    @test Nulls.coalesce(null, null) === null
    @test Nulls.coalesce.([null, 1, null], 0) == [0, 1, 0]
    @test Nulls.coalesce.([null, 1, null], 0) isa Vector{Int}
    @test Nulls.coalesce.([null, 1, null], [0, 10, 5]) == [0, 1, 5]
    @test Nulls.coalesce.([null, 1, null], [0, 10, 5]) isa Vector{Int}
    @test isequal(Nulls.coalesce.([null, 1, null], [0, null, null]), [0, 1, null])
    # Fails in Julia 0.6 and 0.7.0-DEV.1556
    @test_broken Nulls.coalesce.([null, 1, null], [0, null, null]) isa Vector{Union{Null, Int}}

    @test levels(1:1) == levels([1]) == levels([1, null]) == levels([null, 1]) == [1]
    @test levels(2:-1:1) == levels([2, 1]) == levels([2, null, 1]) == [1, 2]
    @test levels([null, "a", "c", null, "b"]) == ["a", "b", "c"]
    @test levels([Complex(0, 1), Complex(1, 0), null]) == [Complex(0, 1), Complex(1, 0)]
    @test levels(sparse([0 3 2])) == [0, 2, 3]
    @test typeof(levels([1])) === typeof(levels([1, null])) === Vector{Int}
    @test typeof(levels(["a"])) === typeof(levels(["a", null])) === Vector{String}
    @test typeof(levels(sparse([1]))) === Vector{Int}
    @test isempty(levels([null]))
    @test isempty(levels([]))

    x = convert(Vector{Union{Int, Null}}, [1.0, null])
    @test isa(x, Vector{Union{Int, Null}})
    @test isequal(x, [1, null])
    x = convert(Vector{Union{Int, Null}}, [1.0])
    @test isa(x, Vector{Union{Int, Null}})
    @test x == [1]
    x = convert(Vector{Union{Int, Null}}, [null])
    @test isa(x, Vector{Union{Int, Null}})
    @test isequal(x, [null])

    @test Nulls.T(Union{Int, Null}) == Int
    @test Nulls.T(Any) == Any
    @test Nulls.T(Null) == Union{}

    @test isequal(nulls(1), [null])
    @test isequal(nulls(Int, 1), [null])
    @test nulls(Int, 1) isa Vector{Union{Int, Null}}
    @test isequal(nulls(Union{Int, Null}, 1, 2), [null null])
    @test nulls(Union{Int, Null}, 1, 2) isa Matrix{Union{Int, Null}}
    @test Union{Int, Null}[1,2,3] == (Union{Int, Null})[1,2,3]

    @test convert(Union{Int, Null}, 1.0) == 1

    # AbstractArray{>:Null}

    @test isnull([1, null] == [1, null])
    @test isnull(["a", null] == ["a", null])
    @test isnull(Any[1, null] == Any[1, null])
    @test isnull(Any[null] == Any[null])
    @test isnull([null] == [null])
    @test isnull(Any[null, 2] == Any[1, null])
    @test isnull([null, false] == BitArray([true, false]))
    @test isnull(Any[null, false] == BitArray([true, false]))
    @test Union{Int, Null}[1] == Union{Float64, Null}[1.0]
    @test Union{Int, Null}[1] == [1.0]
    @test Union{Bool, Null}[true] == BitArray([true])
    @test !(Union{Int, Null}[1] == [2])
    @test !([1] == Union{Int, Null}[2])
    @test !(Union{Int, Null}[1] == Union{Int, Null}[2])

    @test isnull([1, null] != [1, null])
    @test isnull(["a", null] != ["a", null])
    @test isnull(Any[1, null] != Any[1, null])
    @test isnull(Any[null] != Any[null])
    @test isnull([null] != [null])
    @test isnull(Any[null, 2] != Any[1, null])
    @test isnull([null, false] != BitArray([true, false]))
    @test isnull(Any[null, false] != BitArray([true, false]))
    @test !(Union{Int, Null}[1] != Union{Float64, Null}[1.0])
    @test !(Union{Int, Null}[1] != [1.0])
    @test !(Union{Bool, Null}[true] != BitArray([true]))
    @test Union{Int, Null}[1] != [2]
    @test [1] != Union{Int, Null}[2]
    @test Union{Int, Null}[1] != Union{Int, Null}[2]

    @test any([true, null])
    @test any(x -> x == 1, [1, null])
    @test isnull(any([false, null]))
    @test isnull(any(x -> x == 1, [2, null]))
    @test isnull(all([true, null]))
    @test isnull(all(x -> x == 1, [1, null]))
    @test !all([false, null])
    @test !all(x -> x == 1, [2, null])
    @test 1 in [1, null]
    @test isnull(2 in [1, null])
    @test isnull(null in [1, null])
end
