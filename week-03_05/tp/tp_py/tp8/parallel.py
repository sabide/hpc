from mpi4py import MPI
import domain
import numpy as np

N = 0
E = 1
S = 2
W = 3


class Parallel:
    # Rank of process
    rank = 0
    # Number of process
    size = 1
    # Cartesian communicator
    comm2d = MPI.COMM_WORLD
    # Number of process in each dimension
    dims = [0,0]
    # Rank of the 4 neighbours 
    neighbour = [0]*4
    # Type for a line
    type_line = MPI.DOUBLE
    # Type for a column
    type_column = MPI.DOUBLE

    def env_init(self):
        # TODO: Get the rank and size -> rank, size


    def topology_init(self,d):
        # Copy d in class
        self.d = d
        # Read ntx and nty from the file poisson.data
        with open("poisson.data", "r") as file:
            d.ntx = int(file.readline())
            d.nty = int(file.readline())
        # print(f"Rank {rank}: ntx={ntx}, nty={nty}")
        # TODO: Number of processes on each dimension
    
        # TODO: Creation of the 2D cartesian topology
    
        if self.rank == 0:
            print("Execution poisson with", self.size, "MPI processes")
            print("Size of the domain: ntx="+str(d.ntx)+" nty="+str(d.nty))
            print("Dimension for the topology:", self.dims[0],
                  "along x,", self.dims[1], "along y")
            print("-----------------------------------------")

    def domain_boundaries(self):
        # TODO: What is my coordinates in the topology
    
        # Compute local X limits
        self.d.sx = (coords[0]*self.d.ntx)//self.dims[0]+1
        self.d.ex = ((coords[0]+1)*self.d.ntx)//self.dims[0]
        # Compute local Y limits
        self.d.sy = (coords[1]*self.d.nty)//self.dims[1]+1
        self.d.ey = ((coords[1]+1)*self.d.nty)//self.dims[1]
        print(f"Rank in the topology: {self.rank} Local Grid Index: "
              f"{self.d.sx} to {self.d.ex} along x, "
              f"{self.d.sy} to {self.d.ey} along y")

    def domain_neighbours(self):
        # TODO: Get the neighbours in the topology (i.e neighbour[N] neighbour[S])
    
    
        print(f"Process {self.rank} neighbour: "
              f"N {self.neighbour[N]} E {self.neighbour[E]} "
              f"S {self.neighbour[S]} W {self.neighbour[W]}")

    def derived_datatypes(self):
        # TODO: Create derived datatypes for lines and columns


    def communication(self):
        # sx, sy, ex, ey = local index in self.d.u
        sx = 1
        sy = 1
        ex = self.d.ex - self.d.sx + 1
        ey = self.d.ey - self.d.sy + 1
        # Send and receive the boundaries
        # TODO: Send to North and receive to South

        # TODO: Send to South and receive to North

        # TODO: Send to West and receive to east

        # TODO: Send to East and receive to west


    def global_error(self):
        # Compute the global error
        local_error = 0.
        for iterx in range(self.d.sx, self.d.ex + 1):
            for itery in range(self.d.sy, self.d.ey + 1):
                dx = iterx - self.d.sx + 1
                dy = itery - self.d.sy + 1
                delta = np.abs(self.d.u[dx, dy] - self.d.u_new[dx, dy])
                local_error = max(local_error, delta)
        # TODO: Assemble all the local error -> error

        return error

    def write_data(self):
        # TODO: Open the file data.dat for writing
    
        # TODO: Define the subarray type for the view
    
    
    
    
    
    
        # TODO: Set the view
    
        # TODO: Define the shape of the array to write
    
    
    
    
    
    
        # TODO: Write the array to the file
    
        # TODO: Close the file
    
