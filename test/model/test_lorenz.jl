@testset "Lorenz" begin
    model = Lorenz()
    @test model.σ == 10.0
    @test model.ρ == 28.0
    @test model.β == 8/3
    x0 = [randn(), randn(), randn()]
    dt = 0.01
    t_max = 50
    t_list = collect(0.0:dt:t_max)
    @testset "Attractor" begin
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        filter = t_list .> 5
        x_sol_plot = @view x_sol[filter, :]
        plt = plot3d(x_sol_plot[:, 1], x_sol_plot[:, 2], x_sol_plot[:, 3]; array=true, xlabel="X", ylabel="Y", zlabel="Z", title="Attractor of " * string(typeof(model)), aspect_ratio=:equal, label="", lw=0.50)
        savefig(plt, joinpath(PATHS[:lorenz], "00_lorenz_attractor.pdf"))
        @test true
    end
    @testset "Divergence of nearby trajectories" begin
        diff_list = [1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3]
        x1 = [randn(), randn(), randn()]
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        plt = plot(xlabel="Time", ylabel="Distance", title="Divergence of nearby trajectories in " * string(typeof(model)), yscale=:log10, label="", minorgrid=true, legend=:topleft)
        for dd in diff_list
            xx = x0 .+ x1 .* dd
            x_sol1 = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, xx)

            diff = x_sol1 .- x_sol
            norms = [norm(diff[i, :]) for i in 1:size(diff, 1)]
            plot!(t_list, norms; label="initial diff $(dd)", lw=0.5)
        end
        savefig(plt, joinpath(PATHS[:lorenz], "01_lorenz_divergence_initial_diff.pdf"))
        @test true
    end
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
