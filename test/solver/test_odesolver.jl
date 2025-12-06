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
end
