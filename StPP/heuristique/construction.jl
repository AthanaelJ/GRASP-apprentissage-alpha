"""
Heuristique de construction gloutonne sur StPP.
@param n nombre de rectangle.
@param W largeur de la bande.
@param P liste des dimentions des rectangles.
@param Q liste du nombre de chaque rectangles.
@return (solution construit, valeur de la solution construit)
"""
function construction(n, W, P, Q)
    #TODO typage 
    listPlot=[]
    L=[[W, 0, 0]]#w, l, x pour le plot
    (P,Q)=sortingPQ(P, Q)
    C=[]
    R=L[1]
    indice=0
    while P!=[]
        #STEP 1
        boolStock=true
        while boolStock
            (R, indice)=minLevel(L)
            if(R[1]<P[length(P)][1])#à voir la suite de l'implémentation mais là ça veut dire que y'a rien qui rentre
                rlevel=typemax(Int64)
                llevel=typemax(Int64)
                level=0
                lOUr=false#false si rectangle de gauche true sinon
                if (indice != 1)
                    llevel=L[indice-1][2]
                end
                if (indice != length(L))
                    rlevel=L[indice+1][2]
                end
                Lx=L[indice][3]
                if rlevel<llevel
                    lOUr=true
                    level=rlevel
                else
                    level=llevel
                    Lx=L[indice-1][3]
                end
                L[indice][2]=level
                L[indice][3]=Lx
                if lOUr
                    L[indice][1]+=L[indice+1][1]
                    supp!(L, L[indice+1])
                else
                    L[indice][1]+=L[indice-1][1]
                    supp!(L, L[indice-1])
                end
            else
                boolStock=false
            end
        end
        #STEP 2
        mStock=0
        mMax=0
        Pindice=findfirst(x->x[1]<=R[1], P)
        mStock=floor(R[1]/P[Pindice][1])
        if mStock<Q[Pindice]
            mMax=mStock
        elseif Q[Pindice]>mMax
            mMax=Q[Pindice]
        end     
        Pprime=P[Pindice]
        #STEP 3
        lOUr=false#false si on place à gauche true sinon
        if(indice == 1)
            lOUr=false
        elseif(indice == length(L))
            lOUr=true
        elseif(R[1]+Pprime[2]==L[indice-1][2])
            lOUr=false
        elseif(R[1]+Pprime[2]==L[indice+1][2])
            lOUr=true
        else
            if L[indice-1][2]>L[indice+1][2]
                lOUr=false
            else
                lOUr=true
            end
        end
        #STEP 4
        w=P[Pindice][1]*mMax
        w2=P[Pindice][1]
        h=P[Pindice][2]
        prevW=L[indice][1]
        prevL=L[indice][2] 
        x=L[indice][3]
        xStock=x
        y=prevL
        if (lOUr)
            x=x+prevW-w
        end
        for i in 1:mMax
            if lOUr
                push!(listPlot, (x, y, w2, h))
            else
                push!(listPlot, (x, y, w2, h))
            end
            x=x+w2
        end
        Q[Pindice]-=mMax
        if Q[Pindice]<=0
            push!(C, P[Pindice])
            deleteat!(Q, Pindice)
            deleteat!(P, Pindice)
        end
        if lOUr
            L[indice]=[w, L[indice][2]+h, xStock+prevW-w]
        else
            L[indice]=[w, L[indice][2]+h, xStock]
        end
        if prevW>w
            if lOUr
                #on a placé les objets à la droite donc nouveau rectangle à gauche
                insert!(L, indice, [prevW-w, prevL, xStock])
            else
                #inversement
                insert!(L, indice+1, [prevW-w, prevL, xStock+w])
            end
        end
    end
    z = 0
    for i in L
        if i[2]>z
            z=i[2]
        end
    end
    return (listPlot, z)
end

function supp!(list, elt)
    deleteat!(list, findfirst(x->x==elt, list))
end

function sortingPQ(P, Q)#règle de brisage d'égalités pas implémenté, flemme mais en gros quand égalité de largeur on ordone par hauteur décroissnte 
    #TODO typage
    sortList=[]
    newP=[]
    newQ=[]
    j=1
    for i in P
        push!(sortList, [i[1], j])
        j+=1
    end
    sort!(sortList, rev=true)
    for i in sortList
        push!(newP, P[i[2]])
        push!(newQ, Q[i[2]])
    end
    return (newP, newQ)
end

function minLevel(L)
    #TODO typage
    min=L[1][2]
    minElt=L[1]
    minIndice=1
    cpt=1
    for i in L
        if i[2]<min 
            min=i[2]
            minElt=i
            minIndice=cpt
        # pour briser les égalités on choisit le w minimum
        elseif  i[2]==min && i!=minElt && i[1]<minElt[1] 
            min=i[2]
            minElt=i
            minIndice=cpt
        end
        cpt+=1
    end
    return (minElt, minIndice)
end