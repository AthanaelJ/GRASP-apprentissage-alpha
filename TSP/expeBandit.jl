include("Bandit_M.jl")

#Fonction qui sert a calculer les probabilités des alphas par rapport au nb d'ocurence dans un tableau et le nombre de run fait par le Bandit Manchot
function Compute_Proba_alpha(alpha_candidates::Vector{Float64}, vector_Of_Alpha::Vector{Float64}, nb_Run::Int64)
    alpha_counter = Vector{Int64}(undef,length(alpha_candidates))
    for i in 1:length(alpha_candidates)
        alpha_counter[i] = count(j->j==alpha_candidates[i],vector_Of_Alpha)
    end

    alpha_probabilities = alpha_counter ./ nb_Run
    return alpha_probabilities
end

"""
@param nb_Run nombre de run différentes.
@param epsilon parametre epsilon.
@param itt budget de calcule.
"""
#Fonction d'expe pour determiner les alphas choisies sur une plus grande echelle
function experimentation(nb_Run::Int64, epsilon::Float64, n_steps::Int64)

    #--------------------------------Initialisation--------------------------------------------------------------------------
    C = parseTSP("Data/pa561.tsp")
    alpha_candidates = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

    mean_alpha_it = Vector{Tuple{Float64,Vector{Bool},Int64, Float64}}(undef,nb_Run)

    alpha_count::Float64 = 0.0
    #------------------------------------------------------------------------------------------------------------------------


    #On commence par effectuer les runs de l'algo Bandit manchot
    for i in 1:nb_Run
        @time (best_alpha, optimal_actions, best_reward, counts) = BanditM_GRASP(epsilon, C, n_steps, alpha_candidates)

        #On recupere l'alpha qui a ete le + choisi au cours des itérations du Bandit Manchot
        alpha_count = alpha_candidates[argmax(counts)]

        #Création d'un Vector de Tuple qui garde tout les resultats des run 
        #NB: Tres mauvaise idée de faire ca, changer l'imple en mettant des vecteurs
        mean_alpha_it[i] = (best_alpha, optimal_actions, best_reward, alpha_count)
        println(i)
    end

    #On transforme le vecteur de Tuple en plusieurs Vecteur pour pouvoir faire nos moyennes

    mean_optimal_actions = Vector{Float64}(undef,nb_Run)
    vector_Of_bestAlpha =  Vector{Float64}(undef,nb_Run)
    vector_Of_countAlpha = Vector{Float64}(undef,nb_Run)
    vector_Of_bestReward = Vector{Int64}(undef,nb_Run)
    
    for i in 1:nb_Run
        mean_optimal_actions[i] = sum((mean_alpha_it[i])[2])/ n_steps
        vector_Of_bestAlpha[i] = mean_alpha_it[i][1]
        vector_Of_countAlpha[i] = mean_alpha_it[i][4]
        vector_Of_bestReward[i] = mean_alpha_it[i][3]
    end



    println("-------------Mean_Result with ", nb_Run, " run ","-------------")
    
    #On fait la moyenne de l'alpha qui donne la meilleur solution pendant la run du Bandit Manchot
     best_alpha_probabilities = Compute_Proba_alpha(alpha_candidates, vector_Of_bestAlpha, nb_Run)
     println("Alpha qui retourne la meilleur solution en moyenne : ")
     @show best_alpha_probabilities
     println(sum(best_alpha_probabilities))
     println()

    #On fait la moyenne de l'alpha qui a ete le + choisies au cours de l'algo Bandit Manchot
    most_Count_alpha_probabilities = Compute_Proba_alpha(alpha_candidates, vector_Of_countAlpha, nb_Run)
    println("Alpha qui a été choisies le plus par epsilon-greedy en moyenne : ")
    @show most_Count_alpha_probabilities
    println(sum(most_Count_alpha_probabilities))
    println()

    #Moyenne du pourcentage d'actions optimales par run  
    println("Pourcentage d'actions optimales choisies en moyenne : ", sum(mean_optimal_actions)/ nb_Run)

    #Moyenne de la solution optimale retournée par l'algo bandit manchot
    println("solution optimale trouvée en moyenne : ", sum(vector_Of_bestReward)/nb_Run)
    
end

#=
Notes Rapide Apres Test: 

Sur l'instance 10 on observe que c'est 0.1 qui est tout le temps choisi et c'est lui qui donne la meilleur solution souvent.

Pour l'instance 30 celui qui est le plus choisies et 0.9 en moyenne a 90% et celui qui donne la meilleur solution est pas significatif

Pour l'instance 100 Pas de choix significatif

=#