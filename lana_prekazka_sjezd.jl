using LinearAlgebra, NLsolve, CairoMakie

function plot_geometry()
    uBA_v  = (A  - B) / norm(A  - B)
    uBC1_v = (C1 - B) / norm(C1 - B)
    uBC2_v = (C2 - B) / norm(C2 - B)

    # délka šipky proporcionální k síle: mg = referenční 1.0 m
    fs     = 1.0 / (m * g)   # [m/N]  škálovací faktor sil
    al_2T  = fs * 2T
    al_T   = fs * T
    al_mg  = fs * m * g       # = 1.0 m
    lo = 0.25                 # odsazení popisku od špičky šipky [m]

    # popisek: "X N (≈ Y kg)"
    flabel(F) = "$(round(F, digits=0)) N (≈ $(round(F/g, digits=1)) kg)"

    # kolmý směr od šipky pro umístění popisku (rotace 90° CCW)
    perp(v) = [-v[2], v[1]] / norm(v)

    fig = Figure(size = (700, 900), fontsize = 13)

    # ── Pohled z vrchu (xy) ───────────────────────────────────────────
    ax1 = Axis(fig[1, 1],
        xlabel = "x [m]", ylabel = "y [m]",
        title  = "Pohled z vrchu",
        aspect = DataAspect())

    shift_lana = 0.03
    lines!(ax1, [A[1], B[1], C1[1]], [A[2]-shift_lana, B[2]-shift_lana, C1[2]],
           color=:royalblue, linewidth=2, label="lano 1")
    lines!(ax1, [A[1], B[1], C2[1]], [A[2]+shift_lana, B[2]+shift_lana, C2[2]],
           color=:tomato, linewidth=2, label="lano 2")

    scatter!(ax1, [A[1]], [A[2]], markersize=25, color=:black,  marker=:circle)
    scatter!(ax1, [B[1]], [B[2]], markersize=14, color=:orange, marker=:diamond)
    scatter!(ax1, [C1[1], C2[1]], [C1[2], C2[2]], markersize=14, color=:green, marker=:rect)

    text!(ax1, A[1]+0.15,  A[2]+0.15; text="A (strom)",    fontsize=11)
    text!(ax1, B[1]+0.2,  B[2]; text="B (karabina)", fontsize=11, align=(:left, :center))
    text!(ax1, C1[1]+0.15, C1[2]-0.3; text="C₁",           fontsize=11)
    text!(ax1, C2[1]+0.15, C2[2]+0.1; text="C₂",           fontsize=11)

    # popisky délek úseků
    m_AB  = (A[1:2]  + B[1:2])  / 2
    m_BC1 = (B[1:2]  + C1[1:2]) / 2
    m_BC2 = (B[1:2]  + C2[1:2]) / 2
    text!(ax1, m_AB[1]-0.5,  m_AB[2]+0.1;  text="|AB|=$(round(norm(A-B),  digits=2)) m", fontsize=10, color=:royalblue)
    text!(ax1, m_BC1[1]+0.1, m_BC1[2]+0.1; text="|BC₁|=$(round(norm(B-C1),digits=2)) m", fontsize=10, color=:royalblue, align=(:left, :center))
    text!(ax1, m_BC2[1]+0.1, m_BC2[2]-0.1; text="|BC₂|=$(round(norm(B-C2),digits=2)) m", fontsize=10, color=:tomato, align=(:left, :center))

    # šipky tahů v xy rovině — délka ∝ síla
    tip_A  = [B[1] + al_2T*uBA_v[1],  B[2] + al_2T*uBA_v[2]]
    tip_C1 = [B[1] + al_T *uBC1_v[1], B[2] + al_T *uBC1_v[2]]
    tip_C2 = [B[1] + al_T *uBC2_v[1], B[2] + al_T *uBC2_v[2]]
    p_A    = perp(uBA_v[1:2])
    p_C1   = perp(uBC1_v[1:2])
    p_C2   = perp(uBC2_v[1:2])

    arrows2d!(ax1, [B[1]], [B[2]], [al_2T*uBA_v[1]],  [al_2T*uBA_v[2]],  color=:darkorange, shaftwidth=3, tiplength=16, tipwidth=11)
    arrows2d!(ax1, [B[1]], [B[2]], [al_T *uBC1_v[1]], [al_T *uBC1_v[2]], color=:royalblue,  shaftwidth=3, tiplength=16, tipwidth=11)
    arrows2d!(ax1, [B[1]], [B[2]], [al_T *uBC2_v[1]], [al_T *uBC2_v[2]], color=:tomato,     shaftwidth=3, tiplength=16, tipwidth=11)

    text!(ax1, tip_A[1]  + lo*p_A[1],  tip_A[2]  + lo*p_A[2];  text="2T = $(flabel(2T))", fontsize=10, color=:darkorange, align=(:center, :center))
    text!(ax1, tip_C1[1] + lo*p_C1[1], tip_C1[2] + lo*p_C1[2]; text="T = $(flabel(T))",  fontsize=10, color=:royalblue,  align=(:left, :center))
    text!(ax1, tip_C2[1] - lo*p_C2[1], tip_C2[2] - lo*p_C2[2]; text="T = $(flabel(T))",  fontsize=10, color=:tomato,     align=(:left, :center))

    # více místa v x pro popisky vpravo
    xmin1, xmax1 = minimum([A[1],B[1],C1[1],C2[1]]), maximum([A[1],B[1],C1[1],C2[1]])
    xlims!(ax1, xmin1 - 1.5, xmax1 + 2.5)

    axislegend(ax1, position=:lt)

    # ── Pohled z boku (xz) ────────────────────────────────────────────
    ax2 = Axis(fig[2, 1],
        xlabel = "x [m]", ylabel = "z [m]",
        title  = "Pohled z boku",
        aspect = DataAspect())

    lines!(ax2, [A[1], Cmid[1]], [A[3], Cmid[3]],
           color=:gray, linewidth=1, linestyle=:dash, label="přímá spojnice A→C")
    lines!(ax2, [A[1], B[1], C1[1]], [A[3], B[3], C1[3]],
           color=:royalblue, linewidth=2, label="lana")

    # průvěs
    z_B_spojnice = A[3] + (Cmid[3]-A[3]) * (B[1]-A[1]) / (Cmid[1]-A[1])
    lines!(ax2, [B[1], B[1]], [z_B_spojnice, B[3]],
           color=:purple, linewidth=2, linestyle=:dot,
           label="průvěs = $(round(provis, digits=2)) m")
    text!(ax2, B[1]+0.1, (z_B_spojnice + B[3])/2; text="$(round(provis,digits=2)) m", fontsize=10, color=:purple)

    #scatter!(ax2, [A[1]], [A[3]], markersize=25, color=:black,  marker=:circle)
    scatter!(ax2, [B[1]], [B[3]], markersize=14, color=:orange, marker=:diamond)
    scatter!(ax2, [C1[1]], [C1[3]], markersize=14, color=:green, marker=:rect)

    vlines!(ax2, 0, linewidth=17, color=:black)

    text!(ax2, A[1]+0.2,  A[3];  text="A",      fontsize=11)
    text!(ax2, B[1]+0.1,  B[3]-0.35; text="B",      fontsize=11)
    text!(ax2, C1[1]+0.1, C1[3]+0.1; text="C₁/C₂", fontsize=11)

    # popisky délek úseků
    m_AB_xz = ([A[1], A[3]] + [B[1], B[3]]) / 2
    m_BC_xz = ([B[1], B[3]] + [C1[1], C1[3]]) / 2
    text!(ax2, m_AB_xz[1]-0.3, m_AB_xz[2];
          text="|AB|=$(round(norm(A-B),  digits=2)) m", fontsize=10, color=:royalblue, align=(:right, :center))
    text!(ax2, m_BC_xz[1]+0.1, m_BC_xz[2]+0.15;
          text="|BC|=$(round(norm(B-C1), digits=2)) m", fontsize=10, color=:royalblue, align=(:left, :center))

    # šipky sil v B (v bočním pohledu) — délka ∝ síla
    tip_A_xz  = [B[1] + al_2T*uBA_v[1],  B[3] + al_2T*uBA_v[3]]
    tip_C_xz  = [B[1] + al_2T*uBC1_v[1], B[3] + al_2T*uBC1_v[3]]
    tip_mg_xz = [B[1],                    B[3] - al_mg]
    p_A_xz    = perp([uBA_v[1],  uBA_v[3]])
    p_C_xz    = perp([uBC1_v[1], uBC1_v[3]])

    arrows2d!(ax2, [B[1]], [B[3]], [al_2T*uBA_v[1]],  [al_2T*uBA_v[3]],
              color=:darkorange, shaftwidth=3, tiplength=16, tipwidth=11)
    arrows2d!(ax2, [B[1]], [B[3]], [al_2T*uBC1_v[1]], [al_2T*uBC1_v[3]],
              color=:steelblue, shaftwidth=3, tiplength=16, tipwidth=11)
    arrows2d!(ax2, [B[1]], [B[3]], [0.0], [-al_mg],
              color=:red, shaftwidth=3, tiplength=16, tipwidth=11)

    text!(ax2, tip_A_xz[1]  + lo*p_A_xz[1],  tip_A_xz[2]  + lo*p_A_xz[2];
          text="2T = $(flabel(2T))", fontsize=10, color=:darkorange, align=(:right, :center))
    text!(ax2, tip_C_xz[1]  + lo*p_C_xz[1],  tip_C_xz[2]  - lo*p_C_xz[2];
          text="2T = $(flabel(2T))", fontsize=10, color=:steelblue,  align=(:center, :top))
    text!(ax2, tip_mg_xz[1] - lo, tip_mg_xz[2];
          text="mg = $(flabel(m*g))", fontsize=10, color=:red,        align=(:right,   :center))

    xmin2, xmax2 = minimum([A[1],B[1],C1[1]]), maximum([A[1],B[1],C1[1]])
    xlims!(ax2, xmin2 - 1.5, xmax2 + 2.5)

    axislegend(ax2, position=:rt)

    return fig
