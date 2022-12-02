# Tests de integrales propias

using Test

using CuadraturaIntervalos, SpecialFunctions

@testset "Integrales impropias" begin
    # Parámetros 
    local N = 1_000
    local tol = 1e-8
    local order = 20

    # Ejemplo 1: 
    # ∫_[0, ∞] sqrt(x)*exp(-x) = sqrt(π)/2

    local D_1 = 0 .. Inf
    # Función 
    f_1(x) = sqrt(x) * exp(-x)
    # Respuesta 
    R_1 = sqrt(big(π)) / 2
    # Test 
    redondeo(true)

    @test R_1 ∈ cuadratura_infinita(f_1, D_1, tol, order)

    redondeo(false)

    @test R_1 ∈ cuadratura_infinita(f_1, D_1, tol, order)

    # Ejemplo 2: 
    # ∫_[0, ∞] exp(-3x^2) = sqrt(π/3)/2

    local D_2 = 0 .. Inf
    # Función 
    f_2(x) = exp(-3*x^2)
    # Respuesta 
    R_2 = sqrt(big(π)/3) / 2
    # Test 
    redondeo(true)

    @test R_2 ∈ cuadratura_infinita(f_2, D_2, tol, order)

    redondeo(false)

    @test R_2 ∈ cuadratura_infinita(f_2, D_2, tol, order)

    # Ejemplo 3: 
    # ∫_[0, ∞] x^2 * exp(-5x^2) = sqrt(π/5^3)/4

    local D_3 = 0 .. Inf
    # Función 
    f_3(x) = x^2 * exp(-5*x^2)
    # Respuesta 
    R_3 = sqrt(big(π)/5^3) / 4
    # Test 
    redondeo(true)

    @test R_3 ∈ cuadratura_infinita(f_3, D_3, tol, order)

    redondeo(false)

    @test R_3 ∈ cuadratura_infinita(f_3, D_3, tol, order)

    # Ejemplo 4: 
    # ∫_[0, ∞] x^3 * exp(-7x^2) = 1 / (2 * 7^2)

    local D_4 = 0 .. Inf
    # Función 
    f_4(x) = x^3 * exp(-7*x^2)
    # Respuesta 
    R_4 = 1 / big(2 * 7^2)
    # Test 
    redondeo(true)

    @test R_4 ∈ cuadratura_infinita(f_4, D_4, tol, order)

    redondeo(false)

    @test R_4 ∈ cuadratura_infinita(f_4, D_4, tol, order)

    # Ejemplo 5: 
    # ∫_[-∞, ∞] exp(-(x^2 + 2x + 3)) = sqrt(π) * exp(-2)

    local D_5 = -Inf .. Inf
    # Función 
    f_5(x) = exp(-(x^2 + 2x + 3))
    # Respuesta 
    R_5 = sqrt(big(π)) * exp(-big(2))
    # Test 
    redondeo(true)

    @test R_5 ∈ cuadratura_infinita(f_5, D_5, tol, order)

    redondeo(false)

    @test R_5 ∈ cuadratura_infinita(f_5, D_5, tol, order)

    # Ejemplo 6: 
    # ∫_[0, ∞] x^(z-1) * exp(-x) = Γ(z)
    local z = 7/5

    local D_6 = 0 .. Inf
    # Función 
    f_6(x) = x^(z-1) * exp(-x)
    # Respuesta 
    R_6 = gamma(big(z))
    # Test 
    redondeo(true)

    @test R_6 ∈ cuadratura_infinita(f_6, D_6, tol, order)

    redondeo(false)

    @test R_6 ∈ cuadratura_infinita(f_6, D_6, tol, order)
    
end