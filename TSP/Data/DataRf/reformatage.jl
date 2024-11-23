function reformatage(nomFichier::String)
    f::IOStream = open(nomFichier,"r")

    s::String = readline(f) 
    tab::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau (qui ne contient ici qu'un entier)
    n::Int64 = tab[1]

    # Allocation mémoire pour le distancier
    C = Matrix{Int64}(undef,n,n)

    # Lecture du distancier
    for i in 1:n
        s = readline(f)
        tab = parse.(Int64,split(s," ",keepempty = false))
        for j in 1:i
            #if length(tab)>j
                C[i,j] = tab[j]
                C[j,i]=C[i,j]
            #end
        end
    end
    close(f)
    s=nomFichier * ".rf"
	touch(s)
    open(s, "w") do file
		println(file, n)
		for i in 1:n
			for j in 1:n
				print(file, C[i,j])
				print(file, " ")
			end
			println(file, "")
		end
	end	
end
reformatage("hk48.tsp")