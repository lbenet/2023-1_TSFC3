function bisecta(dom::Intervalo)
    m = punto_medio(dom)
    return Intervalo(dom.infimo, m), Intervalo(m, dom.supremo)
end

function minimiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    
    y_cota = Inf
    n_iter = 0
    candidatos = [dom]

    while (n_iter <= max_iter) && (length(candidatos) > 0) && ( maximum(diam.(candidatos)) > tol)
        for i in eachindex(candidatos)
            x0 = popfirst!(candidatos)
            y0 = f(x0)
            if y_cota < y0.infimo
                continue
            else
                m_i = f(punto_medio(x0))
                if m_i < y_cota
                    y_cota = m_i
                end
                append!(candidatos, bisecta(x0))
            end
        end
        n_iter += 1
    end

    for i in eachindex(candidatos)
        x0 = popfirst!(candidatos)
        y0 = f(x0)
        if y_cota ∈ y0
            push!(candidatos, x0)
        end
    end

    return candidatos, y_cota
end

function maximiza(f::Function, dom::Intervalo, tol::T = 1e-8; max_iter::Int = 20) where {T <: Real}
    inverso = minimiza(x -> -f(x), dom, tol; max_iter = max_iter)
    return inverso[1], -inverso[2]
end