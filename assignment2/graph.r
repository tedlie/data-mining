#      [,1] [,2] [,3] [,4]
# [1,]    0    1    1    0
# [2,]    1    0    1    0
# [3,]    1    1    0    1
# [4,]    0    0    1    0

# graph.init = matrix(c(
#   0,1,1,0,
#   1,0,1,0,
#   1,1,0,1,
#   0,0,1,0
# ), 4, 4)

#      [,1] [,2] [,3] [,4] [,5]
# [1,]    0    1    1    0    1
# [2,]    1    0    0    1    0
# [3,]    1    0    0    1    1
# [4,]    0    1    1    0    0
# [5,]    1    0    1    0    0
graph.init = matrix(c(
  0,1,1,0,1,1,0,0,1,0,1,0,0,1,1,0,1,1,0,0,1,0,1,0,0
), 5, 5)

graph.result = list()

n = function(v) {
  which(graph.init[v,] == 1, arr.in=TRUE)
}

calcC = function(matrix) {
  bk(c(), 1:nrow(matrix), c())
}

# BronKerbosch1(R,P,X):
#     if P and X are both empty:
#         report R as a maximal clique
#     for each vertex v in P:
#         BronKerbosch1(R ⋃ {v}, P ⋂ N(v), X ⋂ N(v))
#         P := P \ {v}
#         X := X ⋃ {v}
bk = function(R,P,X, res = list()) {
  if(length(P) == 0 && length(X) == 0){
    graph.result[[length(graph.result) + 1]] = R
    print(R)
    return
  }

  for (v in P) {
    bk(union(R, v), intersect(P, n(v)), intersect(X, n(v)))
    P = P[-1]
    X = union(X, v)
  }
}