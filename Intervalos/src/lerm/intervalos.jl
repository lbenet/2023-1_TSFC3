using ForwardDiff

export Intervalo, Raiz
export ⪽, hull, ⊔, ..
export intervalo_vacio, division_extendida, punto_medio, diam, esmonotona,
       ceros_newton, bisecta, minimiza, maximiza

const advertencia_intervalo_vacio = Bool[false] 

abstract type AbstractIntervalo <: Real end

@doc raw"""
    Intervalo{T <: AbstractFloat}

Un intervalo cerrado **[a, b]** donde **a** es llamado el infimo y **b** el supremo. Para que
**[a, b]** sea un intervalo, debe cumplirse que **a < b**, con la excepción del intervalo 
vacío **[Inf, -Inf]**.
"""
struct Intervalo{T <: AbstractFloat} <: AbstractIntervalo
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
    a, b, _ = promote(infimo, supremo, 0.)
    return Intervalo(a, b)
end

function Intervalo{T}(a::S) where {T, S <: Real}
    U = promote_type(T, S)
    a_ = convert(U, a)
    return Intervalo{U}(a_, a_)
end
Intervalo(a::T) where {T <: Real} = Intervalo(a, a)

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

# Intervalo vacío
import Base: isempty

@doc raw"""
    intervalo_vacio(S::Type{T}) where {T <: AbstractFloat}
    intervalo_vacio(a::Intervalo{T}) where {T <: AbstractFloat}

Regresa el intervalo vacío **[Inf, -Inf]** del tipo apropiado. 
"""
function intervalo_vacio(S::Type{T}) where {T <: AbstractFloat}
    return Intervalo{S}(S(Inf), S(-Inf))
end

intervalo_vacio(a::Intervalo{T}) where {T <: AbstractFloat} = intervalo_vacio(T)

function isempty(a::Intervalo)
    return (a.supremo < a.infimo)
end

# Intervalo cero 
import Base: zero, iszero

zero(::Type{Intervalo{T}}) where {T <: AbstractFloat} = Intervalo(zero(T), zero(T))

zero(a::Intervalo{T}) where {T <: AbstractFloat} = zero(Intervalo{T})

function iszero(a::Intervalo)
    return iszero(a.infimo) && iszero(a.supremo)
end

# Relaciones de conjuntos
import Base: ==, ⊆, ∪, ∩, ∈

function ==(a::Intervalo, b::Intervalo)
    return (a.infimo == b.infimo) && (a.supremo == b.supremo)
end

function ⊆(a::Intervalo, b::Intervalo)
    return (a.infimo ≥ b.infimo) && (a.supremo ≤ b.supremo)
end

function ⊂(a::Intervalo, b::Intervalo)
    return (a ⊆ b) && (a != b)
end

function ⪽(a::Intervalo, b::Intervalo)
    return (a.infimo > b.infimo) && (a.supremo < b.supremo)
end

function hull(a::Intervalo, b::Intervalo)
    return Intervalo(min(a.infimo, b.infimo), max(a.supremo, b.supremo))
end

const ⊔ = hull

∪(a::Intervalo, b::Intervalo) = hull(a, b)

