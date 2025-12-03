@testset "Henon Map Visualization" begin
    model = HenonMap()
    @test model.a == 1.4
    @test model.b == 0.3
    @testset "Attractor" begin
        x0 = [0.0, 0.0]
        n_steps = 100000
        x_sol = map_solver(model, n_steps, x0)
        x_sol = x_sol[10:end, :]
        ncols = 2
        nrows = 2

        plt = plot(layout=(2, 2), size=(300 * ncols, 300 * nrows), xlabel="", ylabel="", legend=false)
        scatter!(plt, x_sol[:, 1], x_sol[:, 2], xlim=(-1.5, 1.5), ylim=(-0.5, 0.5), markersize=0.5, subplot=1)
        scatter!(plt, x_sol[:, 1], x_sol[:, 2], xlim=(0.0, 0.6), ylim=(0.1, 0.3), markersize=0.5, subplot=2)
        scatter!(plt, x_sol[:, 1], x_sol[:, 2], xlim=(0.1, 0.2), ylim=(0.2, 0.25), markersize=0.5, subplot=3)
        scatter!(plt, x_sol[:, 1], x_sol[:, 2], xlim=(0.105, 0.12), ylim=(0.23, 0.245), markersize=0.5, subplot=4)
        savefig(plt, joinpath(PATHS[:henon], "00_henon_map.pdf"))
        @test true
    end
    @testset "Divergence of nearby trajectories" begin
        x0 = randn(2)
        x1 = randn(2)
        diff_list = [1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3]
        plt = plot(xlabel="Steps", ylabel="Distance", title="Divergence of nearby trajectories in Henon Map", yscale=:log10, label="", legend=:topleft, minorgrid=true)
        for dd in diff_list
            xx = x0 .+ x1 .* dd
            n_steps = 50
            x_sol0 = map_solver(model, n_steps, x0)
            x_sol1 = map_solver(model, n_steps, xx)

            norms = [norm(x_sol1[n, :] .- x_sol0[n, :]) for n in 1:size(x_sol0, 1)]
            plot!(plt, 1:n_steps, norms; label="initial diff $(dd)", lw=0.5)
        end
        savefig(plt, joinpath(PATHS[:henon], "01_henon_divergence_initial_diff.pdf"))
        @test true
    end
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
