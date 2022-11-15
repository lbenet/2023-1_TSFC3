@doc raw"""
    Raiz{T <: AbstractFloat} 

Un **Intervalo{T}** que contiene al menos una raíz de una función, la cual puede 
ser única o no. 
"""
struct Raiz{T <: AbstractFloat} 
    raiz::Intervalo{T}
    unicidad::Bool
    # Constructor interno
    function Raiz{T}(raiz::Intervalo{T}, unicidad::Bool) where {T <: AbstractFloat}
        new{T}(raiz, unicidad)
    end
end

# Constructor externo
function Raiz(raiz::Intervalo{T}, unicidad::Bool) where {T <: AbstractFloat}
    Raiz{T}(raiz, unicidad)
end

@doc raw"""
    newton_division_extendida(f::Function, dom::Intervalo)

Aplica el operador de Newton extendido a la función **f** en **dom**.
"""
function newton_division_extendida(f::Function, dom::Intervalo)
    # Derivada 
    df = ForwardDiff.derivative(f, dom)
    # Punto medio 
    m = punto_medio(dom)
    # Intervalo correspondiente al punto medio 
    md = Intervalo(m)
    # Divisón extendida 
    f_div_df = [division_extendida(f(md), df)...]
    # Operador de Newton 
    newton = md .- f_div_df

    return newton .∩ dom
end

@doc raw"""
    ceros_newton(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}

Regresa un **Vector{Raiz}** cuyos elementos contienen las raíces de **f** en **dom**. La función 
iterará hasta que los intervalos tengan un diámetro menor a **tol** o se superen **max_iter** iteraciones. 
"""
function ceros_newton(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    # Número de iteraciones 
    n_iter = 0
    # Candidatos a contener raíces 
    candidatos = Intervalo[dom]

    while (n_iter <= max_iter) && (length(candidatos) > 0) && ( maximum(diam.(candidatos)) > tol)
        for i in eachindex(candidatos)
            # Revisamos un candidato
            x0 = popfirst!(candidatos)
            # Aplicamos el operador de Newton extendido 
            x1 = newton_division_extendida(f, x0)
            for j in eachindex(x1)
                # El candidato no contiene una raíz o es el intervalo vacío
                if ( 0 ∉ f(x1[j]) ) || isempty(x1[j])
                    continue
                # El candidato sí contiene una raíz 
                else 
                    push!(candidatos, x1[j])
                end
            end
        end
        n_iter += 1
    end
    
    # Vector de raíces 
    raices = Vector{Raiz}(undef, length(candidatos))
    for i in eachindex(candidatos)
        # Verificamos unicidad
        raices[i] = Raiz(candidatos[i], esmonotona(f, candidatos[i]))
    end

    return raices
end