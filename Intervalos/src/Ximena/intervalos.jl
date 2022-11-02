### Ejercicio 1: Módulo `Intervalos`
export Intervalo, intervalo_vacio, ⪽, ⊔, division_extendida
import Base: ==, ∪, ∩, ∈, ∉, ⊆, +, -, *, /, ^, isempty, inv

"""
Intervalo{T}
El siguiente código esta basado en lo visto en clase

"""
struct Intervalo{T<:Real}
    #damos las posiciones de infimo y supremo
    infimo::T
    supremo::T
    
    function Intervalo(a,b)# where {T<:Real, S<:Real}
        # a = infimo, b = supremo
        aa, bb, _ = promote(a, b, 1.0) #convertimos a,b en float64 al promover con 1.0
        bb < aa && error("El supremo es menor que el ínfimo") #si el infimo es mayor da ese error
        new{typeof(aa)}(aa, bb) #regresa el intervalo con el tipo ya promovido
    end
end

Intervalo(x) = Intervalo(x,x) #para un intervalo delgado

function intervalo_vacio(S::Type)
#ya que NaN::S da error cuando S=BigFloat, en este caso definiremos intervalo con big(NaN)
    if S == BigFloat
        Intervalo(big(NaN))
    else #si no es bigfloat, lo definimos como usualmente
        Intervalo(S(NaN))  
    end
end

#Si el argumento es un intervalo tipo T
function intervalo_vacio(z::Intervalo{T}) where {T<:Real}
    return Intervalo(T(NaN))
end

### Ejercicio 2: Operaciones básicas
## Operaciones de conjuntos ##################################

import Base: ==, ∪, ∩, ∈, ∉, ⊆, +, -, *, /, ^, isempty, inv

"""
Defino el caso de que un intervalo sea vacío, como mi función de intervalo vacío es (NaN, NaN)
verificaré que el supremo y el infimo sean NaN
"""

function isempty(a::Intervalo)
     if isnan(a.infimo) && isnan(a.supremo)
        return true
     else 
        return false
     end 
end

### Igualdad de conjuntos == #########################
#Recordemos que para que se de la igualdad de conjuntos, tanto el ínfimo como el supremo de ambos deben ser iguales

function ==(a::Intervalo, b::Intervalo) #comparacion entre intervalos
    if isempty(a) && isempty(b)
        return true
    else
        a.infimo == b.infimo && a.supremo == b.supremo
    end
end

### issubset  #######################################
#Recordemos que $$[a] \subseteq [b] \Leftrightarrow \underline{b} \leq \underline{a}$$ y $$\overline{a} \leq \overline{b} $$

function ⊆(a::Intervalo, b::Intervalo)
    isempty(a) && return true #el vacio esta dentro de todo conjunto
    b.infimo ≤ a.infimo && a.supremo ≤ b.supremo #verificando condiciones
end

### isinterior #########################################
#En este caso $$[a] \subset [b] \Leftrightarrow \underline{b} < \underline{a}$$ y $$\overline{a} < \overline{b} $$

function ⪽(a::Intervalo, b::Intervalo)
    isempty(a) && return true #el vacio esta dentro de todo conjunto
    b.infimo < a.infimo && a.supremo <b.supremo #verificando condiciones
end

### In #################################33
#Para saber si a $\in$ [b] hay que verificar si $$\underline{b}\leq a \leq \overline{b}$$

function ∈(a::Real,b::Intervalo)
"""
como el infinito no es real, y los intervalos son reales y cerrados, no permitimos que
el infinito este en el intervalo
"""
    b.infimo == Inf && return false
    b.supremo == Inf && return false
    b.infimo ≤ a ≤ b.supremo
end

### Hull ####################################################
#Como la unión de dos intervalos puede no definir un intervalo si están muy alejados, usaremos el hull, que es el menor intervalo que incluye los elementos de ambos intervalos, es decir.
#$$[a]\sqcup [b] = [min(\underline{a},\underline{b}),max(\overline{a},\overline{b})]$$

