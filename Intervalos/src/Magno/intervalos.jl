import Base: ==, isempty,⊆, ∪, ∩, ∈, ∉, +, -, *, ^, iszero, /, inv

export Intervalo, intervalo_vacio, ⪽, ⊔, division_extendida

struct Intervalo{T<:Real}
    infimo::T
    supremo::T
    
    function Intervalo(infimo,supremo)
        infimo1, supremo1, _ = promote(infimo, supremo, 1.0) 
        infimo1 > supremo1  ? error("Supremo es menor que el ínfimo") : new{typeof(infimo1)}(infimo1,supremo1)
    end
end

Intervalo(infimo) = Intervalo(infimo,infimo)

function intervalo_vacio(T::Type)
    return Intervalo(T(NaN))
end

function intervalo_vacio(a::Intervalo{T}) where T <: Real
return intervalo_vacio(T)
end

function isempty(a::Intervalo)
    isnan(a.infimo) && isnan(a.supremo) && return true
    return false 
end

function ==(a::Intervalo, b::Intervalo)
    isempty(a) && isempty(b) && return true
    a.infimo == b.infimo && a.supremo == b.supremo
end

function ⊆(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    b.infimo ≤ a.infimo && a.supremo ≤ b.supremo
end

function ⪽(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    b.infimo < a.infimo && a.supremo < b.supremo
end

function ∪(a::Intervalo, b::Intervalo)
    isempty(a) && return(b)
    isempty(b) && return(a)
    return Intervalo(min(a.infimo,b.infimo),max(a.supremo,b.supremo))
end

function ⊔(a::Intervalo, b::Intervalo)
    return a∪b 
end

function ∩(a::Intervalo, b::Intervalo)
    isempty(a) && return a
    isempty(b) && return b
    b.supremo < a.infimo && return Intervalo(NaN)
    a.supremo < b.infimo && return Intervalo(NaN)
    return Intervalo(max(a.infimo,b.infimo),min(a.supremo,b.supremo))
end

function ∈(a::Real, b::Intervalo)
    isinf(a) && return false
    b.infimo ≤ a ≤ b.supremo
end 

function +(a::Intervalo, b::Intervalo)
    return Intervalo(prevfloat(a.infimo + b.infimo), nextfloat(a.supremo + b.supremo))
end
    
function +(a::Real, b::Intervalo)
    return Intervalo(a) + b
end
    
function +(a::Intervalo, b::Real)
    return a + Intervalo(b)
end

function -(a::Intervalo, b::Intervalo)
    return Intervalo(prevfloat(a.infimo - b.supremo), nextfloat(a.supremo - b.infimo))
end
    
function -(a::Real, b::Intervalo)
    return Intervalo(a) - b
end
    
function -(a::Intervalo, b::Real)
    return a - Intervalo(b)
end
    
function -(a::Intervalo)
    return Intervalo(-a.supremo, -a.infimo)
end

function iszero(a::Intervalo)
    return a == Intervalo(0.0)
end

function *(a::Intervalo, b::Intervalo)
    (isempty(a) || isempty(b)) && return Intervalo(NaN)
    (iszero(a) || iszero(b)) && return Intervalo(0.0)    
    l1 = (prevfloat(a.infimo*b.infimo), prevfloat(a.infimo*b.supremo), prevfloat(a.supremo*b.infimo), prevfloat(a.supremo*b.supremo))
    l2 = (nextfloat(a.infimo*b.infimo), nextfloat(a.infimo*b.supremo), nextfloat(a.supremo*b.infimo), nextfloat(a.supremo*b.supremo))
    return Intervalo(minimum(l1),maximum(l2))
end

function *(a::Real, b::Intervalo)
    return Intervalo(prevfloat(a*b.infimo), nextfloat(a*b.supremo))
end
    
function *(a::Intervalo, b::Real)
    return Intervalo(prevfloat(a.infimo*b), nextfloat(a.supremo*b))
end

function ^(a::Intervalo, b::Int)
    b < 0 && return inv(a^b)
    b == 1 && return a    
    c = min(a.infimo^b, a.supremo^b)
    d = max(a.infimo^b, a.supremo^b)    
    iseven(b) && 0 ∈ a && return Intervalo(0, nextfloat(d))
    iseven(b) && return Intervalo(prevfloat(c), nextfloat(d)) ∩ Intervalo(0, Inf)
    return Intervalo(prevfloat(c), nextfloat(d))  
end

function inv(a::Intervalo)
    iszero(a) && return Intervalo(NaN)
    return Intervalo(1.0)/a
end

function /(a::Intervalo, b::Intervalo)
    0 ∉ b && return a*Intervalo(1/b.supremo,1/b.infimo)
    b.infimo < 0.0 < b.supremo && return Intervalo(-Inf, Inf)
    0.0 == b.infimo < b.supremo && return Intervalo(prevfloat(min(a.infimo*(1/b.supremo), a.supremo*(1/b.supremo))), Inf)
    b.infimo < b.supremo == 0.0 && return Intervalo(-Inf, nextfloat(max(a.infimo*(1/b.infimo), a.supremo*(1/b.infimo))))       
    iszero(b) && return Intervalo(NaN)
end
    
function /(a::Real, b::Intervalo)
    a == 1 && return inv(b)
end

function division_extendida(a::Intervalo, b::Intervalo)
    0∉b && return (a/b,)
    0∈a && 0∈b && return (Intervalo(-Inf, Inf),)
    a.supremo < 0 && b.infimo < b.supremo == 0 &&return (Intervalo(a.supremo/b.infimo, Inf),)
    a.supremo < 0 && b.infimo < 0 <  b.supremo && return (Intervalo(-Inf, nextfloat(a.supremo/b.supremo)) , (Intervalo(prevfloat(a.supremo/b.infimo), Inf)))
    a.supremo < 0 && 0 == b.infimo < b.supremo && return (Intervalo(-Inf, a.supremo/b.supremo),)
    0 < a.infimo && b.infimo < b.supremo == 0 && return (Intervalo(-Inf, nextfloat(a.infimo/b.infimo)),)
    0 < a.infimo && b.infimo < 0 < b.supremo && return (Intervalo(-Inf, nextfloat(a.infimo/b.infimo)) , (Intervalo(prevfloat(a.infimo/b.supremo), Inf)))
    0 < a.infimo && 0 == b.infimo < b.supremo && return (Intervalo(prevfloat(a.infimo/b.supremo), Inf),)
    0∉a && iszero(b) && return (Intervalo(NaN),)
end
