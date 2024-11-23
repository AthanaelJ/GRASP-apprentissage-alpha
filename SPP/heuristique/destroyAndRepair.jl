#destroy and repair à une varible
function DestroyAndRepair1(C::Vector{Int64}, Av::Vector{Vector{Int64}}, Ac::Vector{Vector{Int64}}, S::Vector{Int64}, z::Int64, u::Vector{Tuple{Float64, Int64}}, possible::Vector{Bool}, listeInter::Vector{Set{Int64}}, inS::Vector{Bool})
	zOrigine=z
	m=length(Av)
	newPossible=Vector{Bool}(undef, m)
	compteur=0#Sert à S[compteur]=i
	newInS=Vector{Bool}(undef, m)
	for i in S
		z=zOrigine-C[i]
		compteur+=1
		newPossible=copy(possible)
		for j in listeInter[i]
			newPossible[j]=true
			for k in listeInter[j]
				if ((inS[k]==true)&&(k!=i))
					newPossible[j]=false
				end
			end
		end
		stockAdd=[]
		newInS=copy(inS)
		newInS[i]=false
		for (_, e) in u
			if newPossible[e]
				newPossible[e]=false
				z+=C[e]
				newInS[e]=true
				for k in Av[e] #on parcourt les varibles qui apparaisent dans les contraintes 
					for p in Ac[k]
						newPossible[p]=false;
					end
				end
				if z>zOrigine
					S[compteur]=e
					return (false, append!(S, stockAdd), z, newPossible, newInS)
				end
				push!(stockAdd, e)
			end
		end
	end
	return (true, S, zOrigine, possible, inS)#indicateur de fin de recherche par voisinage
end

#destroy and repair à deux varibles
function DestroyAndRepair2(C::Vector{Int64}, Av::Vector{Vector{Int64}}, Ac::Vector{Vector{Int64}}, S::Vector{Int64}, z::Int64, u::Vector{Tuple{Float64, Int64}}, possible::Vector{Bool}, listeInter::Vector{Set{Int64}}, inS::Vector{Bool})
	zSTOCK=0
	zOrigine=z
	zOrigine=z
	m=length(Av)
	newPossible=Vector{Bool}(undef, m)
	compteur=0#Sert à S[compteur]=i
	newInS=Vector{Bool}(undef, m)
	compteur=0#Sert à S[compteur]=i
	for i in S
		compteur2=0
		compteur+=1
		zSTOCK=zOrigine-C[i]
		for h in S
			compteur2+=1
			if (h<i)#Permet d'éviter de faire (1, 2) et (2, 1) par exemple
				z=zSTOCK-C[h]
				newPossible=copy(possible)
				range=copy(listeInter[i])
				for j in listeInter[h]
					push!(range, j)
				end
				for j in range
					newPossible[j]=true
					for k in listeInter[j]
						if ((inS[k]==true)&&(k!=i)&&(k!=h))
							newPossible[j]=false
						end
					end
				end
				stockAdd=[]
				newInS=copy(inS)
				newInS[i]=false
				newInS[h]=false
				for (_, e) in u
					if newPossible[e]
						newPossible[e]=false
						z+=C[e]
						newInS[e]=true
						for k in Av[e] #on parcourt les varibles qui apparaisent dans les contraintes 
							for p in Ac[k]
								newPossible[p]=false;
							end
						end
						if z>zOrigine
							S[compteur]=e
							S[compteur2]=S[1]
							popfirst!(S)
							return (false, append!(S, stockAdd), z, newPossible, newInS)
						end
						push!(stockAdd, e)
					end
				end
			end
		end
	end
	return (true, S, zOrigine, possible, inS)#indicateur de fin de recherche par voisinage
end

#destroy and repair qui utilise celui à une et deux variables
function descente(C::Vector{Int64}, A, S::Vector{Int64}, z::Int64, maxDescente)
	(n, m)=size(A)
    #création matrice creuse
	Av=Vector{Vector{Int64}}(undef, m)#liste Adjacente des variables
	Ac=Vector{Vector{Int64}}(undef, n)#liste Adjacente des contraintes
	for i in 1:m#initialisation
		Av[i]=[]
	end
	for i in 1:n
		Ac[i]=[]
	end
	for i in 1:n
		for j in 1:m
			if A[i, j]==1
				push!(Av[j], i)
				push!(Ac[i], j)
			end
		end
	end
    #création liste qui indique toutes les variables qui seront bloqué si une variable i est passé à 1
	listeInter=Vector{Set{Int64}}(undef, m)
	for i in 1:m
		listeInter[i]=Set([])
		for j in Av[i]
			for k in Ac[j]
				if (k!=i)
					push!(listeInter[i], k)
				end
			end
		end
	end
	possible=Vector{Bool}(undef, m)
	inS=Vector{Bool}(undef, m)
	u=Vector{Tuple{Float64, Int64}}(undef, m) #(cout/occurence element, num element)
	for j in 1:m #pour chaque variables
		possible[j]=true
		u[j]=((C[j]/length(Av[j])),j) #cout divisé par l'occurence 
		if (j in S)
			inS[j]=true
		else
			inS[j]=false
		end
	end
	for j in S
		possible[j]=false
		for k in Av[j]
			for l in Ac[k]
				possible[l]=false
			end
		end
	end
	sort!(u, rev=true)
	fin=false
    cptDescente=0
	while !(fin)&&(cptDescente<maxDescente)
		(fin, S, z, possible, inS)=DestroyAndRepair1(C, Av, Ac, S, z, u, possible, listeInter, inS)
        cptDescente+=1
	end
	fin=false
    cptDescente=0
	while !(fin)&&(cptDescente<maxDescente)
		(fin, S, z, possible, inS)=DestroyAndRepair2(C, Av, Ac, S, z, u, possible, listeInter, inS)
        cptDescente+=1
	end
	return (S, z)
end