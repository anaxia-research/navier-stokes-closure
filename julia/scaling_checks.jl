# Numerical checks of the three elementary transformations used in the closure:
#   (1) the viscosity scaling  u_ν(x,t) = √ν u(x/√ν, t),  p_ν = ν p(x/√ν, t),  f_ν = √ν f(x/√ν, t);
#   (2) the parabolic compression  ũ = λ u(λx, λ²(t-t0)),  p̃ = λ² p(...),  f̃ = λ³ f(...);
#   (3) the energy laws  ‖u_ν‖² = ν^{5/2} ‖u‖²  and  ‖ũ‖² = λ^{-1} ‖u‖².
# The test field is divergence free by construction (curl of a smooth vector potential), time
# dependent, and rapidly decaying; the force is *defined* as its Navier–Stokes residual, exactly
# as in the construction being verified. Derivatives are 8th-order central differences.
# Run:  julia scaling_checks.jl     (no packages needed)

using LinearAlgebra, Printf

const H = 1e-3
# 8th-order central first derivative of a scalar function g along a direction e
d1(g, x, e) = (672*(g(x+H*e)-g(x-H*e)) - 168*(g(x+2H*e)-g(x-2H*e)) +
               32*(g(x+3H*e)-g(x-3H*e)) - 3*(g(x+4H*e)-g(x-4H*e))) / (840H)
d2(g, x, e) = d1(y -> d1(g, y, e), x, e)
E3 = (Float64[1,0,0], Float64[0,1,0], Float64[0,0,1])

# vector potential A(x,t) and velocity u = curl A (divergence free); pressure p
A(x, t) = exp(-dot(x,x)) .* [sin(t + x[2]), cos(2t - x[3]), x[1]*(1 + t^2)]
function u(x, t)
    c(i, j) = d1(y -> A(y, t)[i], x, E3[j])
    [c(3,2) - c(2,3), c(1,3) - c(3,1), c(2,1) - c(1,2)]
end
p(x, t) = (1 + t) * exp(-0.5*dot(x,x)) * x[1]

# Navier–Stokes residual at viscosity ν for fields U(x,t), P(x,t)
function residual(U, P, ν, x, t)
    ut = (U(x, t + H) - U(x, t - H)) / (2H)          # 2nd order in t suffices for the ratio test
    adv = sum(U(x, t)[j] .* [d1(y -> U(y, t)[i], x, E3[j]) for i in 1:3] for j in 1:3)
    lap = [sum(d2(y -> U(y, t)[i], x, E3[j]) for j in 1:3) for i in 1:3]
    gp = [d1(y -> P(y, t), x, E3[i]) for i in 1:3]
    ut + adv - ν*lap + gp
end
divergence(U, x, t) = sum(d1(y -> U(y, t)[i], x, E3[i]) for i in 1:3)

f(x, t) = residual(u, p, 1.0, x, t)                 # force := residual at viscosity one

pts = [([0.3,-0.2,0.5], 0.4), ([-0.7,0.1,0.2], 0.9), ([0.05,0.6,-0.4], 0.15)]
ok = true
for ν in (0.25, 2.0, 9.0)
    s = sqrt(ν)
    uν(x, t) = s .* u(x ./ s, t); pν(x, t) = ν * p(x ./ s, t); fν(x, t) = s .* f(x ./ s, t)
    for (x, t) in pts
        xs = s .* x
        r = residual(uν, pν, ν, xs, t); g = fν(xs, t)
        err = norm(r - g) / max(norm(g), 1e-12)
        @printf("viscosity scaling  ν=%5.2f  relative error %.2e   div %.1e\n", ν, err, abs(divergence(uν, xs, t)))
        global ok &= err < 1e-4
    end
end
for λ in (2.0, 3.5)
    t0 = 0.2
    ũ(x, t) = λ .* u(λ .* x, λ^2*(t - t0)); p̃(x, t) = λ^2 * p(λ .* x, λ^2*(t - t0))
    f̃(x, t) = λ^3 .* f(λ .* x, λ^2*(t - t0))
    for (x, t) in pts
        xc = x ./ λ; tc = t0 + t/λ^2
        r = residual(ũ, p̃, 1.0, xc, tc); g = f̃(xc, tc)
        err = norm(r - g) / max(norm(g), 1e-12)
        @printf("compression        λ=%5.2f  relative error %.2e\n", λ, err)
        global ok &= err < 1e-4
    end
end
# energy laws by a midpoint rule on a cube that holds the essential support
function energy(U, t, L, n)
    h = 2L/n; s = 0.0
    for i in 1:n, j in 1:n, k in 1:n
        x = [-L + (i-0.5)h, -L + (j-0.5)h, -L + (k-0.5)h]; s += dot(U(x,t), U(x,t))
    end
    s * h^3
end
e1 = energy(u, 0.4, 4.0, 36)
for ν in (0.25, 4.0)
    s = sqrt(ν); uν(x, t) = s .* u(x ./ s, t)
    eν = energy(uν, 0.4, 4.0*s, 36)
    @printf("energy law  ν=%4.2f  ratio %.6f   predicted ν^(5/2) = %.6f\n", ν, eν/e1, ν^2.5)
    global ok &= abs(eν/e1 - ν^2.5) < 1e-6 * ν^2.5
end
println(ok ? "ALL CHECKS PASSED" : "SOME CHECK FAILED")
exit(ok ? 0 : 1)
