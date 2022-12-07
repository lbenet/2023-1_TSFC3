"""funcion que devuelve dos intervalos correspondientes a las dos mitades
de un intervalo dado"""

function bisecta(dom::Intervalo)
    return Intervalo(dom.infimo,mid(dom)),Intervalo(mid(dom),dom.supremo)
end

#funcion que devuelve el minimo de una funcion dado un intervalo
function minimiza(f::Function,D::Intervalo, tol=1/1024)
    yi=Inf #cota superior
    X=[D] #se crea el vector que contendra los candidatos iniciando con el intervalo inicial 
    b = true #variable para ejecutar el ciclo while
    while b
        x0 = popfirst!(X) #se toma el primer candidatos
        mi=f(mid(x0)) #se evalua la funcion en el punto medio
        if mi<yi #se compara el resultado respecto a la cota
            yi=mi # si se cumple se reasigna un nuevo valor a la cota
        end
        append!(X, bisecta(x0)) #se agregan la biseccion del intervalo a los candidatos             
        b =  maximum(diam.(X))<tol #se comprueba el diametro de los candidatos, 
    end                            #si es menor a la tolerancia se detiene el ciclo while

    indice = [] #vector que contendra los indices correspondiente a los candidatos que cumplen
    for i in eachindex(X)
        if yi ∈ f(X[i]) 
            push!(indice, i) 
        end
    end
    
    return X[indice], yi 
end

#funcion que devuelve el maximo de una funcion dado un intervalo usando la funcion
#creada antes
function maximiza(f::Function,D::Intervalo,tol=1/1024)
    f1(x)=-f(x)
    xm, ym= minimiza(f1,D)
    return xm,-ym
end