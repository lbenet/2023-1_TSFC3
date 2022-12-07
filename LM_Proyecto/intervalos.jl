# using ForwardDiff

#Definimos la estructura Intervalo

abstract type AbstractIntervalo <: Real end

struct Intervalo{T<:AbstractFloat} <: AbstractIntervalo
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
#Creamos una función para los intervalos delgados
Intervalo(x::T) where {T<:Real} = Intervalo(x,x)


export Intervalo

#Creamos la función intervalo_vacio
function intervalo_vacio(x)
    Intervalo(x(NaN))
end

intervalo_vacio(a::Intervalo)=intervalo_vacio(typeof(getfield(a, :infimo)))


export intervalo_vacio

# Sobrecargamos y creamos funciones para las relaciones de conjuntos
import Base: == 

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

function ⊆(a::Intervalo,b::Intervalo)
    if isnan(getfield(a, :infimo))
       return true 
    elseif getfield(b, :infimo)≤ getfield(a, :infimo) && getfield(a, :supremo)≤getfield(b, :supremo)
        return true
    else
        return false
    end
end

function isinterior(a::Intervalo,b::Intervalo)
    if a⊆b && a!=b
        return true
    else
        return false
    end
end

const ⪽ = isinterior 

export ⪽

import Base: ∈

function ∈(a::T,b::Intervalo) where {T<:Real}
    if abs(a)>prevfloat(Inf)
        return false
    elseif getfield(b, :infimo)≤ a ≤ getfield(b, :supremo)
        return true
    else
        return false
    end
end

function hull(a::Intervalo,b::Intervalo)
    if isnan(getfield(a, :infimo))
        return b
    elseif isnan(getfield(b, :infimo))
        return a
    else
        infimo=min(getfield(a, :infimo),getfield(b, :infimo)) #¿por qué el maximo de un numero y NaN es NaN?
        supremo=max(getfield(a, :supremo),getfield(b, :supremo))
        return Intervalo(infimo,supremo)
    end
end

const ⊔ = hull

export ⊔

import Base: ∪
∪(a::Intervalo,b::Intervalo)= ⊔(a,b)

import Base: ∩

function ∩(a::Intervalo,b::Intervalo)
    if getfield(b, :supremo)<getfield(a, :infimo) || getfield(a, :supremo)<getfield(b, :infimo)
        return intervalo_vacio(typeof(getfield(a, :infimo))) #¿qué pasa si los tipos de los intervalos son distintos?
    else 
        infimo=max(getfield(a, :infimo),getfield(b, :infimo))
        supremo=min(getfield(a, :supremo),getfield(b, :supremo))
        return Intervalo(infimo,supremo)
    end
end

#Ahora sobrecargaremos las funciones aritmetica

import Base: +

function +(a::Real,b::Intervalo)
    infimo=prevfloat(a+getfield(b, :infimo))
    supremo=nextfloat(a+getfield(b, :supremo))
    return Intervalo(infimo,supremo)
end
function +(a::Intervalo,b::Intervalo)
    infimo=prevfloat(getfield(a, :infimo)+getfield(b, :infimo))
    supremo=nextfloat(getfield(a, :supremo)+getfield(b, :supremo))
    return Intervalo(infimo,supremo)
end

+(a::Intervalo,b::Real)=+(b,a)

#+(a::Intervalo,b::Intervalo)=Intervalo(prevfloat(getfield(a, :infimo)+getfield(b, :infimo)),nextfloat(getfield(a, :supremo)+getfield(b, :supremo)))

import Base: -

function -(a::Real,b::Intervalo)
    infimo=prevfloat(a-getfield(b, :supremo))
    supremo=nextfloat(a-getfield(b, :infimo))
    return Intervalo(infimo,supremo)
end

function -(a::Intervalo,b::Intervalo)
    infimo=prevfloat(getfield(a, :infimo)-getfield(b, :supremo))
    supremo=nextfloat(getfield(a, :supremo)-getfield(b, :infimo))
    return Intervalo(infimo,supremo)
end

-(a::Intervalo)=Intervalo(-getfield(a, :supremo),-getfield(a, :infimo))

