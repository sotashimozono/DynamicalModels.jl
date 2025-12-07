const NUMERICAL_EPSILON = 1e-10

"""
    correlation_dimension(points; r_min=0.01, r_max=10.0, n_r=50)

Estimate the correlation dimension of a set of points using the Grassberger-Procaccia algorithm.

# Arguments
- `points`: Vector of points (each point is a vector)
- `r_min`: Minimum radius for correlation sum (default: 0.01)
- `r_max`: Maximum radius for correlation sum (default: 10.0)
- `n_r`: Number of radius values to test (default: 50)

# Returns
- Tuple of (radii, correlation_sums, estimated_dimension)

The correlation dimension is estimated from the slope of log(C(r)) vs log(r).

# Example
```julia
model = Lorenz()
trajectory = solve_trajectory(model, [1.0, 1.0, 1.0], 1000.0, 0.01)
radii, C, dim = correlation_dimension(trajectory)
```
"""
function correlation_dimension(points::Vector{Vector{T}}; 
                               r_min=0.01, r_max=10.0, n_r=50) where T
    N = length(points)
    
    if N < 2
        error("Need at least 2 points to calculate correlation dimension")
    end
    
    # Generate logarithmically spaced radii
    radii = exp.(range(log(r_min), log(r_max), length=n_r))
    
    # Calculate correlation sums
    C = zeros(Float64, n_r)
    
    for (i, r) in enumerate(radii)
        count = 0
        for j in 1:N
            for k in (j+1):N
                if norm(points[j] - points[k]) < r
                    count += 1
                end
            end
        end
        # Correlation sum
        C[i] = 2.0 * count / (N * (N - 1))
    end
    
    # Estimate dimension from linear region
    # Use middle portion of the curve to avoid edge effects
    log_r = log.(radii)
    log_C = log.(C .+ NUMERICAL_EPSILON)  # Add small value to avoid log(0)
    
    # Find linear region (middle 60% of data where C > 0)
    valid_indices = findall(C .> NUMERICAL_EPSILON)
    if length(valid_indices) < 2
        return radii, C, NaN
    end
    
    mid_start = valid_indices[div(length(valid_indices), 5)]
    mid_end = valid_indices[div(4 * length(valid_indices), 5)]
    
    if mid_end <= mid_start
        return radii, C, NaN
    end
    
    # Linear regression on log-log plot
    X = log_r[mid_start:mid_end]
    Y = log_C[mid_start:mid_end]
    
    # Calculate slope (dimension estimate)
    n_points = length(X)
    sum_x = sum(X)
    sum_y = sum(Y)
    sum_xy = sum(X .* Y)
    sum_x2 = sum(X .^ 2)
    
    dimension = (n_points * sum_xy - sum_x * sum_y) / (n_points * sum_x2 - sum_x^2)
    
    return radii, C, dimension
end
export correlation_dimension

"""
    kaplan_yorke_dimension(lyapunov_exponents)

Calculate the Kaplan-Yorke (Lyapunov) dimension from a spectrum of Lyapunov exponents.

# Arguments
- `lyapunov_exponents`: Vector of Lyapunov exponents (should be sorted in descending order)

# Returns
- Kaplan-Yorke dimension

The Kaplan-Yorke dimension is defined as:
D_KY = j + (λ_1 + λ_2 + ... + λ_j) / |λ_(j+1)|

where j is the largest integer such that λ_1 + λ_2 + ... + λ_j ≥ 0.

# Example
```julia
model = Lorenz()
x0 = [1.0, 1.0, 1.0]
λs = lyapunov_spectrum(model, x0, 0.1)
D_KY = kaplan_yorke_dimension(λs)
```
"""
function kaplan_yorke_dimension(lyapunov_exponents::Vector{T}) where T
    # Ensure sorted in descending order
    λs = sort(lyapunov_exponents, rev=true)
    
    # Find largest j such that sum of first j exponents is non-negative
    cumsum_λ = cumsum(λs)
    j = findlast(cumsum_λ .>= 0)
    
    if isnothing(j)
        # All exponents are negative
        return 0.0
    end
    
    if j == length(λs)
        # All exponents sum to positive (unbounded growth)
        return Float64(length(λs))
    end
    
    # Calculate Kaplan-Yorke dimension
    D_KY = j + cumsum_λ[j] / abs(λs[j+1])
    
    return D_KY
end
export kaplan_yorke_dimension

"""
    box_counting_dimension(trajectory, box_sizes)

Estimate the box-counting (capacity) dimension of a trajectory.

# Arguments
- `trajectory`: Vector of points representing a trajectory
- `box_sizes`: Vector of box sizes to test (if not provided, automatically generated)

# Returns
- Tuple of (box_sizes, N_boxes, estimated_dimension)

# Example
```julia
model = Lorenz()
trajectory = solve_trajectory(model, [1.0, 1.0, 1.0], 1000.0, 0.01)
sizes, N, dim = box_counting_dimension(trajectory)
```
"""
function box_counting_dimension(trajectory::Vector{Vector{T}}, 
                               box_sizes=nothing) where T
    if isempty(trajectory)
        error("Trajectory is empty")
    end
    
    dim = length(trajectory[1])
    
    # Find bounding box
    mins = minimum(hcat(trajectory...), dims=2)[:]
    maxs = maximum(hcat(trajectory...), dims=2)[:]
    extent = maximum(maxs - mins)
    
    # Generate box sizes if not provided
    if isnothing(box_sizes)
        box_sizes = extent ./ (2 .^ (1:10))
    end
    
    N_boxes = zeros(Int, length(box_sizes))
    
    for (i, ε) in enumerate(box_sizes)
        # Count number of occupied boxes
        occupied = Set{Vector{Int}}()
        
        for point in trajectory
            # Determine which box this point falls into
            box_indices = floor.(Int, (point - mins) / ε)
            push!(occupied, box_indices)
        end
        
        N_boxes[i] = length(occupied)
    end
    
    # Estimate dimension from slope of log(N) vs log(1/ε)
    log_inv_ε = log.(1 ./ box_sizes)
    log_N = log.(Float64.(N_boxes))
    
    # Linear regression
    n_points = length(log_inv_ε)
    sum_x = sum(log_inv_ε)
    sum_y = sum(log_N)
    sum_xy = sum(log_inv_ε .* log_N)
    sum_x2 = sum(log_inv_ε .^ 2)
    
    dimension = (n_points * sum_xy - sum_x * sum_y) / (n_points * sum_x2 - sum_x^2)
    
    return box_sizes, N_boxes, dimension
end
export box_counting_dimension
