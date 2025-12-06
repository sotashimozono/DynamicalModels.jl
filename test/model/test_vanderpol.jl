@testset "van der Pol oscillator test" begin
    model = VanDerPol()
    @test model.ϵ == 1.0
    @test model.F == 0.0
    @test model.ω == 0.0

    @testset "Jacobian trace" begin
        n_tests = 100
        for n in 1:n_tests
            x = randn(2)
            ff = x -> model(n, x)
            J = ForwardDiff.jacobian(ff, x)
            trJ = tr(J)
            exact = model.ϵ - x[1]^2
            @test isapprox(trJ, exact; atol=1e-6)
        end
    end
    model = VanDerPolMu()
    @test model.μ == 1.0
    @test model.F == 0.0
    @test model.ω == 0.0
end