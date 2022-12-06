export Raiz, ceros_newton, mid, diam, NewtExt, NewtR_cand, Newton
#Ejercicio 3: Método de Newton intervalar extendido en 1d

#Definan una estructura Raiz que incluya dos campos, 
#raiz::Intervalo{T} y unicidad::Bool. Puede ser útil parametrizar el tipo.

"""
Raiz{T}
Definiendo la estructura

"""
struct Raiz
    #damos las posiciones de infimo y supremo
    raiz::Intervalo
    unicidad::Bool
end


#Recordemos que para el método de Newton intervalar, requerimos el operador de Newton, el cual usa la función mid, 
#por lo que, primero definiremos mid

"""
Recordemos que mid (a) es el punto medio del intervalo a, es decir
mid (a) = (a.supremo + a.infimo)/2
"""
function mid(a::Intervalo)
    return Intervalo((a.supremo + a.infimo)/2)
end


#Ahora, para medir la tolerancia necesitamos conocer el diámetro del intervalo, por lo que, definamos la func. diam

"""
Función diámetro que regresa el diámetro de un intervalo a, tal que,
diam(a) = a.supremo - a.infimo
"""
function diam(a::Intervalo)
    return a.supremo - a.infimo
end

#=
Ahora como necesitamos el operador de Newton, lo extenderemos mediante la división extendida para tener el método
de Newton intervalar extendido.
Primero recordemos que el operador de Newton se ve de la siguiente manera
N([X]) = N([x]; m) = m - \frac{f(m)}{f'(\zeta)}
donde m es el punto medio del intervalo (la función mid definida previamente)
Ahora, para extenderla con la división extendida, simplemente realizamos la división con la función definida
previamente en intervalos.jl, invocando division_extendida.

La función "Newt Ext" esta basada en la función N_extdiv presentada en las notas de clase "05-CerosFunc"
=#
"""
Operador de Newton extendido, invoca la división extendida definida en el modulo intervalos para aceptar intervalos que
contengan a cero (intervalos con maximos y minimos)
"""
function NewtExt(f::Function, dom::Intervalo)
    fprima = ForwardDiff.derivative(f, dom)
    m = mid(dom)
    Nm = m .- [division_extendida(f(m), fprima)...] #aqui restamos a cada intervalo producido por la division ext.
    return Nm #el resultado sera una tupla
end

#El siguiente código esta basado en el de biseccion de las notas de clase "05-CerosFunc", 

"""
Esta funcion regresa los subintervalos que incluyen a 0 (los candidatos) con diametro menor a una cierta tolerancia
tol
"""
function NewtR_cand(f, dom::Intervalo, tol::AbstractFloat)
    bz = !(0 ∈ f(dom)) #revisamos que haya raíces
    v_cand = [dom]  # Vector que incluirá al resultado

    while !bz #mientras haya una raíz iteramos
        Newton(v_cand, f, tol) #aqui aplicamos newton extendida a cada intervalo dado
        #por la division extendida y separamos los subintervalos candidatos a contener una raíz
        
        bz = maximum(diam.(v_cand)) < tol #a diferencia de biseccion aqui los intervalos
#no siempre tendrán el mismo diámetro, por lo que, se tomará el diámetro máximo de los subintervalos
#para evaluar si son menores a la tolerancia dada
    end

    #Filtra los intervalos que no incluyan al 0 evaluando la función en cada candidato hallado
    vind = findall(0 .∈ f.(v_cand))
    return v_cand[vind] #regresa los subintervalos que incluyen a 0
end
"""
La función Newton aplica el método de Newton intervalar extendido a cada subintervalo dado, siempre que contenga a 
y tenga un diámetro mayor a la tolerancia, de otra manera, simplemente lo ignora si no contiene a , o lo agrega a la
lista de candidatos si contiene a cero y es menor que la tolerancia dada
"""
function Newton(vdom, f, tol)
    for _ in eachindex(vdom)
        dom = popfirst!(vdom)  # Extraemos y borramos la primer entrada de `vdom`
        vf = f(dom) 
        0 ∉ vf && continue #si no hay raíz en ese intervalo la desechamos 
        if diam(dom) < tol #si hay raíz se corre esta parte del código, evaluamos si el diámetro
        #del subintervalo es menor a la tolerancia, en cuyo caso lo agregamos a al final de vdom
            push!(vdom, dom)   
        else #si es mas grande que la tolerancia, aplicamos Newton al subintervalo
            new_Nm = NewtExt(f,dom) #nuevos subintervalos Nm dados por Newton extendido    
            for Nmi in new_Nm #revisamos los subintervalos resultantes
                new_dom = Nmi ∩ dom #sacamos la interseccion de cada subintervalo con el dominio
                isempty(new_dom) && continue #si no se intersectan lo desechamos
                push!(vdom, new_dom) #si se intersectan lo agregamos a vdom como candidato
            end
        end
    end
    return nothing
end

"""
La función ceros_newton usa las funciones creadas previamente para regresar un vector de objetos raiz con los 
subintervalos candidatos e información sobre si es una raíz única o no
"""
function ceros_newton(f, dom::Intervalo, tol::AbstractFloat=1/1024)
    v_cand = NewtR_cand(f, dom, tol) #subintervalos que incluyen a 0 (candidatos)
    unicidad = esmonotona.(f, v_cand) #revisamos que la funion sea monotona en cada subintervalo esto 
    #nos dice si la raiz es unica o no; recordemos que unicidad es un booleano
    return Raiz.(v_cand, unicidad) #regresa un vector de objetos Raiz
end 


