"""
    poincare_section(model, x0, plane_normal, plane_point, t_max; dt=0.01, direction=:both)

Calculate a Poincaré section for a continuous dynamical system.

# Arguments
- `model`: The dynamical model (must be callable with signature `model(t, x)`)
- `x0`: Initial condition vector
- `plane_normal`: Normal vector to the Poincaré section plane
- `plane_point`: A point on the Poincaré section plane
- `t_max`: Maximum integration time
- `dt`: Time step for integration (default: 0.01)
- `direction`: Direction of crossing to record: `:positive`, `:negative`, or `:both` (default: `:both`)

# Returns
- Vector of points where trajectory crosses the Poincaré section

# Example
```julia
model = Lorenz()
x0 = [1.0, 1.0, 1.0]
# Define plane z = 27 (for Lorenz system with ρ=28)
plane_normal = [0.0, 0.0, 1.0]
plane_point = [0.0, 0.0, 27.0]
section = poincare_section(model, x0, plane_normal, plane_point, 1000.0)
```
"""
function poincare_section(model, x0::AbstractVector{T}, 
                         plane_normal::AbstractVector{T}, 
                         plane_point::AbstractVector{T}, 
                         t_max::Real; 
                         dt=0.01, 
                         direction=:both) where T
    # Normalize the plane normal
    n = plane_normal / norm(plane_normal)
    
    section_points = Vector{Vector{T}}()
    
    t = 0.0
    x = copy(x0)
    
    # Calculate signed distance from plane
    dist_prev = dot(x - plane_point, n)
    
    n_steps = ceil(Int, t_max / dt)
    
    for _ in 1:n_steps
        # RK4 step
        k1 = model(t, x)
        k2 = model(t + dt/2, x + dt/2 * k1)
        k3 = model(t + dt/2, x + dt/2 * k2)
        k4 = model(t + dt, x + dt * k3)
        
        x_new = x + (dt/6) * (k1 + 2*k2 + 2*k3 + k4)
        t += dt
        
        # Check if crossed the plane
        dist_new = dot(x_new - plane_point, n)
        
        if dist_prev * dist_new < 0  # Sign changed, crossed the plane
            # Determine crossing direction
            crossing_positive = dist_new > dist_prev
            
            record = false
            if direction == :both
                record = true
            elseif direction == :positive && crossing_positive
                record = true
            elseif direction == :negative && !crossing_positive
                record = true
            end
            
            if record
                # Linear interpolation to find intersection point
                α = abs(dist_prev) / (abs(dist_prev) + abs(dist_new))
                x_section = x + α * (x_new - x)
                push!(section_points, x_section)
            end
        end
        
        x = x_new
        dist_prev = dist_new
    end
    
    return section_points
end
export poincare_section

"""
    poincare_map_2d(model, x0, coord_indices, plane_normal, plane_point, t_max; dt=0.01, direction=:both)

Calculate a 2D Poincaré map by projecting section points onto specified coordinates.

# Arguments
- `model`: The dynamical model
- `x0`: Initial condition vector
- `coord_indices`: Tuple of two indices specifying which coordinates to plot (e.g., (1, 2) for x and y)
- `plane_normal`: Normal vector to the Poincaré section plane
- `plane_point`: A point on the Poincaré section plane
- `t_max`: Maximum integration time
- `dt`: Time step for integration (default: 0.01)
- `direction`: Direction of crossing to record (default: `:both`)

# Returns
- Tuple of (x_coords, y_coords) containing the 2D projection of section points

# Example
```julia
model = Rossler()
x0 = [1.0, 1.0, 1.0]
# Poincaré section at y = 0
plane_normal = [0.0, 1.0, 0.0]
plane_point = [0.0, 0.0, 0.0]
x_coords, z_coords = poincare_map_2d(model, x0, (1, 3), plane_normal, plane_point, 1000.0)
```
"""
function poincare_map_2d(model, x0::AbstractVector{T}, 
                        coord_indices::Tuple{Int, Int},
                        plane_normal::AbstractVector{T}, 
                        plane_point::AbstractVector{T}, 
                        t_max::Real; 
                        dt=0.01, 
                        direction=:both) where T
    section_points = poincare_section(model, x0, plane_normal, plane_point, t_max; 
                                     dt=dt, direction=direction)
    
    i1, i2 = coord_indices
    
    if isempty(section_points)
        return T[], T[]
    end
    
    x_coords = [p[i1] for p in section_points]
    y_coords = [p[i2] for p in section_points]
    
    return x_coords, y_coords
end
export poincare_map_2d
