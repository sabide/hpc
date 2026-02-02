from mpi4py import MPI
import numpy as np
import parallel
import domain

if __name__ == "__main__":
    p = parallel.Parallel()
    d = domain.Domain()
    p.env_init()
    p.topology_init(d)
    p.domain_boundaries()
    d.initialization()
    p.domain_neighbours()
    p.derived_datatypes()
    it = 0
    convergence = False
    t1 = MPI.Wtime()
    while not convergence and it < d.it_max:
        it = it+1
        # Swap u and u_new
        d.u, d.u_new = d.u_new, d.u
        p.communication()
        d.computation()
        diffnorm = p.global_error()
        convergence = diffnorm < 2e-16
        if p.rank == 0 and it % 100 == 0:
            print(f"Iteration {it} global_error = {diffnorm}")
    t2 = MPI.Wtime()
    if p.rank == 0:
        print(f"Convergence after {it} iterations in {t2-t1} secs")
        d.output_results()
    p.write_data()
