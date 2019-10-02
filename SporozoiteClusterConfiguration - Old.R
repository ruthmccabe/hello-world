#cluster intialisation - https://mrc-ide.github.io/didehpc/vignettes/didehpc.html

install.packages("drat")
drat:::add("mrc-ide")
install.packages("didehpc")

options(
  didehpc.username = "rom116",
  didehpc.home = "Q:/")

didehpc:::didehpc_config(credentials=list(username="rom116"),home = "Q:/")

# share <- didehpc::path_mapping("malaria", "M:", "//fi--didef2/malaria", "M:")
# config <- didehpc::didehpc_config(shares = share)

context::context_log_start()

root <- "Q:/Cluster"

setwd("Q:/")

#any files loaded here need to be in the current working directory 
ctx <- context::context_save(root, packages=list(attached = "mlevcm"), package_sources = provisionr::package_sources(github = "pmesperanca/mlevcm"),sources="clusterFunct.R")

obj <- didehpc::queue_didehpc(ctx)

#check configuration
sessionInfo()

#check cluster load 
obj$cluster_load()

#to cancel
#obj$unsubmit(TauAnalysis)


####Reps Analysis####

params_reps <- c(10,25,50,75,100,150,250,500)

RepsAnalysis <- obj$enqueue_bulk(params_reps,sporozoite_reps,do_call = TRUE)

RepsAnalysis$status()
RepsAnalysis$results()

####Tau Analysis####

#set the parameters - 88 combos (when including Z)
params_tau1 <- expand.grid(method=c(1,2),balanced=c(1,2),tau = seq(0,0.05,0.005),Z = c(1,2))

#send models to run in the cluster
TauAnalysis1 <- obj$enqueue_bulk(params_tau1,sporozoite_tau1,do_call = TRUE)
TauAnalysis1$status()
TauAnalysis1$results()

#reformat the results and save in csv 
results_tau <- matrix(unlist(TauAnalysis1$results()),ncol=12,byrow=TRUE)
write.csv(results_tau,"TauAnalysisResults.csv")


#set the parameters - 88 combos (when including Z)
params_tau2 <- expand.grid(method=c(1,2),balanced=c(1,2),tau = seq(0,0.05,0.005))

#send models to run in the cluster
TauAnalysis2 <- obj$enqueue_bulk(params_tau2,sporozoite_tau2,do_call = TRUE)
TauAnalysis2$status()
TauAnalysis2$results()



####Basis Analysis####

BasisAnalysis <- obj$enqueue(sporozoite_basis())
BasisAnalysis$status()
BasisAnalysis$results()






