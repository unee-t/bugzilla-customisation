https://console.aws.amazon.com/support/cases#/5800305021/en

1. Create snapshot CLI commands:
-----------------------------------------
For Linux, OS X, or Unix::
aws rds create-db-cluster-snapshot /
    --db-cluster-identifier mydbcluster /
    --db-cluster-snapshot-identifier mydbclustersnapshot 


2. Restore CLI commands:
-------------------------------------
For Linux, OS X, or Unix:
aws rds restore-db-cluster-from-snapshot \
    --db-cluster-identifier mynewdbcluster \
    --snapshot-identifier mydbclustersnapshot
