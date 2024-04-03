## Let's configure the Azure Databricks notebook - credentials input

Input your data in the following configuration script:
```plain
cd /
./database-input.sh
```{{exec}}

Then apply the configuration of the database to the cluster:
```plain
kubectl apply -f database.yaml
```{{exec}}

You can proceed to the creation of the combined exporter/scraper configuration.
