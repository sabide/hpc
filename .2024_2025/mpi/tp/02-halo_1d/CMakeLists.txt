cmake_minimum_required(VERSION 3.15)
project(PingPong LANGUAGES Fortran)


# Liste des fichiers sources
set(SOURCES fd_p2p.f90 )

# Générer un exécutable pour chaque fichier source
foreach(SOURCE ${SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE} NAME_WE)
    add_executable(${EXEC_NAME} ${SOURCE})
endforeach()

# Ajouter une cible personnalisée pour soumettre un job SLURM pour ping_pong_2
add_custom_target(run
    COMMAND srun -N 2 -n 24 -A training  hostname ./
    VERBATIM
)

add_custom_target(run-1
    COMMAND srun -N 1 -n 2 -A training ./ping_pong_1
    COMMENT "Exécution avec srun pour ping_pong_2"
    VERBATIM
)

add_custom_target(run-2
    COMMAND srun -N 1 -n 2 -A training ./ping_pong_2
    COMMENT "Exécution avec srun pour ping_pong_2"
    VERBATIM
)

add_custom_target(run-3
    COMMAND srun -N 1 -n 2 -A training ./ping_pong_3
    COMMENT "Exécution avec srun pour ping_pong_2"
    VERBATIM
)