function ∩(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    if (b.supremo < a.infimo) || (a.supremo < b.infimo)
        return intervalo_vacio(U)
    else
        return Intervalo(max(a.infimo, b.infimo), min(a.supremo, b.supremo))
    end
end

function ∈(a::T, b::Intervalo) where {T <: Real} 
    isinf(a) && return false
    return (b.infimo ≤ a ≤ b.supremo)
end

# Aritmética

import Base: +, -, *, /, inv, ^

function +(a::Intervalo, b::Intervalo)
    return Intervalo(prevfloat(a.infimo + b.infimo), nextfloat(a.supremo + b.supremo))
end

function +(a::T, b::Intervalo) where {T <: Real}
    return Intervalo(prevfloat(a + b.infimo), nextfloat(a + b.supremo))
end

+(a::Intervalo, b::T) where {T <: Real} = +(b, a)

function -(a::Intervalo, b::Intervalo)
    return Intervalo(prevfloat(a.infimo - b.supremo), nextfloat(a.supremo - b.infimo))
end

function -(a::T, b::Intervalo) where {T <: Real}
    return Intervalo(prevfloat(a - b.supremo), nextfloat(a - b.infimo))
end

function -(a::Intervalo, b::T) where {T <: Real}
    return Intervalo(prevfloat(a.infimo - b), nextfloat(a.supremo - b))
end

-(a::Intervalo) = Intervalo(-a.supremo, -a.infimo)

function *(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    ( isempty(a) || isempty(b) ) && return intervalo_vacio(U)
    ( iszero(a) || iszero(b) ) && return zero(Intervalo{U})
    x = (a.infimo * b.infimo, a.infimo * b.supremo, a.supremo * b.infimo, a.supremo * b.supremo)
    return Intervalo(prevfloat(minimum(x)), nextfloat(maximum(x)))
end

function *(a::T, b::S) where {T <: Real, S <: AbstractIntervalo}
    x = a * b.infimo
    y = a * b.supremo
    return Intervalo(prevfloat(min(x, y)), nextfloat(max(x, y)))
end

*(a::T, b::S) where {T <: AbstractIntervalo, S <: Real} = *(b, a)

function /(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    ( isempty(a) || isempty(b) || iszero(b)) && return intervalo_vacio(U)
    if 0 ∉ b
        x = (a.infimo / b.infimo, a.infimo / b.supremo, a.supremo / b.infimo, a.supremo / b.supremo)
        return Intervalo(prevfloat(minimum(x)), nextfloat(maximum(x)))
    elseif b.infimo < 0 < b.supremo
        return Intervalo(U(-Inf), U(Inf))
    else
        return division_extendida(a, b)[1]
    end
end

function /(a::T, b::Intervalo) where {T <: Real}
    return Intervalo(a, a) / b
end

function inv(b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(one(T), one(T)) / b
end

# Potencias enteras 

function ^(a::Intervalo{T}, b::Int) where {T <: AbstractFloat}

    isempty(a) && return intervalo_vacio(a)

    if b == 1
        return a
    else
        x, y = minmax(a.infimo^b, a.supremo^b)
        
        if iseven(b)
            if 0 ∈ a
                return Intervalo(zero(T), nextfloat(y))
            else
                return Intervalo(prevfloat(x), nextfloat(y)) ∩ Intervalo(zero(T), T(Inf))
            end
        else
            return Intervalo(prevfloat(x), nextfloat(y))
        end
    end
end

# División extendida

@doc raw"""
    division_extendida(a::Intervalo{T}, b:: Intervalo{S}) where {T, S <: AbstractFloat}

Regresa una tupla de dos intervalos que corresponde a la división extendida de **a** y **b**.
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

# Fancy print
import Base: show

const infs = ["∞", "-∞"]

function inf_string(x::T) where {T <: AbstractFloat}
    (x == T(Inf)) && return infs[1]
    (x == T(-Inf)) && return infs[2]
    return string(x)
end

function show(io::IO, a::Intervalo)
    a1 = inf_string(a.infimo)
    a2 = inf_string(a.supremo)
    print(io, "[", a1, ", ", a2, "]")
end

@doc raw"""
    punto_medio(a::Intervalo)

Regresa el punto medio del intervalo **a**.
"""
function punto_medio(a::Intervalo)
    return (a.infimo + a.supremo) / 2
end

@doc raw"""
    diam(a::Intervalo)

Regresa la longitud del intervalo **a**.
"""
function diam(a::Intervalo)
    return a.supremo - a.infimo
end

@doc raw"""
    esmonotona(f::Function, D::Intervalo)

Verifica si la función **f** es monótona en el intervalo **D** o no. 
"""
function esmonotona(f::Function, D::Intervalo)
    return 0 ∉ ForwardDiff.derivative(f, D)
end

include("raices.jl")
include("optimizacion.jl")