function ⊔(a::Intervalo, b::Intervalo)
    isempty(a) && return b
    isempty(b) && return a
    infim = min(a.infimo,b.infimo)
    supr = max(a.supremo, b.supremo)
    return Intervalo(infim, supr)
end

### Unión, es sinónima a hull #################################
#En este caso sólo copie y pegué el hull pero en U

function ∪(a::Intervalo, b::Intervalo)
    isempty(a) && return b
    isempty(b) && return a
    infim = min(a.infimo,b.infimo)
    supr = max(a.supremo, b.supremo)
    return Intervalo(infim, supr)
end

### Intersect  ##########################
#Notemos que se debe agregar el conjunto vacío en caso de que los intervalos sean disjuntos, por lo que, podemos definir la intersección entre dos intercalos como

#$$[a]\cap[b] = $$ $[\oslash]$ si $\overline{b}<\underline{a}$ o $\overline{a}<\underline{b}$


#$[max(\underline{a},\underline{b}), min(\overline{a},\overline{b})]$ en otro caso

function ∩(a::Intervalo, b::Intervalo)
    isempty(a) && return a
    isempty(b) && return b
    b.supremo < a.infimo && return intervalo_vacio(typeof(a.infimo))
    a.supremo < b.infimo && return intervalo_vacio(typeof(b.infimo))
    infim = max(a.infimo,b.infimo)
    supr = min(a.supremo, b.supremo)
    return Intervalo(infim, supr)
end

### Not in $\notin$ ######################################
#La negación de $\in$

function ∉(a::Real,b::Intervalo)
    if a∈b
        return false
    else
        return true
    end
end

######################################################
## Operaciones aritméticas

### Suma + ###################
#Tenemos que
#$$[a] + [b] = [\underline{a} + \underline{b},\overline{a} + \overline{b}]$$
#además la suma de un intervalo vacío con otro, da el intervalo vacío

function +(a, b)
    if a isa Intervalo && b isa Intervalo
        isempty(a) && return a #si un intervalo es vacio devuelve el mismo
        isempty(b) && return b
        infim = a.infimo + b.infimo
        supr = a.supremo + b.supremo
        return Intervalo(prevfloat(infim),nextfloat(supr))#redondeamos con prevfloat y nextfloat
    elseif a isa Intervalo && b isa Real
        a + Intervalo(b)
    elseif a isa Real && b isa Intervalo
        Intervalo(a) + b
    end
end

+(a::Intervalo) = a #si solo hay un argumento tipo intervalo regresa el mismo 

### Resta de intervalos - ##################
#Para la resta de intervalos tenemos que
#$$[a] - [b] = [\underline{a} - \overline{b},\overline{a} - \underline{b}]$$

#resta de dos intervalos en general
function -(a, b)
    if a isa Intervalo && b isa Intervalo
        Intervalo(prevfloat(a.infimo - b.supremo), nextfloat(a.supremo - b.infimo))
    elseif a isa Intervalo && b isa Real
        a - Intervalo(b)
    elseif a isa Real && b isa Intervalo
        Intervalo(a) - b
    end
end

#si solo da una variable tipo intervalo se regresa invertido con signo menos
-(a::Intervalo) = Intervalo(-a.supremo, -a.infimo) 

### Multiplicación * #######################
#Tenemos que
#$$[a]x[b] = function [min(\underline{a}\underline{b},\underline{a}\overline{b},\overline{a}\underline{b},\overline{a}\overline{b}),max(\underline{a}\underline{b},\underline{a}\overline{b},\overline{a}\underline{b},\overline{a}\overline{b})]$$

