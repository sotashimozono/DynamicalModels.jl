@testset "Rossler" begin
    model = Rossler()
    @test model.a == 0.2
    @test model.b == 0.2
    @test model.c == 5.7
    @testset "Jacobian trace" begin
        n_tests = 100
        for n in 1:n_tests
            x = randn(3)
            ff = x -> model(n, x)
            J = ForwardDiff.jacobian(ff, x)
            detJ = tr(J)
            exact = model.a - model.c + x[1]
            @test isapprox(detJ, exact; atol=1e-6)
        end
    end
end