
## Definimos la estructura

struct Intervalo{T<:Real} 
    #Definimos los espacios para el infimo y el supremo.
    infimo::T
    supremo::T
    
    function Intervalo(a, b)# where {T<:Real, S<:Real}
#        infimo, supremo = valida_intervalo(a, b)
        aa, bb, _ = promote(a, b, 1.0)
        bb < aa && error("El supremo tiene que ser menor al infimo")
        new{typeof(aa)}(aa, bb)
    end
end

#Definimos una función para poder hacer u intervalo delgado
Intervalo(x) = Intervalo(x,x)

#Definimos una función para el intervalo intervalo_vacio

function intervalo_vacio(x)
    Intervalo(x(NaN))
end
   
#para solucionar los problemas con NaN el profe recomienda usar la funcion "isnan"

## Relaciones de conjuntos 
import Base: == 
# Definimos una función para comparar si dos intervalos son iguales
function ==(a::Intervalo,b::Intervalo)
    if isnan(getfield(a, :infimo)) && isnan(getfield(b, :infimo))
        return true
    elseif getfield(a, :infimo)==getfield(b, :infimo) && getfield(a, :supremo)==getfield(b, :supremo)
        return true
    else
        return false
    end
end

import Base: ⊆
#Definimos una función para revisar si un conjunto esta contenido en otro o es igual
function ⊆(a::Intervalo,b::Intervalo)
    if getfield(b, :infimo)≤ getfield(a, :infimo) && getfield(a, :supremo)≤getfield(b, :supremo)
        return true
    else
        return false
    end
end
#Definimos una función para revisar si un conjunto esta contenido en otro 
function isinterior(a::Intervalo,b::Intervalo)
    if a⊆b && a!=b
        return true
    else
        return false
    end
end

const ⪽ = isinterior #definimos el sibolo para contención 

import Base: ∈
#Definimos una función para revisar si un elemento está dentro de un intervalo
function ∈(a::T,b::Intervalo) where {T<:Real}
    if getfield(b, :infimo)≤ a ≤ getfield(b, :supremo)
        return true
    else
        return false
    end
end

function hull(a::Intervalo,b::Intervalo)
    infimo=min(getfield(a, :infimo),getfield(b, :infimo)) #¿por qué el maximo de un numero y NaN es NaN?
    supremo=max(getfield(a, :supremo),getfield(b, :supremo))
    return Intervalo(infimo,supremo)
end

import Base: ∩

function ∩(a::Intervalo,b::Intervalo)
    if getfield(b, :supremo)<getfield(a, :infimo) || getfield(a, :supremo)<getfield(b, :infimo)
        return Intervalo_vacio(typeof(a)) #¿qué pasa si los tipos de los intervalos son distintos?
    else 
        infimo=max(getfield(a, :infimo),getfield(b, :infimo))
        supremo=min(getfield(a, :supremo),getfield(b, :supremo))
        return Intervalo(infimo,supremo)
    end
end

### Funciones aritméticas

import Base: +

function +(a,b::Intervalo)
    if typeof(a)<:Real
        infimo=prevfloat(a+getfield(b, :infimo))
        supremo=nextfloat(a+getfield(b, :supremo))
        return Intervalo(infimo,supremo)
    else
        infimo=prevfloat(getfield(a, :infimo)+getfield(b, :infimo))
        supremo=nextfloat(getfield(a, :supremo)+getfield(b, :supremo))
        return Intervalo(infimo,supremo)
    end
end

import Base: -

function -(a,b::Intervalo)
    if typeof(a)<:Real
        infimo=prevfloat(a-getfield(b, :supremo))
        supremo=nextfloat(a-getfield(b, :infimo))
        return Intervalo(infimo,supremo)
    else
        infimo=prevfloat(getfield(a, :infimo)-getfield(b, :supremo))
        supremo=nextfloat(getfield(a, :supremo)-getfield(b, :infimo))
        return Intervalo(infimo,supremo)
    end
end

import Base: *

function *(a,b::Intervalo)
    in_a=getfield(a, :infimo)
    su_a=getfield(a, :supremo)
    in_b=getfield(b, :infimo)
    su_b=getfield(a, :supremo)
    
    if typeof(a)<:Real
        infimo=min(prevfloat(a*in_b),prevfloat(a*su_b))
        supremo=max(nextfloat(a*in_b),nextfloat(a*su_b))
        return Intervalo(infimo,supremo)
    else
        infimo=min(prevfloat(in_a*in_b),prevfloat(in_a*su_b),prevfloat(su_a*in_b),prevfloat(su_a*su_b))
        supremo=max(nextfloat(in_a*in_b),nextfloat(in_a*su_b),nextfloat(su_a*in_b),nextfloat(su_a*su_b))
        return Intervalo(infimo,supremo)
    end
end