-(a::Intervalo,b::Real)=Intervalo(prevfloat(getfield(a, :infimo)-b),nextfloat(getfield(a, :supremo)-b))

import Base: *

function *(a::Real, b::Intervalo)
    
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)
    
    if b==intervalo_vacio(Real)
        return b
    end
    
    if abs(a)==Inf &&  in_b==0 && su_b==0
            return Intervalo(0.0)
        elseif su_b*a==Inf &&  in_b==0 || in_b*a==Inf &&  su_b==0 
            return Intervalo(0,Inf)
        elseif su_b*a==-Inf &&  in_b==0 || in_b*a==-Inf &&  su_b==0 
            return Intervalo(-Inf,0)
        end      
    infimo=min(prevfloat(a*in_b),prevfloat(a*su_b))
    supremo=max(nextfloat(a*in_b),nextfloat(a*su_b))
    return Intervalo(infimo,supremo)
end

function *(a::Intervalo,b::Intervalo)
    in_a=getfield(a, :infimo)
    su_a=getfield(a, :supremo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)
    
    if a==intervalo_vacio(Real)
        return a
    end
    
    if b==intervalo_vacio(Real)
        return b
    end

    if isnan(prevfloat(in_a*in_b)) && isnan(prevfloat(su_a*su_b))
        infimo=0.0
        supremo=0.0
    elseif isnan(prevfloat(in_a*in_b))
        infimo=min(0,prevfloat(in_a*su_b),prevfloat(su_a*in_b),prevfloat(su_a*su_b))
        supremo=max(0,nextfloat(in_a*su_b),nextfloat(su_a*in_b),nextfloat(su_a*su_b))
    elseif isnan(prevfloat(in_a*su_b))
        infimo=min(prevfloat(in_a*in_b),0,prevfloat(su_a*in_b),prevfloat(su_a*su_b))
        supremo=max(nextfloat(in_a*in_b),0,nextfloat(su_a*in_b),nextfloat(su_a*su_b))
    elseif isnan(prevfloat(su_a*in_b))
        infimo=min(prevfloat(in_a*in_b),prevfloat(in_a*su_b),0,prevfloat(su_a*su_b))
        supremo=max(nextfloat(in_a*in_b),nextfloat(in_a*su_b),0,nextfloat(su_a*su_b))
    elseif isnan(prevfloat(su_a*su_b))
        infimo=min(prevfloat(in_a*in_b),prevfloat(in_a*su_b),prevfloat(su_a*in_b),0)
        supremo=max(nextfloat(in_a*in_b),nextfloat(in_a*su_b),nextfloat(su_a*in_b),0)
    else 
        infimo=min(prevfloat(in_a*in_b),prevfloat(in_a*su_b),prevfloat(su_a*in_b),prevfloat(su_a*su_b))
        supremo=max(nextfloat(in_a*in_b),nextfloat(in_a*su_b),nextfloat(su_a*in_b),nextfloat(su_a*su_b))
    end
    return Intervalo(infimo,supremo)
end

*(a::Intervalo,b::Real)=*(b,a)

import Base: /

function /(a::Real,b::Intervalo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)

    if 0 ∈ b 
        if b==Intervalo(0.0)
            return intervalo_vacio(typeof(in_b))
        elseif in_b < 0 < su_b
            return Intervalo(-Inf, Inf)
        elseif 0== in_b < su_b
            return Intervalo(prevfloat(a/su_b),Inf)
        elseif in_b < su_b ==0
            return Intervalo(-Inf,nextfloat(a/in_b))
        end
    end

    infimo=min(prevfloat(a/in_b),prevfloat(a/su_b))
    supremo=max(nextfloat(a/in_b),nextfloat(a/su_b))
    return Intervalo(infimo,supremo)
end

