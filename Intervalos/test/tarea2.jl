# Tests de la Tarea2

using Test, Intervalos

@testset "Tarea2" begin

    raiz(r::Raiz) = getfield(r, :raiz)
    unicidad(r::Raiz) = getfield(r, :unicidad)

    @testset "Monotonicidad de funciones" begin
        #=
        Nota: algunos de los siguientes tests sobre monotonicidad, si bien
        imponen corrección en la implementación, por el tipo de redondeo
        que estamos usando, que es *demasiado* exagerado, dan resultados
        demasiado anchos y entonces no producen el resultado matemáticamente
        conocido. Esto ocurre en particular cuando el rango de la
        derivada tiene al cero en uno de los extremos.
        =#
        @test esmonotona(x->x^2, Intervalo(0.5, 1))
        @test !esmonotona(x->x^2, Intervalo(0.0, 1))
        @test !esmonotona(x->x^3+1, Intervalo(-1, 1))
        @test esmonotona(x->x^3+x, Intervalo(-2, -1))
        @test esmonotona(x->x^3+x, Intervalo(0.6, 1))
        @test esmonotona(x->x^3+x, Intervalo(-0.5, 0.5))
        @test !esmonotona(x->x^3-x^2, Intervalo(0.7, 1))
        @test !esmonotona(x-> 1 - x^4 + x^5, Intervalo(0, 1))
    end

    @testset "Raíces y ceros con el método de Newton" begin
        @test fieldnames(Raiz) == (:raiz, :unicidad)
        @test fieldtypes(Raiz) == (Intervalo, Bool)

        h(x) = 4*x + 3
        rr = ceros_newton(h, Intervalo(-1,0), 0.25)
        r = raiz(rr[1])
        @test -0.75 ∈ r
        @test diam(r) < 0.25
        @test unicidad(rr[1])

        # Este ejemplo no tiene raices
        r = ceros_newton(h, Intervalo(1,2), 0.5)
        @test length(r) == 0

        # Dos raices sencillas
        h1(x) = x^2 - 2
        rr1 = ceros_newton(h1, Intervalo(-10,10))
        @test rr1[1] isa Raiz
        @test any( sqrt(2) .∈ raiz.(rr1))
        @test any(-sqrt(2) .∈ raiz.(rr1))
        @test all( unicidad.(rr1) )
        @test all(0 .∈ h1.(raiz.(rr1)))

        h2(x) = 1 - x^4 + x^5
        rr2 = ceros_newton(h2, Intervalo(-10,10), 1/1024)
        @test rr2[1] isa Raiz
        @test all(0 .∈ h2.(raiz.(rr2)))
        @test all(unicidad.(rr2))
        @test all(diam.(raiz.(rr2)) .< 1/1024)

        # Este ejemplo muestra que a veces vale la pena usar un intervalo
        # no simétrico con el método de Newton. El ejemplo incluye raíces que no son únicas
        h3(x) = x^3*(4-5*x)
        rr3 = ceros_newton(h3, Intervalo(-big(3),4), big(1)/2^10)
        @test all(0 .∈ h3.(raiz.(rr3)))
        @test all(typeof.(raiz.(rr3)) .== Intervalo{BigFloat})
        @test any( 4//5 .∈ raiz.(rr3))
        @test any( 0 .∈ raiz.(rr3))
        @test any(unicidad.(rr3))
        @test !all(unicidad.(rr3))
        @test all(diam.(raiz.(rr3)) .< 1/1024)
        ii = findfirst(.!(unicidad.(rr3)))
        @test 0 ∈ raiz(rr3[ii])

        # Una raíz múltiple
        h4(x) = x*(x^3+1.5^3)^2
        rr4 = ceros_newton(h4, Intervalo(-10,21), 1/2^20)
        @test all( 0 .∈ h4.(raiz.(rr4)))
        @test any( -1.5 .∈ raiz.(rr4))
        @test any( 0 .∈ raiz.(rr4))
        # Raíz no única/simple
        ii = findfirst(.!(unicidad.(rr4)))
        @test -1.5 ∈ raiz(rr4[ii])
        # Raíz única/simple
        ii = findfirst(unicidad.(rr4))
        @test 0 ∈ raiz(rr4[ii])
    end

    @testset "Optimizacion" begin
        h(x) = 1 - x^4 + x^5
        xm, ym = minimiza(h, Intervalo(0,1))
        @test typeof(xm) <: Vector{T} where {T<: Intervalo}
        @test any(4/5 .∈ xm)
        @test all(ym .∈ h.(xm))

        xM, yM = maximiza(h, Intervalo(0,1))
        @test any( 0 .∈ xM)
        @test any( 1 .∈ xM)
        @test all(yM .∈ h.(xM))

        g(x) = 4*x + 3
        xm, ym = minimiza(g, Intervalo(big(1),2), big(1)/125)
        @test any(1 .∈ xm)
        @test all(ym .∈ g.(xm))
        xM, yM = maximiza(g, Intervalo(big(1),2), big(1)/125)
        @test any(2 .∈ xM)
        @test all(yM .∈ g.(xM))
    end
end