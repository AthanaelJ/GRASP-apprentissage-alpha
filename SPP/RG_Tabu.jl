include("heuristique/gloutonSPP.jl")
include("heuristique/graspSPP.jl")
include("heuristique/destroyAndRepair.jl")

"""
Tentative Tabou sur SPP.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param Lalpha liste de parametres alphas.
@param Nalpha nombre d'itérations avant le rafrechissement des probabilités.
@param itt budget de calcule.
@param yparam nombre de mise à jours sans diminution.
@param zparam pourcentage donné à la classe avec le critère d'aspiration.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function reactiveGRASP_tabu(C, A, Lalpha, Nalpha, itt, yparam, zparam)
    (Sbest, zbest)=glouton(C, A)
    nbAlpha=length(Lalpha)
    zworst=zbest+1
    nbIttAlpha=Vector{Int64}(undef, nbAlpha)
    sumAlpha=Vector{Int64}(undef, nbAlpha)
    pAlpha=Vector{Float64}(undef, nbAlpha)
    qAlpha=Vector{Float64}(undef, nbAlpha)
    pourcent = Vector{Vector{Float64}}(undef, length(Lalpha))#plot des probabilités
    ref::Int64=floor(itt/Nalpha)
	for i in 1:length(Lalpha)
		pourcent[i]=zeros(Float64,ref)
	end
	cptTableauDePlot=0
    for i in 1:nbAlpha
        nbIttAlpha[i]=0
        sumAlpha[i]=0
        pAlpha[i]=1/nbAlpha
    end
    #---------------TABU-----------------
    tabu = zeros(Int64, nbAlpha)
    cptMaj=0
    aspiration=0
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
			aspiration=alpha
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
					stockProba=((sumAlpha[j]/nbIttAlpha[j])-zworst)/(zbest-zworst)
                    if qAlpha[j] > stockProba
                        if cptMaj>tabu[j]
                            stockProba=qAlpha[j]
                        end
                    else
                        tabu[j]=cptMaj+yparam
                    end
                    qAlpha[j]=stockProba
                end
                sumAlpha[j]=0
                nbIttAlpha[j]=0
                sumQk+=qAlpha[j]
            end
            for j in 1:nbAlpha
                pAlpha[j]=qAlpha[j]/sumQk
                pourcent[j][cptTableauDePlot]=pAlpha[j]
            end
            if aspiration!=0
                for j in 1:nbAlpha
                    pAlpha[j]=pAlpha[j]*(1-zparam+pAlpha[aspiration])
                end
                pAlpha[aspiration]=zparam
            end
        end
    end
    return (Sbest, zbest, pourcent)
end