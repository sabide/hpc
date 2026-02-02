# Configuration

To run the TPs, it is necessary to create a file make_inc in the `arch`
directory.
The simplest way is to create a symbolic link to one of the already defined
`make_xxx` files.

# Light documentation about mpi4py

- Official documentation website https://mpi4py.readthedocs.io/en/stable/

- Import with `from mpi4py import MPI`
- No need to do `MPI_Init()` the import of mpi4py does it by default
- And also the no need to do `MPI_Finalize()` it's done automatically at the end
- A lot of MPI function (all the communications) are member of a communicator  `comm= MPI.COMM_WORLD`
- Rank `rank = comm.Get_rank()`
- Number of MPI process `nbproc = comm.Get_size()`
- 2 type of communication
	- generic python object => use pickle to communicate
	- buffer for contiguous look like C 
- function in lowercase for generic objects for example `send` `recv`
- function with capital first letter for buffers for example `Send` `Recv`

```
comm.send(sendobj,dest=1,tag=0)
recvobj = comm.recv(None,source=0,tag=0)
```

With Numpy must use the buffer interface
```
comm.Send([sendarray,count,datatype],dest=1,tag=0)
comm.Recv([recvarray,count,datatype],source=0,tag=0)
```
We can avoid specifying `count` in this case it's the size of the array

# List of usefull MPI function for hands-on

# Communicators

- `Get_rank()` same as `MPI_Comm_rank`
- `Get_size()` same as `MPI_Comm_size`
- `Send()` same as `MPI_Send`
- `Recv()` same as `MPI_Recv`
- `Sendrecv()` same as `MPI_Sendrecv`
- `Sendrecv_replace()` same as `MPI_Sendrecv_replace`
- `Reduce()` same as `MPI_Reduce`
- `Allreduce()` same as `MPI_Allreduce`
- `Barrier()` same as `MPI_Barrier`
- `Scatter()` same as `MPI_Scatter`
- `Gather()` same as `MPI_Gather`
- `Bcast()` same as `MPI_Bcast`
- `Abort()` same as `MPI_Abort`
- `Split()` same as `MPI_Comm_split`
- `Create_cart()` same as `MPI_Cart_create`
- `Get_coords()` same as `MPI_Cart_coords`
- `Cart_shift()` same as `MPI_Cart_shift`

# Type

- `Create_contiguous()` same as `MPI_Type_contiguous`
- `Create_vector()` same as `MPI_Type_vector`
- `Create_hvector()` same as `MPI_Type_create_hvector`
- `Create_subarray()` same as `MPI_Type_create_subarray`
- `Commit()` same as `MPI_Type_commit`
- `Create_resized()` same as `MPI_Type_create_resized`
- `Get_size()` same as `MPI_Type_size`

# File

- `MPI.File.Open()` same as `MPI_File_open`
- `Read_at()` same as `MPI_File_read_at`
- `Read()` same as `MPI_File_read`
- `Read_shared()` same as `MPI_File_read_shared`
- `Read_ordered()` same as `MPI_File_read_ordered`
- `Seek()` same as `MPI_File_seek`
- `Seek_shared()` same as `MPI_File_seek_shared`
- `Write()` same as `MPI_File_write`
- `Write_all()` same as `MPI_File_write_all`
- `Close()` same as `MPI_File_close`

# Others

- `MPI.COMM_WORLD` same as `MPI_COMM_WORLD`
- `MPI.INT` same as `MPI_INT`
- `MPI.DOUBLE` same as `MPI_DOUBLE`
- `MPI.Wtime()` same as `MPI_Wtime`
- `MPI.Compute_dims()` same as `MPI_Dims_create`
