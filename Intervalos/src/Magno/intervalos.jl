import Base: ==, isempty,⊆, ∪, ∩, ∈, ∉, +, -, *, ^, iszero, /, inv #se importan las funciones modificadas

export Intervalo, intervalo_vacio, ⪽, ⊔, division_extendida, esmonotona #se exportan las funciones creadas

export minimiza, maximiza #se exportan las funciones creadas de optimizacion.jl

export Raiz, diam, mid, ceros_newton #se exportan las funciones creadas en raices.jl

using ForwardDiff 

# Se define la estructura Intervalo que recibe dos parametros llamados supremos e infimo

struct Intervalo{T<:Real} <: Real
    infimo::T
    supremo::T
    
    function Intervalo(infimo,supremo)
        infimo1, supremo1, _ = promote(infimo, supremo, 1.0) 
        infimo1 > supremo1  ? error("Supremo es menor que el ínfimo") : new{typeof(infimo1)}(infimo1,supremo1)
    end


    #se agrega esta funcion para igualar el tipo del intervalo y el argumento

    function Intervalo{T}(infimo) where T <: Real 
        infimo1, _ = promote(infimo, T(1)) 
        new{typeof(infimo1)}(infimo1, infimo)
    end    
end


# se llama a los otros archivos creados

include("raices.jl")
include("optimizacion.jl")

#puede recibir un solo elemento cuando se quiere definir un intervalo delgado
Intervalo(infimo) = Intervalo(infimo,infimo) 

#se crea la funcion para expresar al intervalo vacio, recibiendo como parametro un Type y devuelve uno del mismo tipo
function intervalo_vacio(T::Type)
    return Intervalo(T(NaN))
end

#se define un segundo metodo de la funcion intervalo_vacio para el caso donde se reciba un parametro de tipo Intervalo de tipo T
function intervalo_vacio(a::Intervalo{T}) where T <: Real
return intervalo_vacio(T)
end

#funcion que comprueba que un intervalo es vacio 
function isempty(a::Intervalo)
    isnan(a.infimo) && isnan(a.supremo) && return true
    return false 
end

"""
Operaciones básicas
La funciones presentadas se siguen de las definiciones presentadas en la bibliografía
"""

#definimos otro metodo para la funcion == para comprobar que dos intervalos son iguales
function ==(a::Intervalo, b::Intervalo)
    isempty(a) && isempty(b) && return true
    a.infimo == b.infimo && a.supremo == b.supremo
end

#definimos otro metodo para la funcion ⊆ para comprobar que un intervalo esta contenido dentro de otro incluyendo
function ⊆(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    b.infimo ≤ a.infimo && a.supremo ≤ b.supremo
end

#definimos la funcion ⪽ para comprobar que un intervalo esta al interior de otro
function ⪽(a::Intervalo, b::Intervalo)
    isempty(a) && return true
    b.infimo < a.infimo && a.supremo < b.supremo
end

#definimos otro metodo para la funcion ∪ que devuelve el hull de dos intervarlos
function ∪(a::Intervalo, b::Intervalo)
    isempty(a) && return(b)
    isempty(b) && return(a)
    return Intervalo(min(a.infimo,b.infimo),max(a.supremo,b.supremo))
end

# Se define la funcion ⊔ hull que se usa como sinonimo de ∪
function ⊔(a::Intervalo, b::Intervalo)
    return a∪b 
end

# se define otro metodo para ∩ que devuelve la interseccion de dos intervalos   
function ∩(a::Intervalo, b::Intervalo)
    isempty(a) && return a
    isempty(b) && return b
    b.supremo < a.infimo && return Intervalo(NaN)
    a.supremo < b.infimo && return Intervalo(NaN)
    return Intervalo(max(a.infimo,b.infimo),min(a.supremo,b.supremo))
end

# funcion para comprobar que un real pertenece a un intervalo dado
function ∈(a::Real, b::Intervalo)
    isinf(a) && return false
    b.infimo ≤ a ≤ b.supremo
end 

# se definen otros metodos para la suma entre intervalos, o intervalo y un real

function +(a::Intervalo, b::Intervalo)
    return Intervalo(prevfloat(a.infimo + b.infimo), nextfloat(a.supremo + b.supremo))
end
    
function +(a::Real, b::Intervalo)
    return Intervalo(a) + b
end
    
function +(a::Intervalo, b::Real)
    return a + Intervalo(b)
end


# se definen otros metodos para la resta entre intervalos, o intervalo y un real
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

#funcion que comprueba que un intervalo es el intervalo 0
function iszero(a::Intervalo)
    return a == Intervalo(0.0)
end

# se definen otros metodos para la multipliacion entre intervalos, o intervalo y un real
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

# se define una funcion que para extender las potencias enteras para intervalos
function ^(a::Intervalo, b::Int)
    b < 0 && return inv(a^b)
    b == 1 && return a    
    c = min(a.infimo^b, a.supremo^b)
    d = max(a.infimo^b, a.supremo^b)    
    iseven(b) && 0 ∈ a && return Intervalo(0, nextfloat(d))
    iseven(b) && return Intervalo(prevfloat(c), nextfloat(d)) ∩ Intervalo(0, Inf)
    return Intervalo(prevfloat(c), nextfloat(d))  
end

#funcion que devuelve el inverso de un intervalo
function inv(a::Intervalo)
    iszero(a) && return Intervalo(NaN)
    return Intervalo(1.0)/a
end

#funcion para la division de intervalos en distintos casos
function /(a::Intervalo, b::Intervalo)
    0 ∉ b && return a*Intervalo(1/b.supremo,1/b.infimo)
    b.infimo < 0.0 < b.supremo && return Intervalo(-Inf, Inf)
    0.0 == b.infimo < b.supremo && return Intervalo(prevfloat(min(a.infimo*(1/b.supremo), a.supremo*(1/b.supremo))), Inf)
    b.infimo < b.supremo == 0.0 && return Intervalo(-Inf, nextfloat(max(a.infimo*(1/b.infimo), a.supremo*(1/b.infimo))))       
    iszero(b) && return Intervalo(NaN)
end

#metodo de la funcion / para un real y un intervalo
function /(a::Real, b::Intervalo)
    a == 1 && return inv(b)
end

#funcion que define la division extendida de los intervalos en distintos casos
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


"""funcion que verifica si una funcion es monotona en un intervalo dado, esto es cierto
cuando la derivada no cambia de signo"""

function esmonotona(f, D::Intervalo)
    a = ForwardDiff.derivative(f, D)
    sign(a.infimo) == sign(a.supremo) && return true
    return false
end

