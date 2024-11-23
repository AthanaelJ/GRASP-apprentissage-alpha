include("heuristique/construction.jl")
include("heuristique/graspStPP.jl")

"""
Tentative roulette sur StPP.
@param n nombre de rectangle.
@param W largeur de la bande.
@param P liste des dimentions des rectangles.
@param Q liste du nombre de chaque rectangles.
@param Lalpha liste de parametres alphas.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function roulette(n, W, P, Q, Lalpha, itt)
    (Sbest, zbest)=construction(n, W, P, Q)
    nbAlpha=length(Lalpha)
    for i in 1:div(itt, nbAlpha)
        for alpha in 1:nbAlpha
            (S, z)=grasp(n, W, P, Q, Lalpha[alpha])
            if z<zbest
                zbest=z
                Sbest=S
            end
        end
    end
    return (Sbest, zbest)
end