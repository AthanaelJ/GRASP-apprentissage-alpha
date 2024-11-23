include("heuristique/nearestNeighbors.jl")
include("heuristique/graspTSP.jl")
include("heuristique/2opt.jl")

"""
Tentative roulette sur TSP.
@param C matrice de coût.
@param Lalpha liste de parametres alphas.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function roulette(C, Lalpha, itt)
    (Sbest, zbest)=nearestNeighbors(C)
    nbAlpha=length(Lalpha)
    for i in 1:div(itt, nbAlpha)
        for alpha in 1:nbAlpha
            (S, z)=grasp(C, Lalpha[alpha])
            (S, z)=opt(C, S)
            if z<zbest
                zbest=z
                Sbest=S
            end
        end
    end
    return (Sbest, zbest)
end