@doc raw"""
    bisecta(a::Intervalo)

Divide `a` por la mitad. 
"""
function bisecta(a::Intervalo)
    m = mid(a)
    return Intervalo(a.infimo, m), Intervalo(m, a.supremo)
end

@doc raw"""
    riemann_term(f::Function, D::Intervalo, order::Int)

Calcula el término de Riemman de `f` en `D` usando una serie de Taylor de orden `order`. 
Ver la ecuación (5.18) de Tucker, W. (2011). Validated Numerics. Estados Unidos: Princeton 
University Press. 
"""
function riemann_term(f::Function, D::Intervalo, order::Int)
    # Punto medio
    x = mid(D)
    # Expansión de Taylor (normal)
    f_t = taylor_expand(f, x; order = order)
    # Expansión de Taylor (intervalar)
    F_t = taylor_expand(f, D; order = order)
    # Epsilon 
    ϵ = mag( F_t[order] - f_t[order] )
    # Intervalo epsilon
    ϵ_I = Intervalo(-ϵ, ϵ)
    # Radio 
    r = rad(D)

    term = zero(D)

    # Término de Riemann 
    for k in 0:floor(Int, order/2)
        term += f_t[2*k] * r^(2*k + 1) / (2*k + 1)
    end
    term += ϵ_I * r^(order + 1) / (order + 1)

    return 2 * term
end

@doc raw"""
    cuadratura_simple(f::Function, D::Intervalo, N::Int = 100)

Calcula la integral de `f` en `D` usando la ecuación (5.14) de Tucker, W. (2011). Validated 
Numerics. Estados Unidos: Princeton University Press con `N` pasos de igual longitud. 
"""
function cuadratura_simple(f::Function, D::Intervalo, N::Int = 100)

    @assert isfinite(D) "Para intervalos con algún extremo infinito usar `cuadratura_infinita`"

    # Iniciamos la suma en 0
    quad = zero(D)
    # Paso 
    dt = diam(D)/N
    # Iteramos sobre el número de intervalos 
    for i in 1:N
        # Intervalo local 
        D_0 = Intervalo(D.infimo + (i-1)*dt, D.infimo + i*dt)
        # Intervalo ingenuo 
        quad += diam(D_0) * f(D_0)
    end

    return quad
end

@doc raw"""
    cuadratura_uniforme(f::Function, D::Intervalo, N::Int = 100, order::Int = 10)   

Calcula la integral de `f` en `D` usando la ecuación (5.18) de Tucker, W. (2011). Validated 
Numerics. Estados Unidos: Princeton University Press con `N` pasos de igual longitud. 
"""
function cuadratura_uniforme(f::Function, D::Intervalo, N::Int = 100, order::Int = 10)
    
    @assert isfinite(D) "Para intervalos con algún extremo infinito usar `cuadratura_infinita`"
    
    # Iniciamos la suma en 0
    quad = zero(D)
    # Paso 
    dt = diam(D)/N
    # Iteramos sobre el número de intervalos 
    for i in 1:N
        # Intervalo local 
        D_0 = Intervalo(D.infimo + (i-1)*dt, D.infimo + i*dt)
        # Término de Riemann
        quad += riemann_term(f, D_0, order)
    end

    return quad
    
end

@doc raw"""
    cuadratura_adaptativa(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}

Calcula la integral de `f` en `D` usando la ecuación (5.18) de Tucker, W. (2011). Validated 
Numerics. Estados Unidos: Princeton University Press con pasos adaptativos. 
"""
function cuadratura_adaptativa(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}
    
    @assert isfinite(D) "Para intervalos con algún extremo infinito usar `cuadratura_infinita`"

    # Término de Riemann inicial 
    quad = riemann_term(f, D, order)
    
    if diam(quad) ≤ tol
        # El término de Riemann es más pequeño que tol -> terminar 
        return quad
    else 
        # Bisectar 
        left, right = bisecta(D)
        # Aplicar cuadratura adaptativa de forma recursiva 
        return cuadratura_adaptativa(f, left, tol/2, order) + cuadratura_adaptativa(f, right, tol/2, order)
    end
    
end

function cuadratura_mas_∞(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}
    
    @assert isfinite(D.infimo) && isinf(D.supremo) "Esta función sólo funciona para intervalos de la forma `[a, ∞]`"

    # Primer intervalo 
    new_D = Intervalo(D.infimo, D.infimo + 1)
    # Primera integral 
    quad = cuadratura_adaptativa(f, new_D, tol, order)
    new_quad = quad
    # "Error" 
    ϵ = mag(new_quad)

    while ϵ > tol
        # Intervalo actual 
        new_D = Intervalo(new_D.supremo, new_D.supremo + 1)
        # Integral actual 
        new_quad = cuadratura_adaptativa(f, new_D, tol, order)
        # "Error" 
        ϵ = mag(new_quad)
        # Sumamos 
        quad += new_quad
    end

    return quad + Intervalo(-ϵ, ϵ)
end

function cuadratura_menos_∞(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}
    
    @assert isinf(D.infimo) && isfinite(D.supremo) "Esta función sólo funciona para intervalos de la forma `[-∞, a]`"

    # Primer intervalo 
    new_D = Intervalo(D.supremo - 1, D.supremo)
    # Primera integral 
    quad = cuadratura_adaptativa(f, new_D, tol, order)
    new_quad = quad
    # "Error" 
    ϵ = mag(new_quad)

    while ϵ > tol
        # Intervalo actual 
        new_D = Intervalo(new_D.infimo - 1, new_D.infimo)
        # Integral actual 
        new_quad = cuadratura_adaptativa(f, new_D, tol, order)
        # "Error" 
        ϵ = mag(new_quad)
        # Sumamos 
        quad += new_quad
    end

    return quad + Intervalo(-ϵ, ϵ)
end

@doc raw"""
    cuadratura_infinita(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}

Calcula la integral de `f` en `D` permitiendo la posibilidad de que alguno (o ambos) de los 
extremos de `D` sean infinitos.  
"""
function cuadratura_infinita(f::Function, D::Intervalo, tol::T = 1e-8, order::Int = 10) where {T <: AbstractFloat}
    
    lo_finito = isfinite(D.infimo)
    hi_finito = isfinite(D.supremo)
    
    if lo_finito && hi_finito
        return cuadratura_adaptativa(f, D, tol, order)
    elseif lo_finito && (!hi_finito)
        cuadratura_mas_∞(f, D, tol, order)
    elseif (!lo_finito) && hi_finito
        cuadratura_menos_∞(f, D, tol, order)
    elseif (!lo_finito) && (!hi_finito)
        return cuadratura_mas_∞(f, 0 .. Inf, tol, order) + cuadratura_menos_∞(f, -Inf .. 0, tol, order)
    end
end