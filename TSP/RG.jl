include("heuristique/nearestNeighbors.jl")
include("heuristique/graspTSP.jl")
include("heuristique/2opt.jl")

"""
Reactive-GRASP sur TSP.
@param C matrice de coût.
@param Lalpha liste de parametres alphas.
@param Nalpha nombre d'itérations avant le rafrechissement des probabilités.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function reactiveGRASP(C, Lalpha, Nalpha, itt)
    (Sbest, zbest)=nearestNeighbors(C)
    nbAlpha=length(Lalpha)
    zworst=0
    nbIttAlpha=Vector{Int64}(undef, nbAlpha)
    sumAlpha=Vector{Int64}(undef, nbAlpha)
    pAlpha=Vector{Float64}(undef, nbAlpha)
    qAlpha=Vector{Float64}(undef, nbAlpha)
    pourcent = Vector{Vector{Float64}}(undef, length(Lalpha))#plot des probabilités
    ref::Int64=floor(itt/Nalpha)
	for i in 1:nbAlpha
		pourcent[i]=zeros(Float64,ref)
	end
	cptTableauDePlot=0
    for i in 1:nbAlpha
        nbIttAlpha[i]=0
        sumAlpha[i]=0
        pAlpha[i]=1/nbAlpha
    end
    for i in 1:itt
        #choix du alpha
        alpha=0#indice de l'alpha dans Lalpha
        sommeproba=0
		r=rand(Float64)
		b=true
		while (b)
			alpha+=1
			sommeproba+=pAlpha[alpha]
			if((r<=sommeproba)||(alpha==nbAlpha))
				b=false
			end
		end
        nbIttAlpha[alpha]+=1
        (S, z)=grasp(C, Lalpha[alpha])
        (S, z)=opt(C, S)
        if z<zbest
            zbest=z
            Sbest=S
        end
        if z>zworst
            zworst=z
        end
        sumAlpha[alpha]+=z
        if mod(i, Nalpha)==0
            cptTableauDePlot+=1
            sumQk=0
            for j in 1:nbAlpha
                if(nbIttAlpha[j]==0)
					qAlpha[j]=0
				else
					qAlpha[j]=(zworst-(sumAlpha[j]/nbIttAlpha[j]))/(zworst-zbest)
				end
                sumAlpha[j]=0
                nbIttAlpha[j]=0
                sumQk+=qAlpha[j]
            end
            for j in 1:nbAlpha
                pAlpha[j]=qAlpha[j]/sumQk
                pourcent[j][cptTableauDePlot]=pAlpha[j]
            end
        end
    end
    return (Sbest, zbest, pourcent)
end