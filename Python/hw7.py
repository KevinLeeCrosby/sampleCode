import Orange

# o CEU is Northern and Western European - 0
# o GIH is Gujarati Indian from Houston - 1
# o JPT is Japanese in Tokyo - 2
# o ASW is Americans of African Ancestry - 3
# o YRI is Yoruba in Ibadan, Nigera - 4
index = dict(CEU=0, GIH=1, JPT=2, ASW=3, YRI=4)

train = Orange.data.Table("genestrain")
test = Orange.data.Table("genesblind")

nb_learner = Orange.classification.bayes.NaiveLearner()
#lr_learner = Orange.classification.logreg.LogRegLearner()
#knn_learner = Orange.classification.knn.kNNLearner()
#svm_learner = Orange.classification.svm.SVMLearner()
#tree_learner = Orange.classification.tree.TreeLearner()
#rule_learner = Orange.classification.rules.RuleLearner()

nb_learner.name = "nb"
#lr_learner.name = "lr"
#knn_learner.name = "k-NN"
#svm_learner.name = "svm"
#tree_learner.name = "tree"
#rule_learner.name = "rule"

#learners = [nb_learner, lr_learner, knn_learner, svm_learner, tree_learner, rule_learner]
#learners = [nb_learner, knn_learner, svm_learner]
learners = [nb_learner]

# cross-validation using training set
#print " "*9 + " ".join("%-4s" % learner.name for learner in learners)
#res = Orange.evaluation.testing.cross_validation(learners, train, folds=5)
#print "Accuracy %s" % " ".join("%.2f" % s for s in Orange.evaluation.scoring.CA(res))
#print "AUC      %s" % " ".join("%.2f" % s for s in Orange.evaluation.scoring.AUC(res))


nb = nb_learner(train)
#lr = lr_learner(train)
#knn = knn_learner(train, k=len(index))
#svm = svm_learner(train)
#tree = tree_learner(train, same_majority_pruning=1, m_pruning=2)
#rule = rule_learner(train)

nb.name = nb_learner.name
#lr.name = lr_learner.name
#knn.name = knn_learner.name
#svm.name = svm_learner.name
#tree.name = tree_learner.name
#rule.name = rule_learner.name

#classifiers = [nb, lr, knn, svm, tree, rule]
#classifiers = [nb, knn, svm]
classifiers = [nb]


c = classifiers[0]

return_type = Orange.classification.Classifier.GetProbabilities
targets = train.domain.class_var.values
i = 0
print "Probabilities under classifer '%s':" % c.name
print " "*13 + " ".join("%-5s" % target for target in targets)
for d in test:
  print "Person #%-2d:" % i,
  print " ".join("%5.3f" % c(d, return_type)[target] for target in targets)
  i += 1

print " "
print "Conclusion ..."
i = 0
for d in test:
  probabilities = [c(d, return_type)[target] for target in targets]
  argmax = probabilities.index(max(probabilities))
  ethnicity = targets[argmax]
  numeric = index[ethnicity]
  print "Person #%-2d:\t%s - %d" % (i, ethnicity, numeric)
  i += 1

print " "
print "Nutshell ..."
for d in test:
  probabilities = [c(d, return_type)[target] for target in targets]
  argmax = probabilities.index(max(probabilities))
  ethnicity = targets[argmax]
  numeric = index[ethnicity]
  print "%d " % numeric,


#for target in range(len(index)):
#  print "Probabilities for %s:" % train.domain.class_var.values[target]
#  print "original class ",
#  print " ".join("%-9s" % l.name for l in classifiers)

#  return_type = Orange.classification.Classifier.GetProbabilities
#  for d in test:
#    print "%-15s" % (d.getclass()),
#    print "     ".join("%5.3f" % c(d, return_type)[target] for c in classifiers)
