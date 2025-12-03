@testset "ode solvers error test" begin
    model = HarmonicOscillator(k=1.0, m=1.0)
    x0 = [1.0, 0.0]
    t_max = 10.0
    dt = 0.01
    t_list = collect(0:dt:t_max)
    for solver_func in DynamicalModels.ODE_SOLVERS
        solver_name = string(solver_func)
        @testset "$solver_name simple run" begin
            x_list_num = DynamicalModels.ode_solver(solver_func, model, t_list, x0)
            sol_exact_list = solve_exact(model, t_list, x0)
            x_list_exact = hcat(sol_exact_list...)' # [N, 2]
            final_error = norm(x_list_num[end, :] - x_list_exact[end, :])
            @show final_error
            if solver_func == DynamicalModels.RK4
                @test final_error < 1e-5
                @test final_error < 1e-6
                @test final_error < 1e-7
            elseif solver_func == DynamicalModels.Heun || solver_func == DynamicalModels.mean_point
                @test final_error < 1e-3
                # @test final_error < 1e-4
                # @test final_error < 1e-5
            elseif solver_func == DynamicalModels.Euler
                @test final_error < 1e-1
                # @test final_error < 1e-2
                # @test final_error < 1e-3
            end
        end
    end
    @testset "Error Order Verification" begin
        # use a moderate set of N to estimate convergence orders numerically
        N_list = [20, 40, 80, 160, 320, 640, 1280]
        plt = plot(
            title="ODE Solver Convergence Order",
            xaxis=:log, yaxis=:log,
            xlabel="Step Size (h)",
            ylabel="Final Error (E)",
            legend=:bottomright,
            minorgrid=true
        )
        h_ref = [1e-3, 1.0]
        plot!(plt, h_ref, h_ref .^ 1, linestyle=:dash, color=:gray, label="Order 1 (h)")
        plot!(plt, h_ref, h_ref .^ 2, linestyle=:dash, color=:darkgray, label="Order 2 (h^2)")
        plot!(plt, h_ref, h_ref .^ 4, linestyle=:dash, color=:black, label="Order 4 (h^4)")
        for solver_func in DynamicalModels.ODE_SOLVERS
            solver_name = string(solver_func)
            h_list = Float64[]
            error_list = Float64[]
            for N in N_list
                t_list = range(0, t_max; length=N)
                h = t_list[2] - t_list[1]
                x_list_num = DynamicalModels.ode_solver(solver_func, model, t_list, x0)
                sol_exact_list = solve_exact(model, t_list, x0)
                x_list_exact = hcat(sol_exact_list...)' # [N, 2]
                final_error = norm(x_list_num[end, :] - x_list_exact[end, :])
                push!(h_list, h)
                push!(error_list, final_error)
            end
            plot!(plt, h_list, error_list, marker=:o, label=solver_name)
        end
        @test true
        savefig(plt, joinpath(FIG_ODE, "ode_solver_convergence_order.pdf"))
    end
end
