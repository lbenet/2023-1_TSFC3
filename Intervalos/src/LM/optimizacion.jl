export minimiza, mid, diam, biseccion,maximiza

#Creamos una función para obtener el valor medio de un intervalo
function mid(a::Intervalo)
    return (a.supremo+a.infimo)/2
end

#Creamos una función para medir el diametro de un intervalo
function diam(a::Intervalo)
    return a.supremo-a.infimo
end

#Creamos una función para bisectar un intervalo creando dos del mismo diametro
function biseccion(a::Intervalo)
    m=mid(a)
    return Intervalo(a.infimo,m),Intervalo(m,a.supremo)
end

#Creamos la función minimiza que buscara el valor minimo de una función dentro de un intervalo
function minimiza(f::Function,dom::Intervalo, tol::Real=1/1024)
    y_asterisco=Inf
    candidatos=[dom]
    bz=!(diam(dom)>tol)
    while !bz
        for _ in eachindex(candidatos)
            dominio = popfirst!(candidatos) 
            vf=f(dominio)
            y_asterisco < vf.infimo && continue
            m_i=f(mid(dominio))
            if m_i<y_asterisco
                y_asterisco=m_i
            end
            bisecta=biseccion(dominio)
            append!(candidatos, bisecta)
        end
        bz=maximum(diam.(candidatos))<tol
    end
    v_inc=findall(y_asterisco .∈ f.(candidatos))
    return candidatos[v_inc], y_asterisco
end

#Creamos la función maximiza que emplea para función minimiza para encontrar el valor máximo de una función dentro de un intervalo
function maximiza(f::Function,dom::Intervalo,tol::Real=1/1024)
    reflexion(x)=-f(x)
    xm, ym= minimiza(reflexion,dom)
    return xm,-ym
end