@doc raw"""
    bisecta(dom::Intervalo)

Divide **dom** por la mitad. 
"""
function bisecta(dom::Intervalo)
    m = punto_medio(dom)
    return Intervalo(dom.infimo, m), Intervalo(m, dom.supremo)
end

@doc raw"""
    minimiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}

Regresa un **Vector{Intervalo}** cuyos elementos contienen el mínimo global de **f** en **dom**.
La función iterará hasta que los intervalos tengan un diámetro menor a **tol** o se superen 
**max_iter** iteraciones. 
"""
function minimiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    # Cota superior inicial 
    y_cota = Inf
    # Número de iteraciones
    n_iter = 0
    # Candidatos a contener el mínimo global 
    candidatos = [dom]

    while (n_iter <= max_iter) && (length(candidatos) > 0) && ( maximum(diam.(candidatos)) > tol)
        for i in eachindex(candidatos)
            # Revisamos un candidato
            x0 = popfirst!(candidatos)
            # Aplicamos la función 
            y0 = f(x0)
            # El candidato es estrictamente mayor que la cota 
            if y_cota < y0.infimo
                continue
            # El candidato puede contener al mínimo 
            else
                m_i = f(punto_medio(x0))
                # Actualizamos la cota 
                if m_i < y_cota
                    y_cota = m_i
                end
                # Bisectamos 
                append!(candidatos, bisecta(x0))
            end
        end
        n_iter += 1
    end
    # Eliminamos los candidatos que no contienen a la cota 
    for i in eachindex(candidatos)
        x0 = popfirst!(candidatos)
        y0 = f(x0)
        if y_cota ∈ y0
            push!(candidatos, x0)
        end
    end

    return candidatos, y_cota
end

@doc raw"""
    maximiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}

Regresa un **Vector{Intervalo}** cuyos elementos contienen el máximo global de **f** en **dom**.
La función iterará hasta que los intervalos tengan un diámetro menor a **tol** o se superen 
**max_iter** iteraciones. 
"""
function maximiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    inverso = minimiza(x -> -f(x), dom, tol; max_iter = max_iter)
    return inverso[1], -inverso[2]
end

function hull(a::Vector{Intervalo{T}}) where {T <: AbstractFloat}
    x = a[1]
    for i in 2:length(a)
        x = hull(x, a[i])
    end
    return x
end