end

fig = plot_geometry()



# ── Vstupní parametry ────────────────────────────────────────────
h_kotva = 5.0    # výška kotvení na stromě [m]
d_strom = 8.0    # vodorovná vzdálenost lidí od stromu [m]
d_lide  = 4.0    # vzdálenost mezi lidmi [m]
L       = 10.3   # délka každého lana [m]  ← hlavní vstup; závaží najde rovnováhu
m       = 50.0   # hmotnost závaží [kg]
g       = 9.81   # tíhové zrychlení [m/s²]

# ── Odvozená geometrie ───────────────────────────────────────────
A    = [0.0,         0.0,        h_kotva]
C1   = [d_strom, -d_lide/2,  0.0]
C2   = [d_strom, +d_lide/2,  0.0]
Cmid = (C1 + C2) / 2

L_min = norm(A - C1)   # délka napnutého (přímého) lana – spodní mez
println("L_min (přímé lano A→C) = $(round(L_min, digits=2)) m,  L = $L m,  přebytek = $(round(L - L_min, digits=2)) m")
L < L_min && error("Lano je kratší než přímá vzdálenost A→C ($(round(L_min,digits=2)) m) – rovnováha neexistuje.")

# ── Soustava rovnic (symetrie: T1=T2=T, By=0) ───────────────────
#
# 2 neznámé: Bx, Bz
# Rovnice 1: ê_BA[x] + ê_BC₁[x] = 0   (x-složka síly, nezávisí na T)
# Rovnice 2: |A−B| + |B−C₁| = L        (délková podmínka)
#
# T potom analyticky z z-složky: T = mg / (2·ê_BA_z + 2·ê_BC₁_z)

