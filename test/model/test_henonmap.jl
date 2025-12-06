@testset "Henon Map Visualization" begin
    model = HenonMap()
    @test model.a == 1.4
    @test model.b == 0.3
    @testset "Jacobian determinant" begin
        n_tests = 100
        for n in 1:n_tests
            x = randn(2)
            ff = x -> model(n, x)
            J = ForwardDiff.jacobian(ff, x)
            detJ = det(J)
            @test isapprox(detJ, -model.b; atol=1e-6)
        end
    end
end
