include("heuristique/gloutonSPP.jl")
include("heuristique/graspSPP.jl")
include("heuristique/destroyAndRepair.jl")

"""
Tentative roulette sur SPP.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param Lalpha liste de parametres alphas.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function roulette(C, A, Lalpha, itt)
    (Sbest, zbest)=glouton(C, A)
    nbAlpha=length(Lalpha)
    for i in 1:div(itt, nbAlpha)
        for alpha in 1:nbAlpha
            (S, z)=grasp(C, A, Lalpha[alpha])
            (S, z)=descente(C, A, S, z, 2)
            if z>zbest
				zbest=z
				Sbest=S
                #println("============", Lalpha[alpha], "============")
            end
        end
    end
    return (Sbest, zbest)
end