function equations!(F, u)
    Bx, Bz = u
    B_loc  = [Bx, 0.0, Bz]
    uBA_l  = (A  - B_loc) / norm(A  - B_loc)
    uBC1_l = (C1 - B_loc) / norm(C1 - B_loc)
    F[1] = uBA_l[1] + uBC1_l[1]              # silová podmínka (x)
    F[2] = norm(A - B_loc) + norm(B_loc - C1) - L   # délková podmínka
end

# počáteční odhad: B někde uprostřed, níž než přímá spojnice
B0 = [(A[1] + Cmid[1]) / 2,  (A[3] + Cmid[3]) / 2 - 0.5]
sol = nlsolve(equations!, B0, autodiff = :forward)
sol.f_converged || @warn "NLsolve nekonvergoval – zkontroluj počáteční odhad nebo parametry."

Bx, Bz = sol.zero
B  = [Bx, 0.0, Bz]

uBA  = (A  - B) / norm(A  - B)
uBC1 = (C1 - B) / norm(C1 - B)
uBC2 = (C2 - B) / norm(C2 - B)

T = (m * g) / (2*uBA[3] + uBC1[3] + uBC2[3])

# průvěs: pokles B pod přímou spojnicí A→střed (výsledek, ne vstup)
z_spojnice = A[3] + (Cmid[3]-A[3]) * (Bx - A[1]) / (Cmid[1] - A[1])
provis = z_spojnice - Bz