function *(a, b)
    if a isa Intervalo && b isa Intervalo 
        #primero notemos que el vacio por algo es el vacio
        isempty(a) && return intervalo_vacio(a)
        isempty(b) && return intervalo_vacio(b)
        
        #Luego el 0 por lo que sea es 0
        a == Intervalo(0.0) && return a
        b == Intervalo(0.0) && return b
        
        #ahora definamos los 4 valores a evaluar para hallar los extremos del intervalo resultante
        aibi = a.infimo*b.infimo
        aibs = a.infimo*b.supremo
        asbi = a.supremo*b.infimo
        asbs = a.supremo*b.supremo
        #Ponemos todo junto en la expresión
        Intervalo(prevfloat(min(aibi,aibs,asbi,asbs)),nextfloat(max(aibi,aibs,asbi,asbs)))
    
    #Si multiplican por un numero y no un intervalo
    elseif a isa Intervalo && b isa Real
        #en este caso multiplicamos los extremos por el numero real
        Intervalo(prevfloat(b*a.infimo),nextfloat(b*a.supremo))
    elseif a isa Real && b isa Intervalo
        Intervalo(prevfloat(a*b.infimo),nextfloat(a*b.supremo))
    end
end 


### División / ######################################
#Esta definición de división se ve de la siguiente forma
#$$[a]/[b]
#    ax[1/\overline{b},1/\underline{b}]$$ si $0\notin b$

function /(a::Intervalo, b::Intervalo)
    isempty(a) && return intervalo_vacio(a)
    isempty(b) && return intervalo_vacio(b)
    0 ∉ b && return a*Intervalo(1/b.supremo,1/b.infimo)
    if 0 ∈ b #si 0 en b revisamos cada posible caso
        b == Intervalo(0.0) && return intervalo_vacio(b) #si b es delgado de 0
        b.infimo < 0.0 < b.supremo && return Intervalo(-Inf, Inf) #si b esta dentro del intervalo

        # si el infimo es 0 lo quitamos haciendo 1/supremo de b al infinito positivo
        0.0 == b.infimo < b.supremo && return Intervalo(prevfloat(min(a.infimo*(1/b.supremo), a.supremo*(1/b.supremo))), Inf)

        #si el 0 es el supremo lo quitamos haciendo intervalo de -infinito a 1/ infimo de b
        b.infimo < b.supremo == 0.0 && return Intervalo(-Inf, nextfloat(max(a.infimo*(1/b.infimo), a.supremo*(1/b.infimo))))
    end
end

"""
Si a es real hay que repetir las pruebas para ver si 0 está en b, copie y pegue los casos
anteriores abajo
        
"""
function /(a::Real,b::Intervalo)   
    isempty(b) && return intervalo_vacio(b)
    if 0 ∈ b
        b == Intervalo(0.0) && return intervalo_vacio(b)
        b.infimo < 0.0 < b.supremo && return Intervalo(-Inf, Inf)

        # si el infimo es 0 lo quitamos haciendo 1/supremo de b al infinito positivo
        b.infimo == 0 < b.supremo && return Intervalo(prevfloat(a/b.supremo), Inf)

        #si el 0 es el supremo lo quitamos haciendo intervalo de -infinito a 1/ infimo de b
        b.infimo < 0.0 == b.supremo && return Intervalo(-Inf,nextfloat(a/b.infimo))
    end
    if 0.0 ∉ b
        #para a positiva 
        0 ≤ a && return Intervalo(prevfloat(a/b.supremo), nextfloat(a/b.infimo))
        #para a negativa intercambiamos los extremos
        a < 0 && return Intervalo(prevfloat(a/b.infimo), nextfloat(a/b.supremo))
    end
end



"""
Si b es un numero hay que verificar que no sea 0, si no lo es seguimos normal
"""
function /(a::Intervalo, b::Real)
    b == 0.0 && error("El denominador es 0")
    a*Intervalo(1/b)
end

### Potencias * ###################################3

#Veamos potencias enteras

#Para potencias negativas extendamos inv, primero veremos que no sea un intervalo (0,0), luego tomamos el inverso del supremo como infimo del nuevo intervalo y el inverso del infimo como el supremos, además ensanchamos el intervalo para asegurar que los extremos se encuentren dentro del intervalo resultante

function inv(a::Intervalo)
    a == Intervalo(0) && return intervalo_vacio(BigFloat) #BigFloat para que no haya problema
    return Intervalo(1.0)/a 
