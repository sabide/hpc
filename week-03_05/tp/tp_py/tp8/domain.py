import numpy as np


class Domain:
    ntx = 4
    nty = 4
    sx = 0
    ex = 0
    sy = 0
    ey = 0
    u = np.empty((0, 0), dtype=np.float64)
    u_new = np.empty((0, 0), dtype=np.float64)
    u_exact = np.empty((0, 0), dtype=np.float64)
    f = np.empty((0, 0), dtype=np.float64)
    coef = []
    it_max = 1000

    def initialization(self):
        sizex = self.ex-self.sx+3
        sizey = self.ey-self.sy+3
        self.u = np.zeros((sizex, sizey), dtype=np.float64)
        self.u_new = np.zeros((sizex, sizey), dtype=np.float64)
        self.u_exact = np.zeros((sizex, sizey), dtype=np.float64)
        self.f = np.zeros((sizex, sizey), dtype=np.float64)
        hx = 1/(self.ntx+1)
        hy = 1/(self.nty+1)
        self.coef = [(0.5*hx*hx*hy*hy)/(hx*hx+hy*hy), 1./(hx*hx), 1./(hy*hy)]
        for iterx in range(self.sx, self.ex + 1):
            for itery in range(self.sy, self.ey + 1):
                x = iterx * hx
                y = itery * hy
                dx = iterx - (self.sx - 1)
                dy = itery - (self.sy - 1)
                self.f[dx, dy] = 2*(x*x - x + y*y - y)
                self.u_exact[dx, dy] = x * y * (x - 1) * (y - 1)

    def computation(self):
        # print(f"Coef : {self.coef}")
        # print(f"f : {self.f}")
        for iterx in range(self.sx, self.ex+1):
            for itery in range(self.sy, self.ey+1):
                dx = iterx - (self.sx - 1)
                dy = itery - (self.sy - 1)
                dudx = self.coef[1]*(self.u[dx + 1, dy] + self.u[dx-1, dy])
                dudy = self.coef[2]*(self.u[dx, dy+1] + self.u[dx, dy-1])
                du = dudx + dudy - self.f[dx, dy]
                self.u_new[dx, dy] = self.coef[0] * du

    def output_results(self):
        print(f"Exact Solution u_exact - Computed Solution u")
        for itery in range(self.sy, self.ey+1):
            print(f"{self.u_exact[1-(self.sx-1), itery-(self.sy-1)]} "
                  f"{self.u[1-(self.sx-1), itery-(self.sy-1)]}")
