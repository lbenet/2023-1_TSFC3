# Abreviación del nombre de la paquetería 
const CI = CuadraturaIntervalos

# Mostrar o no advertencias por intervalo vacío 
const advertencia_intervalo_vacio = Bool[false] 

@doc raw"""
    advertencias(x::Bool)

Activa (`true`) o desactiva (`false`) las advertencias por intervalo vacío.
"""
function advertencias(x::Bool)
    advertencia_intervalo_vacio[] = x
end

# Modo de redondeo 
const redondeo_avanzado = Bool[true]

@doc raw"""
    redondeo(x::Bool)

Cambia el modo de redondeo entre avanzado (`true`) o simple (`false`). El redonde avanzado sólo
está disponible para `Float32` y `Float64`.
"""
function redondeo(x::Bool)
    redondeo_avanzado[] = x
end

const NonSysFloat = Union{Float16, BigFloat}

abstract type AbstractIntervalo{T} <: Real end

@doc raw"""
    Intervalo{T <: AbstractFloat}

Un intervalo cerrado `[a, b]` donde `a` es llamado el ínfimo y `b` el supremo. Para que
`[a, b]` sea un intervalo, debe cumplirse que `a < b`, con la excepción del intervalo 
vacío `[∞, -∞]`.
"""
struct Intervalo{T <: AbstractFloat} <: AbstractIntervalo{T}
    infimo::T
    supremo::T
    # Constructor interno 
    function Intervalo{T}(infimo::T, supremo::T; warn = advertencia_intervalo_vacio[1]) where {T <: AbstractFloat}
        (infimo ≤ supremo) && return new{T}(infimo, supremo)
        warn && @warn("No se cumple que infimo ($infimo) < supremo ($supremo), regresando el intervalo vacío")
        return new{T}(T(Inf), T(-Inf))
    end
end

# Constructores externos

Intervalo(infimo::T, supremo::T) where {T <: AbstractFloat} = Intervalo{T}(infimo, supremo)

function Intervalo(infimo::T, supremo::S) where {T, S <: Real} 
    # Para asegurarnos de que siempre estamos trabajando con floats
    a, b = promote(float(infimo), float(supremo))
    return Intervalo(a, b)
end

Intervalo(a::T) where {T <: Real} = Intervalo(a, a)

# Métodos para irracionales 
Intervalo(a::Irrational, b::Irrational) = Intervalo(Float64(a, RoundDown), Float64(b, RoundUp))
Intervalo(a::Irrational, b::T) where {T <: Real} = Intervalo(Float64(a, RoundDown), b)
Intervalo(a::T, b::Irrational) where {T <: Real} = Intervalo(a, Float64(b, RoundUp))

function Intervalo{T}(a::S) where {T <: AbstractFloat, S <: Real}
    U = promote_type(T, S)
    a_ = convert(U, a)
    return Intervalo{U}(a_, a_)
end

function ..(infimo::T, supremo::S) where {T, S <: Real} 
    return Intervalo(infimo, supremo)
end

# Promoción
import Base: promote

