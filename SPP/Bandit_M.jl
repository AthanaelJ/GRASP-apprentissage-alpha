using Random

include("parseSPP.jl")
include("heuristique/gloutonSPP.jl")
include("heuristique/graspSPP.jl")
include("heuristique/DestroyAndRepair.jl")
"""
Tentative Bandit-Manchot (epsilon greedy) sur SPP.
@param epsilon parametre epsilon.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param itt budget de calcule.
@param Lalpha liste de parametres alphas.
@return (alpha associé à la meilleur solution trouvé, tableau boolean pour chaque itérations meilleur action choisit? , meilleur solution trouvé, nombre de fois qu'une classe alpha a été choisit)
"""
# Dans le cadre du TSP on est sur un probleme de minimisation, on cherche donc la plus petite valeur ce qui inverse le BanditM_GRASP
function BanditM_GRASP(epsilon, C, A, itt, Lalpha)
    rewards::Vector{Int64} = ones(itt)
    # Tableau pour enregistrer les étapes où la meilleure performance est atteinte
    optimal_actions::Vector{Bool} = zeros(Bool, itt)

    # Initialisation avec la première valeur d'alpha
    best_alpha::Float64 = Lalpha[1]
    # Initialisation de la meilleure performance observée jusqu'à présent
    best_reward = -1

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
            action = argmax(values)
        end
        # Exécuter GRASP avec l'alpha sélectionné
        (solution, current_reward) = grasp(C, A, Lalpha[action])
        (solution, current_reward) = descente(C, A,  solution, current_reward, 2) 

        # Mettre à jour les récompenses en fonction de la performance de GRASP
        if current_reward > rewards[i]
            rewards[i] = current_reward
        end

        counts[action] += 1
        values[action] += (current_reward - values[action]) / counts[action]

        # Enregistrer l'étape où la meilleure performance est atteinte
        if action == argmax(values)
            optimal_actions[i] = true
        end

        # Mise à jour de la meilleure performance si la performance actuelle
        if current_reward > best_reward
            best_reward = current_reward
            best_alpha = Lalpha[action]
        end
    end

    return best_alpha, optimal_actions, best_reward, counts
end