function /(a::Intervalo,b::Intervalo)
    in_a=getfield(a, :infimo)
    su_a=getfield(a, :supremo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)

    if isnan(in_a)
        return a
    elseif isnan(in_b)
        return b
    end

    if 0 ∈ b 
        if b==Intervalo(0.0)
            return intervalo_vacio(typeof(in_b))
        elseif in_b < 0 < su_b
            return Intervalo(-Inf, Inf)
        elseif 0== in_b < su_b
            return Intervalo(prevfloat(min(in_a*1/su_b,su_a*1/su_b)),Inf)
        elseif in_b < su_b ==0
            return Intervalo(-Inf,nextfloat(max(in_a*1/in_b,su_a*1/in_b)))
        end
    end

    infimo=min(prevfloat(in_a/in_b),prevfloat(in_a/su_b),prevfloat(su_a/in_b),prevfloat(su_a/su_b))
    supremo=max(nextfloat(in_a/in_b),nextfloat(in_a/su_b),nextfloat(su_a/in_b),nextfloat(su_a/su_b))
    return Intervalo(infimo,supremo)
end

function /(a::Intervalo,b::Real)
    if b==0
        return error("El denominador es cero")
    end
    return a*Intervalo(1/b)
end


# Definimos la función para las potencias enteras

import Base: ^

function ^(a::Intervalo,b::Int64)
    if b==0
        return Intervalo(1,1)
    end
    
    if isnan(getfield(a, :infimo)) || b==1
        return a
    end

    if b==-1
        return 1/a
    end
    
    a_in=getfield(a,:infimo)^b
    a_su=getfield(a,:supremo)^b
    
    if b%2!=0
        return Intervalo(prevfloat(a_in),nextfloat(a_su))
    else
        if getfield(a,:infimo) ≤ 0 && getfield(a,:supremo) ≥ 0
            supremo= max(a_in,a_su)
            return Intervalo(0,nextfloat(supremo))
        else 
            infimo=prevfloat(min(a_in,a_su))
            supremo=nextfloat(max(a_in,a_su))
            return Intervalo(infimo,supremo)
        end
    end
end

#Definimos la función division_extendida de acuerdo a lo visto en clase.

function division_extendida(a::Intervalo,b::Intervalo)
    in_a=getfield(a, :infimo)
    su_a=getfield(a, :supremo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)
    
    if 0 ∉ b
        return (a/b,)
    elseif 0 ∈ a && 0 ∈ b
        return (Intervalo(-Inf,Inf),)
    elseif su_a <0 && in_b < su_b==0
        return (Intervalo(prevfloat(su_a/in_b),Inf),)
    elseif su_a <0 && in_b < 0 < su_b
        return (Intervalo(-Inf,nextfloat(su_a/su_b)),Intervalo(prevfloat(su_a/in_b),Inf),)
    elseif su_a <0 && 0==in_b < su_b
        return (Intervalo(-Inf,nextfloat(su_a/su_b)),)
    elseif 0 < in_a && in_b < su_b==0
        return (Intervalo(-Inf,nextfloat(in_a/in_b)),)
    elseif 0 < in_a && in_b < 0 < su_b
        return (Intervalo(-Inf,nextfloat(in_a/in_b)),Intervalo(prevfloat(in_a/su_b),Inf),)        
    elseif 0 < in_a && 0==in_b < su_b
        return (Intervalo(prevfloat(in_a/su_b),Inf),)
    elseif 0 ∉ a && b==Intervalo(0,0)
        return (intervalo_vacio(typeof(in_a)),)
    end
end

#/(a::Intervalo,b::Intervalo)=division_extendida(a,b)

import Base: inv

inv(a::Intervalo)=1/a

export division_extendida

# Para la tarea 2: Ejercicio 1: Intervalo y ForwardDiff¶

import Base: one

function one(a::Intervalo)
    return Intervalo(one(a.infimo),one(a.supremo))
end

import Base: zero

function zero(a::Intervalo)
    return Intervalo(zero(a.infimo),zero(a.supremo))
end

function zero(a::Type{Intervalo{Float64}})
    return Intervalo(zero(Float64))
end


## Ejercicio 2: Verificando la monotonicidad

export esmonotona

function esmonotona(a::Function , b::Intervalo)
    fprima = ForwardDiff.derivative(a,b)
    #@show(fprima)
    0 ∈ fprima && return false
    return true
end

## Ejercicio 3: Método de Newton intervalar extendido en 1d

#include("raices.jl")
#include("optimizacion.jl")