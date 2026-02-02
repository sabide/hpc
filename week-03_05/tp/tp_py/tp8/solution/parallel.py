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
        # Get the rank and size -> rank, size
        self.rank = self.comm2d.Get_rank()
        self.size = self.comm2d.Get_size()

    def topology_init(self,d):
        # Copy d in class
        self.d = d
        # Read ntx and nty from the file poisson.data
        with open("poisson.data", "r") as file:
            d.ntx = int(file.readline())
            d.nty = int(file.readline())
        # print(f"Rank {rank}: ntx={ntx}, nty={nty}")
        # Number of processes on each dimension
        self.dims = MPI.Compute_dims(self.size, self.dims)
        # Creation of the 2D cartesian topology
        self.comm2d = MPI.COMM_WORLD.Create_cart(self.dims)
        if self.rank == 0:
            print("Execution poisson with", self.size, "MPI processes")
            print("Size of the domain: ntx="+str(d.ntx)+" nty="+str(d.nty))
            print("Dimension for the topology:", self.dims[0],
                  "along x,", self.dims[1], "along y")
            print("-----------------------------------------")

    def domain_boundaries(self):
        # What is my coordinates in the topology
        coords = self.comm2d.Get_coords(self.rank)
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
        # Get the neighbours in the topology (i.e neighbour[N] neighbour[S])
        self.neighbour[N], self.neighbour[S] = self.comm2d.Shift(0, 1)
        self.neighbour[W], self.neighbour[E] = self.comm2d.Shift(1, 1)
        print(f"Process {self.rank} neighbour: "
              f"N {self.neighbour[N]} E {self.neighbour[E]} "
              f"S {self.neighbour[S]} W {self.neighbour[W]}")

    def derived_datatypes(self):
        db = MPI.DOUBLE
        # Create derived datatypes for lines and columns
        self.type_line = db.Create_contiguous(self.d.ey - self.d.sy + 1)
        self.type_line.Commit()
        self.type_column = db.Create_vector(self.d.ex - self.d.sx + 1, 1,
                                            self.d.ey - self.d.sy + 3)
        self.type_column.Commit()

    def communication(self):
        # sx, sy, ex, ey = local index in self.d.u
        sx = 1
        sy = 1
        ex = self.d.ex - self.d.sx + 1
        ey = self.d.ey - self.d.sy + 1
        # Send and receive the boundaries
        # Send to North and receive to South
        self.comm2d.Sendrecv(sendbuf=[self.d.u[sx, sy:], 1, self.type_line],
                             dest=self.neighbour[N],
                             recvbuf=[self.d.u[ex + 1, sy:],
                                      1, self.type_line],
                             source=self.neighbour[S])
        # Send to South and receive to North
        self.comm2d.Sendrecv(sendbuf=[self.d.u[ex, sy:], 1, self.type_line],
                             dest=self.neighbour[S],
                             recvbuf=[self.d.u[sx - 1, sy:],
                                      1, self.type_line],
                             source=self.neighbour[N])
        # Send to West and receive to east
        self.comm2d.Sendrecv(sendbuf=[self.d.u[sx, sy:], 1, self.type_column],
                             dest=self.neighbour[W],
                             recvbuf=[self.d.u[sx, ey + 1:],
                                      1, self.type_column],
                             source=self.neighbour[E])
        # Send to East and receive to west
        self.comm2d.Sendrecv(sendbuf=[self.d.u[sx, ey:], 1, self.type_column],
                             dest=self.neighbour[E],
                             recvbuf=[self.d.u[sx, sy - 1:],
                                      1, self.type_column],
                             source=self.neighbour[W])

    def global_error(self):
        # Compute the global error
        local_error = 0.
        for iterx in range(self.d.sx, self.d.ex + 1):
            for itery in range(self.d.sy, self.d.ey + 1):
                dx = iterx - self.d.sx + 1
                dy = itery - self.d.sy + 1
                delta = np.abs(self.d.u[dx, dy] - self.d.u_new[dx, dy])
                local_error = max(local_error, delta)
        # Assemble all the local error
        error = self.comm2d.allreduce(local_error, op=MPI.MAX)
        return error

    def write_data(self):
        # Open the file data.dat for writing
        fh = MPI.File.Open(self.comm2d, "data.dat",
                           MPI.MODE_WRONLY | MPI.MODE_CREATE)
        # Define the subarray type for the view
        shape_array_view = [self.d.ntx, self.d.nty]
        sizex = self.d.ex - self.d.sx + 1
        sizey = self.d.ey - self.d.sy + 1
        shape_subarray_view = [sizex, sizey]
        start_coord_view = [self.d.sx - 1, self.d.sy - 1]
        db = MPI.DOUBLE
        type_subarray_view = db.Create_subarray(shape_array_view,
                                                shape_subarray_view,
                                                start_coord_view,
                                                MPI.ORDER_C)
        type_subarray_view.Commit()
        # Set the view
        fh.Set_view(0, db, type_subarray_view)
        # Define the shape of the array to write
        shape_array = [sizex + 2, sizey + 2]
        shape_subarray = [sizex, sizey]
        start_coord = [1, 1]
        type_subarray = db.Create_subarray(shape_array, shape_subarray,
                                           start_coord, MPI.ORDER_C)
        type_subarray.Commit()
        # Write the array to the file
        fh.Write_all([self.d.u, 1, type_subarray])
        # Close the file
        fh.Close()
