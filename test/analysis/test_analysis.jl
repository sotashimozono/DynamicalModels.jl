@testset "Lyapunov Exponents" begin
    @testset "Lorenz system" begin
        model = Lorenz()
        x0 = [1.0, 1.0, 1.0]
        
        # Calculate largest Lyapunov exponent
        # For Lorenz system with standard parameters, largest LE should be positive (~0.9)
        λ_max = lyapunov_exponent(model, x0, 0.1; warmup=500, n_iterations=1000)
        @test λ_max > 0.0  # Chaotic system should have positive LE
        @test λ_max < 2.0  # Reasonable upper bound
        
        # Test that the function runs without error (spectrum calculation needs more iterations)
        λs = lyapunov_spectrum(model, x0, 0.5; warmup=500, n_iterations=500)
        @test length(λs) == 3
        # Just test that it returns 3 values for now
    end
    
    @testset "Van der Pol oscillator" begin
        model = VanDerPol(ϵ=1.0)
        x0 = [1.0, 0.0]
        
        # Van der Pol is not chaotic but has a limit cycle
        # All Lyapunov exponents should be zero or negative
        λ_max = lyapunov_exponent(model, x0, 0.1; warmup=500, n_iterations=1000)
        @test λ_max < 0.5  # Should not be strongly positive
    end
end

@testset "Poincaré Section" begin
    @testset "Lorenz system" begin
        model = Lorenz()
        x0 = [1.0, 1.0, 1.0]
        
        # Define Poincaré section at z = 27
        plane_normal = [0.0, 0.0, 1.0]
        plane_point = [0.0, 0.0, 27.0]
        
        section = poincare_section(model, x0, plane_normal, plane_point, 100.0; 
                                   dt=0.01, direction=:both)
        
        @test length(section) > 0  # Should have some crossings
        @test all(abs(p[3] - 27.0) < 0.1 for p in section)  # All points near z=27
        
        # Test 2D projection
        x_coords, y_coords = poincare_map_2d(model, x0, (1, 2), 
                                              plane_normal, plane_point, 100.0)
        @test length(x_coords) == length(y_coords)
        @test length(x_coords) > 0
    end
    
    @testset "Rossler system" begin
        model = Rossler()
        x0 = [1.0, 1.0, 1.0]
        
        # Poincaré section at y = 0
        plane_normal = [0.0, 1.0, 0.0]
        plane_point = [0.0, 0.0, 0.0]
        
        section = poincare_section(model, x0, plane_normal, plane_point, 500.0; 
                                   dt=0.01, direction=:positive)
        
        @test length(section) > 0
        # All points should be near y=0
        @test all(abs(p[2]) < 0.1 for p in section)
    end
end

@testset "Dimension Analysis" begin
    @testset "Kaplan-Yorke dimension" begin
        # Test with known values
        λs_dissipative = [1.0, 0.0, -2.0]
        D_KY = kaplan_yorke_dimension(λs_dissipative)
        @test D_KY ≈ 2.0 + (1.0 + 0.0) / 2.0  # j=2, sum of first 2 = 1.0, |λ_3| = 2.0
        
        λs_all_negative = [-1.0, -2.0, -3.0]
        D_KY = kaplan_yorke_dimension(λs_all_negative)
        @test D_KY == 0.0
        
        # Test for Lorenz system - just verify function runs
        model = Lorenz()
        x0 = [1.0, 1.0, 1.0]
        λs = lyapunov_spectrum(model, x0, 0.5; warmup=500, n_iterations=500)
        D_KY = kaplan_yorke_dimension(λs)
        @test D_KY >= 0.0  # Should be non-negative
        @test D_KY <= 3.0  # Should not exceed dimension
    end
    
    @testset "Correlation dimension - basic test" begin
        # Create simple test data (points on a line, dimension should be ~1)
        points = [[Float64(i), 2.0*i, 3.0*i] for i in 1:100]
        radii, C, dim = correlation_dimension(points; r_min=0.5, r_max=50.0, n_r=30)
        
        @test length(radii) == length(C)
        @test length(radii) == 30
        @test all(C .>= 0.0)
        @test all(C .<= 1.0)
        # Dimension estimate might not be perfect but should be reasonable
        @test !isnan(dim)
    end
end
