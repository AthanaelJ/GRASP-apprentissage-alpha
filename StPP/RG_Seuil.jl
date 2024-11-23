include("heuristique/construction.jl")
include("heuristique/graspStPP.jl")

"""
Tentative Seuil sur StPP.
@param n nombre de rectangle.
@param W largeur de la bande.
@param P liste des dimentions des rectangles.
@param Q liste du nombre de chaque rectangles.
@param Lalpha liste de parametres alphas.
@param Nalpha nombre d'itérations avant le rafrechissement des probabilités.
@param itt budget de calcule.
@return (meilleur solution trouvé, valeur de la meilleur solution trouvé)
"""
function reactiveGRASP_Seuil(n, W, P, Q, Lalpha, Nalpha, itt)
    (Sbest, zbest)=construction(n, W, P, Q)
    nbAlpha=length(Lalpha)
    zworst=0
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
    aspiration2 = fill(false, nbAlpha)
    isBetter::Bool = false
    iAspiration::Int64 = 0
    for i in 1:itt
        #choix du alpha
        alpha=0#indice de l'alpha dans alpha
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
        (S, z)=grasp(n, W, P, Q, Lalpha[alpha])
        #println(Lalpha[alpha], " ", z)
        if z<zbest
            zbest=z
            Sbest=S
            aspiration=alpha
            #println()
            #println("===========", Lalpha[alpha], "===========")
            #println()
        end
        if z>zworst
            zworst=z
        end
        sumAlpha[alpha]+=z
        if mod(i, Nalpha)==0
            cptMaj+=1
            sumQk=0
            for j in 1:nbAlpha
                if(nbIttAlpha[j]==0)
					qAlpha[j]=0
				else
					stockProba=(zworst-(sumAlpha[j]/nbIttAlpha[j]))/(zworst-zbest)
                    #print(sumAlpha[j]/nbIttAlpha[j], "   ")
                    if qAlpha[j] > stockProba
                        if cptMaj>tabu[j]
                            stockProba=qAlpha[j]
                        end
                        if aspiration2[j]
                            stockProba = qAlpha[j]
                        end
                        if j == iAspiration
                            stockProba = qAlpha[j]
                        end
                    else
                        stockProba= stockProba*4
                        tabu[j]=cptMaj+3
                    end
                    qAlpha[j]=stockProba
				end
                sumQk+=qAlpha[j]
            end

            if aspiration!=0
                sumQk -= qAlpha[aspiration]
                qAlpha[aspiration]=sumQk/2
                sumQk+=qAlpha[aspiration]
            end

            if isBetter
                sumQk = sumQk - qAlpha[iAspiration]
                stock::Float64 = sumQk/2

                if stock < qAlpha[iAspiration]
                    sumQk += qAlpha[iAspiration]
                else
                    qAlpha[iAspiration] = stock
                    sumQk += qAlpha[iAspiration]
                end 
            end
            
            acc::Float64 = 0
            #println()
            for j in 1:nbAlpha
                pAlpha[j]=qAlpha[j]/sumQk
                acc += pAlpha[j]
                #println(pAlpha[j])
            end
            #println()
            #println("-------------------------------")
            #println()
            for j=1:nbAlpha
                #Creation d'un parameteres pour le premier seuil.
                if pAlpha[j] > 0.15 && isBetter == false

                    aspiration2[j]=true
                end
                
                if pAlpha[j] > 0.40 && isBetter == false
                    isBetter = true

                    aspiration2 = fill(false, nbAlpha)
                    aspiration2[j]=true
                    i::Int64 = j
                    iAspiration = i
                    #println("la classe à min 0.40: ", i)

                    sumQk = 0.0
                    acc2::Float64 = 0
                    for k=1:nbAlpha
                        if(nbIttAlpha[k]==0)
                            qAlpha[k]=0
                        else
                            if k != i
                                qAlpha[j] =  (zworst-(sumAlpha[j]/nbIttAlpha[j]))/(zworst-zbest)#(zAvgClasseAlpha[j]-zWorst)/(zbetter-zWorst)
                                #println("av maj, ", qAlpha[k])
                                sumQk += qAlpha[k]
                            else
                                qAlpha[k] = qAlpha[k]
                                #println("av maj, ", qAlpha[k])
                                sumQk += qAlpha[k]
                            end
                        end

                    end
                    for k=1:nbAlpha
                        pAlpha[k] =  qAlpha[k]/sumQk
                        #println("maj , ", pAlpha[k])
                        acc2 += pAlpha[k]
                    end
                    #println("La somme des probas est bien de: ", acc2)
                    break
                end
            end
            cptTableauDePlot+=1
            for j=1:nbAlpha
                sumAlpha[j]=0
                nbIttAlpha[j]=0
                pourcent[j][cptTableauDePlot]=pAlpha[j]
            end
        end
    end
    return (Sbest, zbest, pourcent)
end