include("parseStPP.jl")
include("heuristique/construction.jl")
include("heuristique/graspStPP.jl")

"""
Tentative Bandit-Manchot (epsilon greedy) sur SPP.
@param epsilon parametre epsilon.
@param n nombre de rectangle.
@param W largeur de la bande.
@param P liste des dimentions des rectangles.
@param Q liste du nombre de chaque rectangles.
@param itt budget de calcule.
@param Lalpha liste de parametres alphas.
@return (alpha associé à la meilleur solution trouvé, tableau boolean pour chaque itérations meilleur action choisit? , meilleur solution trouvé, nombre de fois qu'une classe alpha a été choisit)
"""
# Dans le cadre du StripPacking on est sur un probleme de minimisation, on cherche donc la plus petite valeur ce qui inverse le BanditM_GRASP
function BanditM_GRASP(epsilon, n, W, P, Q,  itt, Lalpha)
    rewards::Vector{Int64} = ones(itt)
    # Tableau pour enregistrer les étapes où la meilleure performance est atteinte
    optimal_actions::Vector{Bool} = zeros(Bool, itt)

    # Initialisation avec la première valeur d'alpha
    best_alpha::Float64 = Lalpha[1]
    # Initialisation de la meilleure performance observée jusqu'à présent
    best_reward = 99999999

    solution = Vector{Int64}(undef,itt)

    # Initialisation du nombre de sélections
    counts::Vector{Int64} = zeros(Int, length(Lalpha))
     # Initialisation des valeurs estimées
    values::Vector{Float64} = zeros(Float64, length(Lalpha))

        for i in 1:itt
            
            # Sélection de l'alpha selon la politique Epsilon-Greedy
            if rand() < epsilon
                # Exploration
                action = rand(1:length(Lalpha))
            else
                # Exploitation
                action = argmin(values)
            end
            # Exécuter GRASP avec l'alpha sélectionné
            (solution, current_reward) = grasp(n, W, P, Q, Lalpha[action])

            # Mettre à jour les récompenses en fonction de la performance de GRASP
            # On inverse le sens en < car on est en min
            if current_reward < rewards[i]
                rewards[i] = current_reward
            end

            #Mise a jour de l'estimation de la valeur de l'action, ajout de la recompense obtenu - la somme cumulée des recompenses de l'action
            #Tout cela divisé par le nombre de fois que l'action a été choisie
            #Variante de l'estimation Action-Valeur car on doit utiliser les solutions de GRASP dans la recompense.
            counts[action] += 1
            values[action] += (current_reward - values[action]) / counts[action]                

            # Enregistrer l'étape où la meilleure performance est atteinte afin de voir le pourcentage de fois que l'on a choisi l'action estimée optimale
            if action == argmin(values)
                optimal_actions[i] = true
            end

            # Mise à jour de la meilleure performance si la performance actuelle
            # On inverse et on met < car on est sur un pb de minimisation
            if current_reward < best_reward
                best_reward = current_reward
                best_alpha = Lalpha[action]
            end
        end

        

    return best_alpha, optimal_actions, best_reward, counts
end