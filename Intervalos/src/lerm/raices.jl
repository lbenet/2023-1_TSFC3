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

function ceros_newton(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    
    n_iter = 0
    candidatos = [dom]

    while (n_iter <= max_iter) && (length(candidatos) > 0) && ( maximum(diam.(candidatos)) > tol)
        for i in eachindex(candidatos)
            x0 = popfirst!(candidatos)
            x1 = newton_division_extendida(f, x0)
            for j in eachindex(x1)
                if 0 ∉ f(x1[j]) 
                    continue
                elseif isempty(x1[j])
                    continue
                else 
                    push!(candidatos, x1[j])   # Se incluye a `dom` (al final de `vdom`)
                end
            end
        end
        n_iter += 1
    end
    
    raices = [Raiz(c, esmonotona(f, c)) for c in candidatos]

    return raices
end