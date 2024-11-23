"""
Parseur TSP.
@param String nom du fichier à parser.
@return C la matrice de coût.
"""
function parseTSP(nomFichier::String)
    # Ouverture d'un fichier en lecture
    f::IOStream = open(nomFichier,"r")

    # Lecture de la première ligne pour connaître la taille n du problème
    s::String = readline(f) # lecture d'une ligne et stockage dans une chaîne de caractères
    tab::Vector{Int64} = parse.(Int64,split(s," ",keepempty = false)) # Segmentation de la ligne en plusieurs entiers, à stocker dans un tableau (qui ne contient ici qu'un entier)
    n::Int64 = tab[1]

    # Allocation mémoire pour le distancier
    C = Matrix{Int64}(undef,n,n)

    # Lecture du distancier
    for i in 1:n
        s = readline(f)
        tab = parse.(Int64,split(s," ",keepempty = false))
        for j in 1:n
            C[i,j] = tab[j]
        end
    end

    # Fermeture du fichier
    close(f)

    # Retour de la matrice de coûts
    return C
end

"""
Transforme la solution en sa valeur z.
@param S la solution.
@param C la matrice de coût.
@return z.
"""
function toZ(S, C)
    z=0
    for i in 1:length(S)-1
        z+=C[S[i], S[i+1]]
    end
    z+=C[S[length(S)], S[1]]
    return z
end

"""
Verifie si la solution est admissible.
@param S la solution.
@param C la matrice de coût.
"""
function verif(S, C)
    n=size(C, 1)
    stock = Vector{Bool}(undef,n)
    for i in 1:n
        stock[i]=true
    end
    for elt in S
        if stock[elt]
            stock[elt]=false
        else
            print("FF")
        end
    end
    print("OK")
end