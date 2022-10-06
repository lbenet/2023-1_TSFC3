@doc raw"""
    Intervalo{T <: AbstractFloat}

Un intervalo cerrado **[a, b]** donde **a** es llamado el infimo y **b** el supremo. Para que
**[a, b]** sea un intervalo, debe cumplirse que **a < b**, con la excepción del intervalo 
vacío **[Inf, -Inf]**.
"""
struct Intervalo{T <: AbstractFloat}
    infimo::T
    supremo::T
    # Constructor interno 
    function Intervalo{T}(infimo::T, supremo::T; warn = true) where {T <: AbstractFloat}
        infimo ≤ supremo && return new{T}(infimo, supremo)
        if warn
            @warn("No se cumple que infimo ($infimo) < supremo ($supremo), regresando el intervalo vacío")
        end
        return new{T}(convert(T, Inf), convert(T, -Inf))
    end
end

# Constructores externos
Intervalo(infimo::T, supremo::T) where {T <: AbstractFloat} = Intervalo{T}(infimo, supremo)
function Intervalo(infimo::T, supremo::S) where {T, S <: Real} 
    a, b, c = promote(infimo, supremo, 0.)
    return Intervalo(a, b)
end
Intervalo(a::T) where {T <: AbstractFloat} = Intervalo(a, a)

function ..(infimo::T, supremo::S) where {T, S <: Real} 
    return Intervalo(infimo, supremo)
end

# Promoción
import Base: promote, zero, iszero, isempty