end

function ^(a::Intervalo, n::Int64)
    #primero veamos los casos especiales, potencia 0, potencia 1, e intervalo vacio
    n == 0 && return Intervalo(1) #a la potencia cero será un intervalo delgado de 1
    n == 1 && return a #potencia 1 regresa lo mismo
    isempty(a) && return a #si esta vacio devuelve el intervalo vacio
    n == -1 && return 1/a
    #Ahora veamos el caso de potencia par primero
    if n%2 == 0 #verificando si es par
        if a.infimo < 0 && a.supremo > 0
            #inf = 0 #comentado, no tiene caso usar memoria aqui para guardad el 0
            #sup = max(a.infimo^n,a.supremo^n) #como la pot es par no importa el signo de inf o sup
            return Intervalo(0, nextfloat(max(a.infimo^n,a.supremo^n)))
        else
            
            inf = min(a.infimo^n,a.supremo^n)
            sup = max(a.infimo^n,a.supremo^n)
            inf == 0 && return Intervalo(0,nextfloat(sup)) #para no redondear 0 que es representable
            return Intervalo(prevfloat(inf),nextfloat(sup))
            #ensanchamos un poco el intervalo
            #para no perder información y garantizar que los extremos estén dentro
        end
    else #si es impar se conservan los signos
        a.infimo^n == 0 && return Intervalo(0,nextfloat(sup)) #para no redondear 0's
        a.supremo^n == 0 && return(prevfloat(a.infimo^n),0)
        return Intervalo(prevfloat(a.infimo^n), nextfloat(a.supremo^n))
    end
end

### División extendida ##########################################
 
function division_extendida(a::Intervalo, b::Intervalo)
    0.0 ∉ b && return (a/b,) #caso 1 como ya definimos asi la división antes, solo la invocamos
    #caso 2, 0 ∈ [a],[b]=> [-inf,inf]
    if 0.0 ∈ a && 0.0 ∈ b
        return (Intervalo(-Inf, Inf),)
    #caso 3,a y b negativos, b con cero
    elseif a.supremo < 0.0 && b.infimo < b.supremo == 0.0
        return (Intervalo(prevfloat(a.supremo/b.infimo), Inf),) #redondeando para ensanchar un poco el intervalo
    #caso 4, a negativo sin cero, 0 ∈ b
    elseif a.supremo < 0.0 && b.infimo < 0.0 < b.supremo
    #tomamos ambos intervalos, primero el que viene de -inf, y despues el que va a +inf, asi abarcamos la union de ambos
        return (Intervalo(-Inf, nextfloat(a.supremo/b.supremo)), Intervalo(prevfloat(a.supremo/b.infimo), Inf),)
    #caso 5 intervalo a debajo de 0 e infimo de b igual a 0  
    elseif a.supremo < 0.0 && 0.0 == b.infimo < b.supremo
        return (Intervalo(-Inf, nextfloat(a.supremo/b.supremo)), )
    #caso 6, a positivo, b negativo incluyendo el 0
    elseif 0 < a.infimo && b.infimo < b.supremo == 0
        return (Intervalo(-Inf, nextfloat(a.infimo/b.infimo)), )
    #caso 7 a positivo sin cero y 0 ∈ b
    elseif 0.0 < a.infimo && b.infimo < 0.0 < b.supremo
    #analogo al caso 4
        return (Intervalo(-Inf, nextfloat(a.infimo/b.infimo)), Intervalo(prevfloat(a.infimo/b.supremo), Inf),)
    #caso 8 a positiva, b positivo con cero en el infimo
    elseif 0.0 < a.infimo && 0 == b.infimo < b.supremo
        return (Intervalo(prevfloat(a.infimo/b.supremo), Inf) , )
    #caso 9 a sin 0 y b intervalo delgado de 0 (asi no esta indeterminado)
    elseif 0.0 ∉ a && b == Intervalo(0)
        return (intervalo_vacio(BigFloat), )
    end
end