# ── Hmotnost osoby na C₁, C₂ ────────────────────────────────────
# Lano u C₁ táhne osobu silou T ve směru (B - C₁): šikmo nahoru a dovnitř.
# Rozklad na svislou (zvedání) a vodorovnou (tažení) složku:
uC1B   = (B - C1) / norm(B - C1)          # jednotkový vektor od C₁ k B
T_z_C  = T * uC1B[3]                       # svislá složka tahu (zvedá osobu)
T_xy_C = T * norm(uC1B[1:2])               # vodorovná složka (táhne osobu k B)
β_C    = rad2deg(atan(T_z_C, T_xy_C))      # úhel lana nad horizontálou u C [°]

# Osoba stojí na zemi a drží lano — dvě podmínky rovnováhy:
#   1) nezvednutí:   m·g ≥ T_z          →  m ≥ T_z / g
#   2) neuklouznutí: μ·(m·g − T_z) ≥ T_xy  →  m ≥ T_xy/(μ·g) + T_z/g
μ = 0.6   # koeficient tření bot na zemi (tráva/hlína ≈ 0.5–0.7)
m_nezvednutí  = T_z_C / g
m_neuklouznutí = T_xy_C / (μ * g) + T_z_C / g
m_osoba = max(m_nezvednutí, m_neuklouznutí)

# ── Výsledky ─────────────────────────────────────────────────────
#println("=== VÝSLEDKY ===")
#println("Poloha karabiny B     = ", round.(B, digits=3), " m")
#println("Tah v každém laně: T  = ", round(T, digits=1), " N  (≈ ", round(T/g, digits=1), " kg)")
#println("Průvěs (pokles B):    = ", round(provis, digits=3), " m")
#println("Úhel A→B od horizontály:   ", round(rad2deg(asin(abs(uBA[3]))),  digits=1), "°")
#println("Úhel B→C od horizontály:   ", round(rad2deg(asin(abs(uBC1[3]))), digits=1), "°")
#println()
#println("=== OSOBY NA C₁, C₂ (každý konec zvlášť) ===")
#println("Síla lana na osobu:      T  = ", round(T,      digits=1), " N,  směr: ", round(β_C, digits=1), "° nad horizontálou")
#println("  svislá složka (zvedá): T_z  = ", round(T_z_C,  digits=1), " N")
#println("  vodorovná složka:      T_xy = ", round(T_xy_C, digits=1), " N")
#println()
#println("  Podmínka nezvednutí:   m ≥ ", round(m_nezvednutí,   digits=1), " kg")
#println("  Podmínka neuklouznutí: m ≥ ", round(m_neuklouznutí, digits=1), " kg  (μ = $μ)")
#println("  ─────────────────────────────────────────")
#println("  → minimální hmotnost osoby: m ≥ ", round(m_osoba, digits=1), " kg")

# ── Vizualizace ───────────────────────────────────────────────────
fig = plot_geometry()