function promote(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    a1 = convert(U, a.infimo)
    a2 = convert(U, a.supremo)
    b1 = convert(U, b.infimo)
    b2 = convert(U, b.supremo)
    return Intervalo(a1, a2), Intervalo(b1, b2)
end

function promote(a::T, b::Intervalo{S}) where {T, S <: AbstractFloat}
    U = promote_type(T, S)
    a_ = convert(U, a)
    b1 = convert(U, b.infimo)
    b2 = convert(U, b.supremo)
    return a_, Intervalo{U}(b1, b2; warn = false)
end

# Intervalo vacío
intervalo_vacio(T::Type{S}) where {S <: AbstractFloat} = Intervalo{T}(convert(T, Inf), convert(T, -Inf); warn = false)
intervalo_vacio(a::Intervalo{T}) where {T <: AbstractFloat} = intervalo_vacio(T)
isempty(a::Intervalo{T}) where {T <: AbstractFloat} = a.infimo == convert(T, Inf) && a.supremo == convert(T, -Inf)

# Intervalo cero 
zero(::Type{Intervalo{T}}) where {T <: AbstractFloat} = Intervalo(zero(T), zero(T))
iszero(a::Intervalo{T}) where {T <: AbstractFloat} = a.infimo == zero(T) && a.supremo == zero(T)

# Relaciones de conjuntos
import Base: ==, ⊆, ∪, ∩, ∈

function ==(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return a.infimo == b.infimo && a.supremo == b.supremo
end

function ⊆(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return a.infimo ≥ b.infimo && a.supremo ≤ b.supremo
end

function ⊂(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return a ⊆ b && a != b
end

function ⪽(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return a.infimo > b.infimo && a.supremo < b.supremo
end

function hull(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(min(a.infimo, b.infimo), max(a.supremo, b.supremo))
end

const ⊔ = hull

∪(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat} = hull(a, b)

function ∩(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    if b.supremo < a.infimo || a.supremo < b.infimo
        return intervalo_vacio(T)
    else
        return Intervalo(max(a.infimo, b.infimo), min(a.supremo, b.supremo))
    end
end

∈(a::T, b::Intervalo{T}) where {T <: AbstractFloat} = (b.infimo ≤ a ≤ b.supremo)

# Aritmética

import Base: +, -, *, /, inv, ^

function +(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(prevfloat(a.infimo + b.infimo), nextfloat(a.supremo + b.supremo))
end

function +(a::T, b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(prevfloat(a + b.infimo), nextfloat(a + b.supremo))
end

function -(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(prevfloat(a.infimo - b.supremo), nextfloat(a.supremo - b.infimo))
end

function -(a::T, b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(prevfloat(a - b.supremo), nextfloat(a - b.infimo))
end

function -(a::Intervalo{T}, b::T) where {T <: AbstractFloat}
    return Intervalo(prevfloat(a.infimo - b), nextfloat(a.supremo - b))
end

-(a::Intervalo{T}) where {T, S <: AbstractFloat} = Intervalo(-a.supremo, -a.infimo)

function *(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    ( isempty(a) || isempty(b) ) && return intervalo_vacio(T)
    ( iszero(a) || iszero(b) ) && return zero(Intervalo{T})
    x = (a.infimo * b.infimo, a.infimo * b.supremo, a.supremo * b.infimo, a.supremo * b.supremo)
    return Intervalo(prevfloat(minimum(x)), nextfloat(maximum(x)))
end

function *(a::T, b::Intervalo{T}) where {T <: AbstractFloat}
    x = a * b.infimo
    y = a * b.supremo
    return Intervalo(prevfloat(min(x, y)), nextfloat(max(x, y)))
end

function /(a::Intervalo{T}, b::Intervalo{T}) where {T <: AbstractFloat}
    if 0 ∉ b
        ( isempty(a) || isempty(b) ) && return intervalo_vacio(T)
        x = (a.infimo / b.infimo, a.infimo / b.supremo, a.supremo / b.infimo, a.supremo / b.supremo)
        return Intervalo(prevfloat(minimum(x)), nextfloat(maximum(x)))
    elseif iszero(b)
        return intervalo_vacio(T)
    elseif b.infimo < 0 < b.supremo
        return Intervalo(convert(T, -Inf), convert(T, Inf))
    else
        return division_extendida(a, b)[1]
    end
end

function /(a::T, b::Intervalo{S}) where {T <: Real, S <: AbstractFloat}
    return Intervalo(a, a) / b
end

function inv(b::Intervalo{T}) where {T <: AbstractFloat}
    return Intervalo(one(T), one(T)) / b
end

for op ∈ (:(==), :(⊆), :(⊂), :(⪽), :(hull), :(∪), :(∩), :(+), :(-), :(*), :(/))
    @eval begin

        function $op(a::Intervalo{T}, b::Intervalo{S}) where {T, S <: AbstractFloat}
            a_, b_ = promote(a, b)
            return $op(a_, b_)
        end

    end
end 

for op ∈ (:(∈), :(+), :(-), :(*))
    @eval begin

        function $op(a::T, b::Intervalo{S}) where {T <: Real, S <: AbstractFloat}
            a_, b_ = promote(a, b)
            return $op(a_, b_)
        end

        if $op == :(-)
            function $op(a::Intervalo{T}, b::S) where {T <: AbstractFloat, S <: Real}
                a_, b_ = promote(a, b)
                return $op(a_, b_)
            end
        elseif $op != :(∈)
            $op(a::Intervalo{T}, b::S) where {T <: AbstractFloat, S <: Real} = $op(b, a)
        end

    end
end 

# Potencias enteras 

function ^(a::Intervalo{T}, b::Int) where {T <: AbstractFloat}

    isempty(a) && return intervalo_vacio(T)

    if b == 1
        return a
    else
        x, y = minmax(a.infimo^b, a.supremo^b)
        
        if iseven(b)
            if 0 ∈ a
                return Intervalo(0, nextfloat(y))
            else
                return Intervalo(prevfloat(x), nextfloat(y)) ∩ Intervalo(0, Inf)
            end
        else
            return Intervalo(prevfloat(x), nextfloat(y))
        end
    end
end

# División estendida

function division_extendida(a::Intervalo{T}, b:: Intervalo{T}) where {T <: AbstractFloat}
    if 0 ∉ b
        return (a / b,)
    elseif (0 ∈ a) && (0 ∈ b)
        return (Intervalo(convert(T, -Inf), convert(T, Inf)),)
    elseif (a.supremo < 0) && (b.infimo < b.supremo == 0)
        return (Intervalo(a.supremo / b.infimo, convert(T, Inf)),)
    elseif (a.supremo < 0) && (b.infimo < 0 < b.supremo)
        return (Intervalo(a.supremo / b.infimo, convert(T, Inf)), Intervalo(convert(T, -Inf), a.supremo / b.supremo))
    elseif (a.supremo < 0) && (0 == b.infimo < b.supremo)
        return (Intervalo(convert(T, -Inf), a.supremo / b.supremo),)
    elseif (a.infimo > 0) && (b.infimo < b.supremo == 0)
        return (Intervalo(convert(T, -Inf), a.infimo / b.infimo),)
    elseif (a.infimo > 0) && (b.infimo < 0 < b.supremo)
        return (Intervalo(convert(T, -Inf), a.infimo / b.infimo), Intervalo(a.infimo / b.supremo, convert(T, Inf)))
    elseif (a.infimo > 0) && (0 == b.infimo < b.supremo)
        return (Intervalo(a.infimo / b.supremo, convert(T, Inf)),)
    elseif (0 ∉ a) && iszero(b)
        return (intervalo_vacio(T),)
    end
end


import Base: show

show(io::IO, a::Intervalo{T}) where {T <: AbstractFloat} = print(io, "[", a.infimo, ", ", a.supremo, "]")

export Intervalo, ..
export intervalo_vacio, ⪽, hull, ⊔
export division_extendida