#Definimos la estructura Intervalo

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
#Creamos una función para los intervalos delgados
Intervalo(x) = Intervalo(x,x)


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

+(a::Intervalo,b)=+(b,a)

+(a::Intervalo,b::Intervalo)=Intervalo(prevfloat(getfield(a, :infimo)+getfield(b, :infimo)),nextfloat(getfield(a, :supremo)+getfield(b, :supremo)))

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

-(a::Intervalo)=Intervalo(-getfield(a, :supremo),-getfield(a, :infimo))

-(a::Intervalo,b::Real)=Intervalo(prevfloat(getfield(a, :infimo)-b),nextfloat(getfield(a, :supremo)-b))

import Base: *

function *(a,b::Intervalo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)
    
    if a==intervalo_vacio(Real)
        return a
    end
    
    if b==intervalo_vacio(Real)
        return b
    end
    
    
    if typeof(a)<:Real
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
    else
        in_a=getfield(a, :infimo)
        su_a=getfield(a, :supremo)
        
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
end

*(a::Intervalo,b::Real)=*(b,a)

import Base: /

function /(a,b::Intervalo)
    in_b=getfield(b, :infimo)
    su_b=getfield(b, :supremo)
    
    if 0 ∈ b
        return Intervalo(-Inf, Inf)    
    elseif typeof(a)<:Real
        infimo=min(prevfloat(a/in_b),prevfloat(a/su_b))
        supremo=max(nextfloat(a/in_b),nextfloat(a/su_b))
        return Intervalo(infimo,supremo)
    else
        in_a=getfield(a, :infimo)
        su_a=getfield(a, :supremo)
        
        infimo=min(prevfloat(in_a/in_b),prevfloat(in_a/su_b),prevfloat(su_a/in_b),prevfloat(su_a/su_b))
        supremo=max(nextfloat(in_a/in_b),nextfloat(in_a/su_b),nextfloat(su_a/in_b),nextfloat(su_a/su_b))
        return Intervalo(infimo,supremo)
    end
end

# Definimos la función para las potencias enteras

import Base: ^

function ^(a::Intervalo,b::Int64)
    if b==0
        return Intervalo(1,1)
    end
    
    if isnan(getfield(a, :infimo))
        return a
    end
    
    a_in=prevfloat(getfield(a,:infimo)^b)
    a_su=nextfloat(getfield(a,:supremo)^b)
    
    if b%2!=0
        return Intervalo(a_in,a_su)
    else
        if getfield(a,:infimo) ≤ 0 && getfield(a,:supremo) ≥ 0
            supremo= max(a_in,a_su)
            return Intervalo(0,supremo)
        else 
            infimo=min(a_in,a_su)
            supremo=max(a_in,a_su)
            return (infimo,supremo)
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
        return a/b
    elseif 0 ∈ a && 0 ∈ b
        return Intervalo(-Inf,Inf)
    elseif su_a <0 && in_b < su_b==0
        return Intervalo(prevfloat(su_a/in_b),Inf)
    elseif su_a <0 && in_b < 0 < su_b
        println(Intervalo(su_a/in_b,Inf)," ∪ ",Intervalo(-Inf,su_a/su_b))
        return (Intervalo(prevfloat(su_a/in_b),Inf),Intervalo(-Inf,nextfloat(su_a/su_b)))
    elseif su_a <0 && 0==in_b < su_b
        return Intervalo(-Inf,nextfloat(su_a/su_b))
    elseif 0 < in_a && in_b < su_b==0
        return Intervalo(-Inf,nextfloat(in_a/in_b))
    elseif 0 < in_a && in_b < 0 < su_b
        println(Intervalo(in_a/su_b,Inf)," ∪ ",Intervalo(-Inf,in_a/in_b))
        return (Intervalo(prevfloat(in_a/su_b),Inf), Intervalo(-Inf,nextfloat(in_a/in_b)))
    elseif 0 < in_a && 0==in_b < su_b
        return Intevalo(prevfloat(in_a/su_b),Inf)
    elseif 0 ∉ a && b==Intervalo(0,0)
        return intervalo_vacio(typeof(in_a))
    end
end

/(a::Intervalo,b::Intervalo)=division_extendida(a,b)

import Base: inv

inv(a::Intervalo)=division_extendida(Intervalo(1),a)

export division_extendida