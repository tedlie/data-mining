#
# @xs Array<Array<Integer>>
# @tr A custom tree
#
tree.classify = function(cases, tr) {
  classes = c()
  for (i in 1:(nrow(cases))) {
    classes[i] = tree.calcClassify(cases[i,], tr)
  }
  return(classes)
}

tree.calcClassify = function(case, tr) {
  if(tree.isNode(tr)){
    index = tr[[3]][[3]]
    comp = case[index]

    # Walk left
    if(comp <= tr[[4]]){
      return(tree.calcClassify(case, tr[[5]]))
    # Walk right
    } else {
      return(tree.calcClassify(case, tr[[6]]))
    }
  } else if(tree.isLeaf(tr)){
    if (tr[1] > tr[2]) {
      return(0)
    } else {
      return(1)
    }
  } else {
    print("\n\nWTF")
  }
}

tree.isNode = function(tr) {
  return(length(tr) == 6)
}

tree.isLeaf = function(tr) {
  return(length(tr) == 2)
}

tree.grow = function(matrix, class, nmin=2, minleaf=1) {
  nClass0 = length(which(class == 0))
  nClass1 = length(which(class == 1))
  
  if(nrow(matrix) < nmin || nClass0 == 0 || nClass1 == 0){
    return(list(nClass0, nClass1))
  }

  bestR = -1
  bestS = NULL
  bestI = NULL
  for (i in 1:ncol(matrix)) {
    result = tree.bestsplit(matrix[,i], class)
    if(result[2] > bestR) {
      bestR = result[2]
      bestS = result[1]
      bestI = i
    }
  }

  left = matrix[matrix[,bestI] <= bestS,]
  leftClass = class[matrix[,bestI] <= bestS]

  right = matrix[matrix[,bestI] > bestS,]
  rightClass = class[matrix[,bestI] > bestS]

  if(nrow(left) < minleaf || nrow(right) < minleaf) {
    return(list(nClass0, nClass1))
  }

  leftG = tree.grow(left, leftClass, nmin, minleaf)
  rightG = tree.grow(right, rightClass, nmin, minleaf)

  return(
    list(nClass0, nClass1, bestI, bestS, leftG, rightG)
  )
}

tree.print = function(node, level = 0) {
  indent = sprintf(paste0("%", level, "s"), "")
  if(tree.isNode(node)) {
    cat(indent, sprintf("Node: (%s|%s) { bestI: %s, bestS: %s }", node[1], node[2], node[3], node[4]), "\n")
    tree.print(node[[5]], level + 2)
    tree.print(node[[6]], level + 2)
  } else {
    cat(indent, sprintf("Leaf: (%s|%s)", node[1], node[2]), "\n")
  }

}

tree.main = function() {
  matrix = read.csv('credit.txt')
  small = tree.grow(matrix[,1:5], matrix[,6])

  return(small)

  matrix = read.csv('pima.txt')
  large = tree.grow(matrix[,1:8], matrix[,9])

  return(c(small, large))
}

tree.impurity = function (v) {
  (sum(v) / length(v)) * (length(v) - sum(v)) / length(v)
}

tree.bestsplit = function (x, y) {
  x_ <- x[order(x)]
  y_ <- y[order(x)]

  bestR = -1
  bestS = 0 # "Should be" NULL

  for (i in 1:(length(x_) - 1))  {
    if (x_[i] == x_[i + 1]) {
      next
    }

    a <- mean(x_[i]:x_[i + 1])
    left = y_[x_ <= a]
    right = y_[x_ > a]
    piLeft <- length(left)/length(x_)
    piRight <- length(right)/length(x_)

    currentR = tree.impurity(y) - (piLeft*tree.impurity(left) + piRight*tree.impurity(right))
    if(currentR > bestR){
      bestR = currentR
      bestS = a
    }
  }

  return(c(bestS, bestR))
}