function promote(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    a1 = U(a.infimo)
    a2 = U(a.supremo)
    b1 = U(b.infimo)
    b2 = U(b.supremo)
    return Intervalo(a1, a2), Intervalo(b1, b2)
end

function promote(a::T, b::Intervalo{S}) where {T <: Real, S <: AbstractFloat}
    U = promote_type(T, S)
    return Intervalo{U}(a), Intervalo{U}(b.infimo, b.supremo)
end

function promote(a::Intervalo{T}, b::S) where {T <: AbstractFloat, S <: Real} 
    U = promote_type(T, S)
    return Intervalo{U}(a.infimo, a.supremo), Intervalo{U}(b)
end

# Intervalo vacío
import Base: isempty

@doc raw"""
    intervalo_vacio(S::Type{T} = Float64) where {T <: AbstractFloat}
    intervalo_vacio(a::Intervalo{T}) where {T <: AbstractFloat}

Regresa el intervalo vacío `[∞, -∞]` del tipo apropiado. 
"""
function intervalo_vacio(S::Type{T} = Float64) where {T <: AbstractFloat}
    return Intervalo{S}(S(Inf), S(-Inf))
end

intervalo_vacio(a::Intervalo{T}) where {T <: AbstractFloat} = intervalo_vacio(T)

function isempty(a::Intervalo)
    return (a.supremo < a.infimo)
end

# Intervalos infinitos
import Base: isfinite

isfinite(a::Intervalo) = isfinite(a.infimo) && isfinite(a.supremo)

# Intervalo cero 
import Base: zero, iszero

zero(::Type{Intervalo{T}}) where {T <: AbstractFloat} = Intervalo(zero(T), zero(T))

zero(a::Intervalo{T}) where {T <: AbstractFloat} = zero(Intervalo{T})

function iszero(a::Intervalo)
    return iszero(a.infimo) && iszero(a.supremo)
end

# Impresión bonita 
import Base: show

const infs = ["∞", "-∞"]

function inf_string(x::T) where {T <: AbstractFloat}
    (x == T(Inf)) && return infs[1]
    (x == T(-Inf)) && return infs[2]
    return string(x)
end

function show(io::IO, a::Intervalo)
    if isempty(a)
        print(io, "∅")
    else    
        a1 = inf_string(a.infimo)
        a2 = inf_string(a.supremo)
        print(io, "[", a1, ", ", a2, "]")
    end
end

# Relaciones de conjuntos
import Base: ==, ⊆, ≤, ∈, ∪, ∩, abs

function ==(a::Intervalo, b::Intervalo)
    isempty(a) && isempty(b) && return true
    return (a.infimo == b.infimo) && (a.supremo == b.supremo)
end

function ⊆(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    return (a.infimo ≥ b.infimo) && (a.supremo ≤ b.supremo)
end

function ⊂(a::Intervalo, b::Intervalo)
    a == b && return false
    return a ⊆ b
end

function ⪽(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    return (a.infimo > b.infimo) && (a.supremo < b.supremo)
end

function ≤(a::Intervalo, b::Intervalo)
    (isempty(a) && isempty(b)) && return true
    (isempty(a) || isempty(b)) && return false
    return (a.infimo ≤ b.infimo) && (a.supremo ≤ b.supremo)
end

function ∈(a::T, b::Intervalo) where {T <: Real} 
    isinf(a) && return false
    return (b.infimo ≤ a ≤ b.supremo)
end

@doc raw"""
    hull(a::Intervalo, b::Intervalo)
    ⊔(a::Intervalo, b::Intervalo)
    ∪(a::Intervalo, b::Intervalo)

Regresa el intervalo más pequeño que contiene tanto a `a` como a `b`. 
"""
hull(a::Intervalo, b::Intervalo) = Intervalo(min(a.infimo, b.infimo), max(a.supremo, b.supremo))

const ⊔ = hull

∪(a::Intervalo, b::Intervalo) = hull(a, b)

∩(a::Intervalo, b::Intervalo) = Intervalo(max(a.infimo, b.infimo), min(a.supremo, b.supremo))

@doc raw"""
    rad(a::Intervalo)

Regresa el radio del intervalo `a`.
"""
function rad(a::Intervalo{T}) where {T <: AbstractFloat}
    isempty(a) && return convert(T, NaN)
    return (a.supremo - a.infimo)/2
end

@doc raw"""
    diam(a::Intervalo)

Regresa la longitud del intervalo `a`.
"""
function diam(a::Intervalo{T}) where {T <: AbstractFloat} 
    isempty(a) && return convert(T, NaN)
    return a.supremo - a.infimo
end

@doc raw"""
    mid(a::Intervalo)

Regresa el punto medio del intervalo `a`.
"""
function mid(a::Intervalo{T}) where {T <: AbstractFloat}
    isempty(a) && return convert(T, NaN)
    return (a.supremo + a.infimo)/2
end

@doc raw"""
    mig(a::Intervalo)

Regresa la mignitud del intervalo `a`.
"""
function mig(a::Intervalo{T}) where {T <: AbstractFloat} 
    isempty(a) && return convert(T, NaN)
    (0 ∈ a) && return zero(T)
    return min(abs(a.infimo), abs(a.supremo))
end

@doc raw"""
    mag(a::Intervalo)

Regresa la magnitud del intervalo `a`.
"""
function mag(a::Intervalo{T}) where {T <: AbstractFloat} 
    isempty(a) && return convert(T, NaN)
    return max(abs(a.infimo), abs(a.supremo))
end

function abs(a::Intervalo)
    isempty(a) && return intervalo_vacio(a)
    return Intervalo(mig(a), mag(a))
end

# Aritmética

import Base: +, -, *, /, inv, ^

# Funciones para redondear dependiendo del modo de redondeo

for (f, g) in ( (:(add), +), (:(sub), :(-)), (:(mul), :(*)), (:(div), :(/)))

    fu = Symbol(f, :(_up))
    fd = Symbol(f, :(_down))

    @eval begin

        function $f(a::T, b::T) where {T <: AbstractFloat} 
            return $g(a, b)
        end
        
        # Redondeo avanzado (Float32 y Float64)
        function $fd(a::T, b::T, ::Val{true}) where {T <: RoundingEmulator.SysFloat}
            return $fd(a, b)
        end

        function $fu(a::T, b::T, ::Val{true}) where {T <: RoundingEmulator.SysFloat}
            return $fu(a, b)
        end

        # Redondeo simple (Float32 y Float64)

        function $fd(a::T, b::T, ::Val{false}) where {T <: RoundingEmulator.SysFloat}
            return prevfloat($f(a, b))
        end

        function $fu(a::T, b::T, ::Val{false}) where {T <: RoundingEmulator.SysFloat}
            return nextfloat($f(a, b))
        end

        # Redondeo simple (Float16 y BigFloat)

        function $fd(a::T, b::T, ::U) where {T <: NonSysFloat, U <: Union{Val{true}, Val{false}}}
            return prevfloat($f(a, b))
        end

        function $fu(a::T, b::T, ::U) where {T <: NonSysFloat, U <: Union{Val{true}, Val{false}}}
            return nextfloat($f(a, b))
        end

    end
end

+(a::Intervalo, b::Intervalo) = Intervalo(
                                    add_down(a.infimo, b.infimo, Val(redondeo_avanzado[1])),
                                    add_up(a.supremo, b.supremo, Val(redondeo_avanzado[1]))
                                )

+(a::T, b::Intervalo) where {T <: Real} = +(promote(a, b)...)

+(a::Intervalo, b::T) where {T <: Real} = +(b, a)

-(a::Intervalo, b::Intervalo) = Intervalo(
                                    sub_down(a.infimo, b.supremo, Val(redondeo_avanzado[1])),
                                    sub_up(a.supremo, b.infimo, Val(redondeo_avanzado[1]))
                                )

-(a::T, b::Intervalo) where {T <: Real} = -(promote(a, b)...)

-(a::Intervalo, b::T) where {T <: Real} = -(promote(a, b)...)

-(a::Intervalo) = Intervalo(-a.supremo, -a.infimo)

function *(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    ( isempty(a) || isempty(b) ) && return intervalo_vacio(U)
    ( iszero(a) || iszero(b) ) && return zero(Intervalo{U})
    
    left = [a.infimo, a.infimo, a.supremo, a.supremo]
    right = [b.infimo,  b.supremo,  b.infimo, b.supremo]

    for i in 1:4
        if ( isinf(left[i]) && iszero(right[i]) ) || ( iszero(left[i]) && isinf(right[i]) )
            left[i] = zero(U)
            right[i] = zero(U)
        end
    end

    return Intervalo(
        minimum(mul_down.(left, right, Val(redondeo_avanzado[1]))), 
        maximum(mul_up.(left, right, Val(redondeo_avanzado[1])))
    )
end

*(a::T, b::S) where {T <: Real, S <: AbstractIntervalo} = *(promote(a, b)...)

*(a::T, b::S) where {T <: AbstractIntervalo, S <: Real} = *(b, a)

function /(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    ( isempty(a) || isempty(b) || iszero(b)) && return intervalo_vacio(U)
    if 0 ∉ b
        left = (a.infimo, a.infimo, a.supremo, a.supremo)
        right = (b.infimo, b.supremo, b.infimo, b.supremo)
        return Intervalo(
            minimum(div_down.(left, right, Val(redondeo_avanzado[1]))), 
            maximum(div_up.(left, right, Val(redondeo_avanzado[1])))
        )
    elseif b.infimo < 0 < b.supremo
        return Intervalo(U(-Inf), U(Inf))
    else
        return division_extendida(a, b)[1]
    end
end

/(a::T, b::S) where {T <: Real, S <: AbstractIntervalo} = /(promote(a, b)...)

/(a::T, b::S) where {T <: AbstractIntervalo, S <: Real} = /(promote(a, b)...)

function inv(b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(one(T)) / b
end

# Potencias enteras 
#=
function pow_up(x::T, n::Int) where {T <: AbstractFloat}
    @assert n ≥ 0
    if n == 0
        return one(T)
    elseif n == 1
        return x
    else
        x_0 = x
        for i in 2:n
            x_0 = mul_up(x_0, x)
        end
        return x_0
    end
end

function pow_down(x::T, n::Int) where {T <: AbstractFloat}
    @assert n ≥ 0
    if n == 0
        return one(T)
    elseif n == 1
        return x
    else
        x_0 = x
        for i in 2:n
            x_0 = mul_down(x_0, x)
        end
        return x_0
    end
end

function ^(a::Intervalo{T}, n::Int) where {T <: AbstractFloat}

    isempty(a) && return intervalo_vacio(a)

    if n == 0
        return Intervalo(one(T))
    elseif n == 1
        return a
    elseif iseven(n)
        return Intervalo(
            pow_down(mig(a), n),
            pow_up(mag(a), n)
        )
    elseif isodd(n)
        return Intervalo(
            pow_down(a.infimo, n), 
            pow_up(a.supremo, n)
        )
    elseif (n < 0) && (0 ∉ a)
        return Intervalo(
            div_down(one(T), a.supremo),
            div_up(one(T), a.infimo)
        )^(-n)
    end
end
=#
# División extendida

@doc raw"""
    division_extendida(a::Intervalo{T}, b:: Intervalo{S}) where {T, S <: AbstractFloat}

Regresa una tupla de dos intervalos que corresponde a la división extendida de `a` y `b`.
Ver la sección 2.3.4 de Tucker, W. (2011). Validated Numerics. Estados Unidos: Princeton University
Press.
"""
function division_extendida(a::Intervalo{T}, b:: Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    if 0 ∉ b
        return (a / b,)
    elseif (0 ∈ a) && (0 ∈ b)
        return (Intervalo(U(-Inf), U(Inf)),)
    elseif (a.supremo < 0) && (b.infimo < b.supremo == 0)
        return (Intervalo(a.supremo / b.infimo, U(Inf)),)
    elseif (a.supremo < 0) && (b.infimo < 0 < b.supremo)
        return (Intervalo(a.supremo / b.infimo, U(Inf)), Intervalo(U(-Inf), a.supremo / b.supremo))
    elseif (a.supremo < 0) && (0 == b.infimo < b.supremo)
        return (Intervalo(U(-Inf), a.supremo / b.supremo),)
    elseif (a.infimo > 0) && (b.infimo < b.supremo == 0)
        return (Intervalo(U(-Inf), a.infimo / b.infimo),)
    elseif (a.infimo > 0) && (b.infimo < 0 < b.supremo)
        return (Intervalo(U(-Inf), a.infimo / b.infimo), Intervalo(a.infimo / b.supremo, U(Inf)))
    elseif (a.infimo > 0) && (0 == b.infimo < b.supremo)
        return (Intervalo(a.infimo / b.supremo, U(Inf)),)
    elseif (0 ∉ a) && iszero(b)
        return (intervalo_vacio(U),)
    end
end

@doc raw"""
    esmonotona(f::Function, D::Intervalo)

Verifica si la función **f** es monótona en el intervalo **D** o no. 
"""
function esmonotona(f::Function, D::Intervalo)
    return 0 ∉ ForwardDiff.derivative(f, D)
end