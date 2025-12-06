const FIG_VANDERPOL = joinpath(FIG_MODEL, "vanderpol")
mkpath(FIG_VANDERPOL)
let 
    model = VanDerPol()
    x0 = [randn(), randn()]
    dt = 0.01
    t_max = 50
    t_list = collect(0.0:dt:t_max)

    # TODO : Attractor
    x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
    filter = t_list .> 5

    ϵ_list = [0.0, 0.1, 1.0, 2.0, 4.0]
    plt1 = plot(title="Van der Pol Oscillator", xlabel="Time", ylabel="x",)
    plt2 = plot(title="Van der Pol Oscillator Phase Space", xlabel="x", ylabel="v",)
    plt3 = plot(title="Van der Pol Poincare Section", xlabel="x_n", ylabel="x_n+1",)
    plt4 = plot(title="Van der Pol return maps", xlabel="x_n", ylabel="x_n+1",)
    plt5 = plot(title="Amplitudes", xlabel="ϵ", ylabel="Amplitude",)
    plt6 = plot(title="Amplitudes", xlabel="ϵ", ylabel="Amplitude",)
    function poincare_section(x_sol, t_list)
        Poincare = []
        for (t, tt) in enumerate(t_list)
            if t == length(t_list)
                break
            end
            if x_sol[t, 2] * x_sol[t+1, 2] < 0 && x_sol[t, 1] > 0
                push!(Poincare, x_sol[t, 1])
            end
        end
        return Poincare
    end
    for ϵ in ϵ_list
        # TODO  solve
        model = VanDerPol(ϵ=ϵ)
        x0 = [2.0, 0.0]
        t_max = 20.0
        dt = 0.01
        t_list = collect(0:dt:t_max)
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        # TODO : solve nulclines
        # plot!(plt2, ~~~)
        # TODO : show plots
        plot!(plt1, t_list, x_sol[:, 1], label="ϵ=$ϵ")
        plot!(plt2, x_sol[:, 1], x_sol[:, 2], label="ϵ=$ϵ")
        # TODO : Poincare 断面
        x0 = [randn(), randn()]
        t_max = 200.0
        dt = 0.01
        t_list = collect(0:dt:t_max)
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        Poincare = poincare_section(x_sol, t_list)
        plot!(plt3, Poincare[1:end-1], Poincare[2:end], label="ϵ=$ϵ")
    end
    ϵ_list = collect(0.0:0.1:4.0)
    for ϵ in ϵ_list
        model = VanDerPol(ϵ=ϵ)
        x0 = [randn(), randn()]
        t_max = 200.0
        dt = 0.01
        t_list = collect(0:dt:t_max)
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        Poincare = poincare_section(x_sol, t_list)
        plot!(plt4, Poincare[1:end-1], Poincare[2:end], label="")
    end
    plot!(plt4, [0, 3], [0, 3], label="y=x", linestyle=:dash, color=:black)
    ϵ_list = collect(0.01:0.01:2.0)
    Amplitude = zeros(length(ϵ_list))
    for (i, ϵ) in enumerate(ϵ_list)
        model = VanDerPol(ϵ=ϵ)
        x0 = [randn(), randn()]
        t_max = 200.0
        dt = 0.01
        t_list = collect(0:dt:t_max)
        x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
        filter = t_list .> (t_max / 2)
        Amplitude[i] = maximum(x_sol[filter, 1]) - minimum(x_sol[filter, 1])
    end
    plot!(plt5, ϵ_list, Amplitude, label="Amplitude")
    plot!(plt6, ϵ_list, Amplitude, label="Amplitude", xscale=:log10, yscale=:log10)
    plot!(plt6, ϵ_list, sqrt.(ϵ_list) * Amplitude[end] / sqrt(ϵ_list[end]), label="ϵ^0.5", xscale=:log10, yscale=:log10)
    savefig(plt1, joinpath(FIG_VANDERPOL, "00_vanderpol_time.png"))
    savefig(plt2, joinpath(FIG_VANDERPOL, "01_vanderpol_phase_space.png"))
    savefig(plt3, joinpath(FIG_VANDERPOL, "02_vanderpol_poincare_section.png"))
    savefig(plt4, joinpath(FIG_VANDERPOL, "03_vanderpol_return_maps.png"))
    savefig(plt5, joinpath(FIG_VANDERPOL, "04_vanderpol_amplitudes.png"))
    savefig(plt6, joinpath(FIG_VANDERPOL, "05_vanderpol_amplitudes_loglog.png"))
    # TODO : Forced Van der Pol Oscillator
    ϵ_list = [0.0, 1.0, 2.0, 4.0]
    F_list = [0.1, 0.5, 1.0, 1.5]
    ω_list = [0.1, 0.5, 1.0, 1.5]
    for ϵ in ϵ_list
        ncols = length(F_list)
        nrows = length(ω_list)
        plt1 = plot(layout=(nrows, ncols), size=(300 * ncols, 250 * nrows), xlabel="", ylabel="", legend=false)
        plt2 = plot(layout=(nrows, ncols), size=(300 * ncols, 250 * nrows), xlabel="", ylabel="", legend=false)
        plt3 = plot(layout=(nrows, ncols), size=(300 * ncols, 250 * nrows), xlabel="", ylabel="", legend=false)
        for (f, F) in enumerate(F_list)
            for (w, ω) in enumerate(ω_list)
                idx = (f - 1) * ncols + w
                # solve
                model = VanDerPol(ϵ=ϵ, F=F, ω=ω)
                x0 = [1.0, 0.0]
                t_max = 200.0
                dt = 0.04
                t_list = collect(0:dt:t_max)
                x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
                # phase space
                filter = t_list .> (t_max / 2)
                xs = x_sol[filter, 1]
                ys = x_sol[filter, 2]
                plot!(plt1, xs, ys; subplot=idx, lw=1.5)
                plot!(plt1, title="F=$(F), ω=$(ω)", subplot=idx)
                # time position
                filter = t_list .> (t_max - 40.0)
                xs = x_sol[filter, 1]
                ys = x_sol[filter, 2]
                plot!(plt2, t_list[filter], xs; title="F=$(F), ω=$(ω)", subplot=idx, lw=1.5)
                plot!(plt2, t_list[filter], ys; title="F=$(F), ω=$(ω)", subplot=idx, lw=1.5)
                # FFT
                model = VanDerPol(ϵ=ϵ, F=F, ω=ω)
                x0 = [1.0, 0.0]
                t_max = 4000.0
                dt = 0.04
                t_list = collect(0:dt:t_max)
                x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)

                freq = fftfreq(length(t_list), 2π / dt)
                xf = real.(fft(x_sol[:, 1]))
                freq = fftshift(freq)
                xf = fftshift(xf)
                plot!(plt3, freq[freq.>=0], abs.(xf[freq.>=0]); subplot=idx, lw=1.5)
                plot!(plt3, title="F=$(F), ω=$(ω)", subplot=idx, xlim=(0, 4.0))
            end
        end
        savefig(plt1, joinpath(FIG_VANDERPOL, "10_vanderpol_phase_space_ϵ$(ϵ).png"))
        savefig(plt2, joinpath(FIG_VANDERPOL, "11_vanderpol_time_position_ϵ$(ϵ).png"))
        savefig(plt3, joinpath(FIG_VANDERPOL, "12_vanderpol_fft_ϵ$(ϵ).png"))
    end
    # TODO : Arnold tongue
    ϵ_list = [0.0, 1.0, 2.0, 4.0]
    df = 0.05
    dω = 0.05
    F_list = collect(df:df:4.0)
    ω_list = collect(dω:dω:4.0)
    for ϵ in ϵ_list
        nF = length(F_list)
        nω = length(ω_list)
        arnoldi = zeros(nF, nω)
        for (f, F) in enumerate(F_list)
            for (w, ω) in enumerate(ω_list)
                model = VanDerPol(ϵ=ϵ, F=F, ω=ω)
                x0 = [1.0, 0.0]
                t_max = 1000.0
                dt = 0.1
                t_list = collect(0:dt:t_max)
                x_sol = DynamicalModels.ode_solver(DynamicalModels.RK4, model, t_list, x0)
                # 区間の取り出し
                filter = t_list .> 200
                tt = t_list[filter]
                times = []
                xs = @view x_sol[filter, :]
                for (i, t) in enumerate(tt)
                    if i == length(tt)
                        break
                    end
                    if xs[i, 2] * xs[i+1, 2] < 0 && xs[i, 1] > 0
                        push!(times, t)
                    end
                end
                time_diff = times[2:end] .- times[1:end-1]
                arnoldi[f, w] = 2π / mean(time_diff)
                arnoldi[f, w] /= ω
            end
        end
        plt = heatmap(ω_list, F_list, arnoldi; ylabel="F", xlabel="ω", title="Arnold Tongue ϵ=$(ϵ)", colorbar_title="relative frequency", clim=(0, 3))
        savefig(plt, joinpath(FIG_VANDERPOL, "20_vanderpol_arnold_tongue_ϵ$(ϵ).png"))
    end
end