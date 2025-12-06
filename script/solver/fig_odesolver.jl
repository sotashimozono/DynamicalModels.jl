let
    model = HarmonicOscillator(k=1.0, m=1.0)
    x0 = [1.0, 0.0]
    t_max = 10.0
    dt = 0.01
    t_list = collect(0:dt:t_max)

    # TODO : calculate convergence order and plot
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
    savefig(plt, joinpath(FIG_ODE, "convergence_order.png"))

    # TODO : plot trajectories for different solvers
    plt_traj = plot(
        title="ODE Solver Trajectories",
        xlabel="Time (t)",
        ylabel="Position (x)",
        legend=:topright,
        minorgrid=true
    )
    N = 1000
    t_list = range(0, t_max; length=N)
    for solver_func in DynamicalModels.ODE_SOLVERS
        solver_name = string(solver_func)
        x_list_num = DynamicalModels.ode_solver(solver_func, model, t_list, x0)
        plot!(plt_traj, t_list, x_list_num[:, 1], label=solver_name)
    end
    sol_exact_list = solve_exact(model, t_list, x0)
    x_list_exact = hcat(sol_exact_list...)' # [N, 2]
    plot!(plt_traj, t_list, x_list_exact[:, 1], linestyle=:dash, color=:black, label="Exact Solution")
    savefig(plt_traj, joinpath(FIG_ODE, "trajectories_harmonic_oscillator.png"))
end