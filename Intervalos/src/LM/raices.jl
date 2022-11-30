export ceros_newton
#Definimos la estructura Raiz

struct Raiz{T<:AbstractFloat}
    raiz::Intervalo{T}
    unicidad::Bool
end

#Definimos una función para segmentar los intervalos a la mitad 

function mid(a::Intervalo)
    return (a.supremo+a.infimo)/2
end

#Definimos una función para medir el diametro de los intervalos
function diam(a::Intervalo)
    return a.supremo-a.infimo
end

#Definimos una función para implementar el método de Newton extendido

function N_extdiv(f::Function, dom::Intervalo)
    f′=ForwardDiff.derivative(f, dom)   
    md=Intervalo(mid(dom))
    Nm=md.-[division_extendida(f(md),f′)...]
    return Nm
end

#Definimos la fucnión ceros_newton para encontrar los intervalos que contienen ceros de la función y si estas racies son unicas.

function ceros_newton(f::Function, dom::Intervalo, tol::AbstractFloat=1/1024)
    #Nm=N_extdiv(f,dom) 
    dom_intersec=dom
    candidatos=[dom]
    bz= !(0 ∈ f(dom)) 
    while !bz
        for _ in eachindex(candidatos)
            dominio = popfirst!(candidatos) # Extraemos y borramos la primer entrada de `Nm`
            #print(dominio)
            dominio= dominio  ∩ dom_intersec
            isnan(dominio.infimo) && continue
            vf = f(dominio)
            0 ∉ vf && continue
            if diam(dominio) < tol
                push!(candidatos, dominio)   # Se incluye a `dom` (al final de `Nm`)
            else
                nuevos=N_extdiv(f,dominio) .∩ dominio
                append!(candidatos, nuevos) 
            end
        end
        bz=maximum(diam.(candidatos))<tol
    end
    vind = findall(0 .∈ f.(candidatos))
    unicidad=esmonotona.(f,candidatos[vind])
    return Raiz.(candidatos[vind],unicidad)
end