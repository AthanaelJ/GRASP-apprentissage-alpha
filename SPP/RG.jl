include("heuristique/gloutonSPP.jl")
include("heuristique/graspSPP.jl")
include("heuristique/destroyAndRepair.jl")

"""
Reactive-GRASP sur SPP.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param Lalpha liste de parametres alphas.
@param Nalpha nombre d'itérations avant le rafrechissement des probabilités.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function reactiveGRASP(C, A, Lalpha, Nalpha, itt)
    (Sbest, zbest)=glouton(C, A)
    nbAlpha=length(Lalpha)
    zworst=zbest+1
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
        (S, z)=grasp(C, A, Lalpha[alpha])
        (S, z)=descente(C, A, S, z, 2)
        if z>zbest
            zbest=z
            Sbest=S
        end
        if z<zworst
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
					qAlpha[j]=((sumAlpha[j]/nbIttAlpha[j])-zworst)/(zbest-zworst)
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