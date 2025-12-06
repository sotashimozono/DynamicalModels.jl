@testset "Lorenz" begin
    model = Lorenz()
    @test model.σ == 10.0
    @test model.ρ == 28.0
    @test model.β == 8/3

    @testset "Jacobian trace" begin
        n_tests = 100
        for n in 1:n_tests
            x = randn(3)
            ff = x -> model(n, x)
            J = ForwardDiff.jacobian(ff, x)
            detJ = tr(J)
            @test isapprox(detJ, -model.σ - model.β - 1; atol=1e-6)
        end
    end
end
