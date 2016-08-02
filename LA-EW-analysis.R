setwd("~/Documents/la-project/data/edge-weights")
temp = list.files(pattern="*.csv")
for (i in 1:length(temp)){
  assign(substr(temp[i],0,nchar(temp[i])-20), read.csv(temp[i]))
} 
rm(temp)

brains = list(TKA011, TKA013, TKA021, TKA028, TKA054, TKA068, TKA076, TKA084, TKA094, TKA098)
names(brains) = c("TKA011", "TKA013", "TKA021", "TKA028", "TKA054", "TKA068", "TKA076", "TKA084", "TKA094", "TKA098")

rm(TKA011)
rm(TKA013)
rm(TKA021)
rm(TKA028)
rm(TKA054)
rm(TKA068)
rm(TKA076)
rm(TKA084)
rm(TKA094)
rm(TKA098)

for(i in 1:length(brains)){
  brains[[i]] = brains[[i]][2:4]
}

LA_volume = c(115,2647,5494,2541,909,1110,1622,697,330,2291)
mean_EW = c(mean(brains[["TKA011"]]$edge.weight),mean(brains[["TKA013"]]$edge.weight),mean(brains[["TKA021"]]$edge.weight),mean(brains[["TKA028"]]$edge.weight),mean(brains[["TKA054"]]$edge.weight),mean(brains[["TKA068"]]$edge.weight),mean(brains[["TKA076"]]$edge.weight),mean(brains[["TKA084"]]$edge.weight),mean(brains[["TKA094"]]$edge.weight),mean(brains[["TKA098"]]$edge.weight))

plot(LA_volume, mean_EW, main = "Mean Edge Weight vs Leukoaraiosis Volume", xlab = "Volume of Leukoariosis (mm^3)", ylab = "Mean Edge Weight", pch = 19)
abline(lm(mean_EW~LA_volume), col="red")

mean_EW.lm = lm(LA_volume ~ mean_EW)
summary(mean_EW.lm)$r.squared	

cor(LA_volume, mean_EW, method = "spearman")
nodes = sort(unique(c(brains[[1]][,1],brains[[1]][,2])))

node_mat = matrix(data = 0, nrow=82, ncol=82, dimnames = list(nodes,nodes))
brain_mat = list(node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat)
bin_brain_mat = list(node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat,node_mat)
names(brain_mat) = c("TKA011", "TKA013", "TKA021", "TKA028", "TKA054", "TKA068", "TKA076", "TKA084", "TKA094", "TKA098")

#creates matrices to store node strengths and node degrees
node_weights = matrix(data = 0, nrow = 10, ncol = 82, dimnames = list(names(brain_mat), nodes))
node_degrees = matrix(data = 0, nrow = 10, ncol = 82, dimnames = list(names(brain_mat), nodes))

#creates connectivity matrix for nodes
for(i in 1:length(brain_mat)){
  for(n in 1:length(brains[[i]]$edge.weight)){
    src_ind = which(dimnames(brain_mat[[i]])[[1]] == brains[[i]]$source.node[n])
    dest_ind =  which(dimnames(brain_mat[[i]])[[1]] == brains[[i]]$dest.node[n])
    brain_mat[[i]][src_ind,dest_ind] = brains[[i]]$edge.weight[n]
    #since connections go both ways, mirror the matrix along the diagonal
    brain_mat[[i]][dest_ind,src_ind] = brains[[i]]$edge.weight[n]
  }
  #fills binary matrix
  bin_brain_mat[[i]] = brain_mat[[i]]
  bin_brain_mat[[i]][brain_mat[[i]] > 0] <- 1 
  #saves node strengths
  node_weights[i,] = colSums(brain_mat[[i]])
  #saves node degrees
  node_degrees[i,] = colSums(bin_brain_mat[[i]])
}

NW_values = vector(mode = "numeric", length = 82)
ND_values = vector(mode = "numeric", length = 82)

count = 0

for(i in 1:length(node_weights[1,])){
  name = names(node_weights[1,])[i]
  
  #calculate the correlation for LA and node weights/degree
  NW_cor = cor(LA_volume, node_weights[,i], method = "spearman")
  ND_cor = cor(LA_volume, node_degrees[,i], method = "spearman")
  
  NW_values[i] = NW_cor
  ND_values[i] = ND_cor
  
  if(NW_cor <= -.37){
    count = count + 1
    #print(paste(name, NW_cor))
    #plot(LA_volume, node_weights[,name], main = paste("Node Strength vs Leukoaraiosis Volume for Node",name), xlab = "Volume of Leukoaraiosis (mm^3)", ylab = "Node Strength")
  }
  if(ND_cor <= -.37){
    print(paste(name, ND_cor))
    #plot(LA_volume, node_degrees[,name], main = paste("Node Degree vs Leukoaraiosis Volume for Node",name), xlab = "Volume of Leukoaraiosis (mm^3)", ylab = "Node Degree")
  }
}
plot(LA_volume, node_degrees[,"54"], main = paste("Node Degree vs Leukoaraiosis Volume for Node",name), xlab = expression('Volume of Leukoaraiosis in mm' ^ 3 ), ylab = "Node Degree")
abline(lm(node_degrees[,"54"]~LA_volume), col="red")
hist(NW_values, main = "R Values for Node Strength vs LA Volume", xlab = "Correlation Coefficient", ylab = "Number of Nodes")
hist(ND_values, main = "R Values for Node Degree vs LA Volume", xlab = "Correlation Coefficient", ylab = "Number of Nodes")

