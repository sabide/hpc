# Finite differences

## Background
This project aims to evaluate the second derivative of the function in one variable using finite differences.
Let's consider a periodic domain $\Omega=[0,1)$ and a partition $\Omega_h=\{x_i=(i-1)/n_{glb} \, |  1 \le i \le n_{glb} \}$
The second derivative is given by :
$$
\delta^2 u_i i = \frac{u_{i-1}-2u_{i}+u_{i+1}}{h^2} 
$$
![alt text](image_url)
Fig. xxx shows the stencil associated to this discrete operator.

In this exercise you will evaluate the second derivative using the $N_p$ ```MPI``` method to speed up the calculation.

## Questions

*The primary enquiry is intended to facilitate the implementation of the second derivative, denoted by δ². It is important to note that the implementation of periodic constraints needs. As a suggestion for potential solution, it is noteworthy that the calculation of the neighbour in a periodic is straightforward: $i+1=mod(i+1, n_{glb})$.*
1. Write the code to calculate the second derivative sequentially.<br>
*The following step-by-step procedure will be followed to assist you. You have to keep in mind that this problem can be undertaken easily if you are thinking on distributed index space. In other words, a ```rank``` has a left and a right neighbord.*
2.
sssss

