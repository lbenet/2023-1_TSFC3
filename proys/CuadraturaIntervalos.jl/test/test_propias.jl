# Tests de integrales propias

using Test

using CuadraturaIntervalos, SpecialFunctions

@testset "Integrales propias sencillas" begin

    # Parámetros 
    local N = 1_000
    local tol = 1e-8
    local order = 20

    # Ejemplo 1: 
    # ∫_[0, 1] x = 0.5

    local D_1 = 0 .. 1
    # Función 
    f_1(x) = x
    # Respuesta 
    R_1 = 0.5
    # Test 
    redondeo(true)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)

    redondeo(false)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)

    # Ejemplo 2: 
    # ∫_[-π/2, π/2] sin(x) = 0

    local D_2 = -π/2 .. π/2

    # Función 
    f_2(x) = sin(x)
    # Respuesta 
    R_2 = 0
    # Test 
    redondeo(true)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)

    redondeo(false)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)

    # Ejemplo 3: 
    # ∫_[-1, 2] exp(x) = e^2 - 1/e

    local D_3 = -1 .. 2
    # Función 
    f_3(x) = exp(x)
    # Respuesta 
    R_3 = big(ℯ)^2 - 1/big(ℯ)
    # Test 
    redondeo(true)

    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)

    redondeo(false)

    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)

end

@testset "Integrales propias intermedias" begin
    
    # Parámetros 
    local N = 1_000
    local tol = 1e-8
    local order = 20

    # Ejemplo 1: 
    # ∫_[0, π] exp(x) * (1 + sin(x)) = (3e^π - 1) / 2

    local D_1 = 0 .. π
    # Función 
    f_1(x) = exp(x) + exp(x) * sin(x)
    # Respuesta 
    R_1 = (3 * big(ℯ)^big(π) - 1) / 2
    # Test 
    redondeo(true)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)

    redondeo(false)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)
    
    # Ejemplo 2: 
    # ∫_[0.5, 1] x^2 log(x) - 1 = (3*log(2) - 43) / 72

    local D_2 = 0.5 .. 1

    # Función 
    f_2(x) = x^2 * log(x) - 1
    # Respuesta 
    R_2 = ( 3 * log(big(2)) - 43) / 72
    # Test 
    redondeo(true)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)

    redondeo(false)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)
    
    # Ejemplo 3: 
    # ∫_[-1, 1] (1 - x^2) * cos(x) = 4(sin(1) - cos(1))

    local D_3 = -1 .. 1
    # Función 
    f_3(x) = cos(x) - x^2 * cos(x)
    # Respuesta 
    R_3 = 4 * (sin(big(1)) - cos(big(1)))
    # Test 
    redondeo(true)

    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)

    redondeo(false)
     
    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)
end

@testset "Integrales propias avanzadas" begin

    # Parámetros 
    local N = 1_000
    local tol = 1e-8
    local order = 15

    # Ejemplo 1: 
    # ∫_[0, 1] x^(-x) dx = ∑_{n=1}^∞ n^(-n)

    local D_1 = 0 .. 1
    # Función 
    f_1(x) = x^(-x)
    # Respuesta 
    function respuesta_1(N::Int)
        suma = 0.
        for i in 1:N
            suma += float(i)^(-i)
            i += 1
        end

        return suma
    end
    R_1 = respuesta_1(20)
    # Test 
    redondeo(true)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)

    redondeo(false)

    @test R_1 ∈ cuadratura_simple(f_1, D_1, N)
    @test R_1 ∈ cuadratura_uniforme(f_1, D_1, N, order)
    @test R_1 ∈ cuadratura_adaptativa(f_1, D_1, tol, order)

    # Ejemplo 2: 
    # ∫_[0, 1] x^x dx = -∑_{n=1}^∞ (-n)^(-n)

    local D_2 = 0 .. 1
    # Función 
    f_2(x) = x^x
    # Respuesta
    function respuesta_2(N::Int)
        suma = 0.
        for i in 1:N
            suma += float(-i)^(-i)
            i += 1
        end

        return -suma
    end
    R_2 = respuesta_2(20)
    # Test 
    redondeo(true)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)

    redondeo(false)

    @test R_2 ∈ cuadratura_simple(f_2, D_2, N)
    @test R_2 ∈ cuadratura_uniforme(f_2, D_2, N, order)
    @test R_2 ∈ cuadratura_adaptativa(f_2, D_2, tol, order)

    # Ejemplo 3: 
    # ∫_[0, 1] x^(α - 1) * (1 - x)^(β-1) dx = Γ(α)Γ(β)/Γ(α + β)
    local α = 3/2
    local β = 7/5

    local order = 20
    local D_3 = 0 .. 1
    # Función 
    f_3(x) = x^(α - 1) * (1 - x)^(β - 1)
    # Respuesta
    R_3 = gamma(big(α)) * gamma(big(β)) / gamma(big(α + β))
    # Test 
    redondeo(true)

    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)

    redondeo(false)

    @test R_3 ∈ cuadratura_simple(f_3, D_3, N)
    @test R_3 ∈ cuadratura_uniforme(f_3, D_3, N, order)
    @test R_3 ∈ cuadratura_adaptativa(f_3, D_3, tol, order)
end