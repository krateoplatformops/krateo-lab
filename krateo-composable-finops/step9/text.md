## Databricks notebook for data analysis
For this following step, there is requirement of having a route between the Databricks database and the Kubernetes cluster. Since this is not possible on Killercoda, the following steps will only be shown. You can follow them if you are using your own cluster.

Create a new notebook on Databricks with the following code. This code computes unused resources on a Virtual Machine and forwards the optimization to the FinOps HTTP REST Queue:
```
import pandas as pd
import numpy as np
import random
import requests

from pyspark.sql.functions import col
from datetime import timedelta, datetime

json_template = {'resourceId': '', 'optimization': None}
json_template_optimization = {'resourceName':'', 'resourceDelta':0, 'typeChange':None}
json_template_type_change = {'cyclic':'', 'from':'', 'to':''}
topic = 'optimizations'
url = '<your_url_here>:<service_port>/upload?topic=' + topic

TIME_GRANULARITY = 5 # in minutes

def compute(df: pd.DataFrame, resource_id: str, metric_name: str):
    time_durations = [int(60/TIME_GRANULARITY)] # in minutes
    _, moving_average_values = moving_average(df, np.min(time_durations))
    usage, usage_max = utilization_per_unit(df, moving_average_values, 'd')
    proposed_optimization = optimize(usage, usage_max)
    window_low_utilization = find_start_finish_window_low_utilization(proposed_optimization)

    json_template_type_change['cyclic'] = 'day'
    json_template_type_change['from'] = str(24 + window_low_utilization[2] if window_low_utilization[2] < 0 else window_low_utilization[2]) + ':00'
    json_template_type_change['to'] = str(window_low_utilization[1] + window_low_utilization[2]) + ':00'
    json_template_optimization['resourceName'] = metric_name
    json_template_optimization['resourceDelta'] = -window_low_utilization[0]
    json_template_optimization['typeChange'] = json_template_type_change
    json_template['resourceId'] = resource_id
    json_template['optimization'] = json_template_optimization

    #_ = requests.post(url, json=json_template)
    print('For resource', resource_id)
    print('Remove', str(min(proposed_optimization))+'%', 'CPU(s) overall')
    print('Remove', str(window_low_utilization[0])+'%', 'CPU(s) from', str(24 + window_low_utilization[2] if window_low_utilization[2] < 0 else window_low_utilization[2]) + ':00', 'to', str(window_low_utilization[1] + window_low_utilization[2]) + ':00')

    print("JSON:\n", json_template)



def moving_average(df: pd.DataFrame, time_duration: int) -> list:
    moving_average_values = [0.0 for _ in range(len(df['Value']))]
    result = []
    contiguos = False
    for i in range(len(df['Value'])):
        partial = 0.0
        cur_index = i
        for _ in range(cur_index, cur_index + time_duration):
            if cur_index < len(df['Value']):
                partial += df['Value'][cur_index]
                cur_index += 1
        partial = float(partial)/float(time_duration)
        moving_average_values[i] = partial
        if partial > np.average(df['Value']) and contiguos:
            result[-1] = (result[-1][0], result[-1][1]+1)
        elif partial > np.average(df['Value']):
            result.append((df['timestamp'][i], 1))
            contiguos = True
        else:
            contiguos = False
    return result, moving_average_values

def utilization_per_unit(df: pd.DataFrame, moving_average_values: list, unit: str) -> tuple[list, list]:
    if unit == 'd':
        fields = 24
    usage = [0.0 for _ in range(fields)]
    usage_max = [-1.0 for _ in range(fields)]
    usage_counter = [0 for _ in range(fields)]

    for index, value in enumerate(moving_average_values):
        if value > np.average(df['Value']):
            usage[df['timestamp'][index].hour] += value
            usage_counter[df['timestamp'][index].hour] += 1
        if value > usage_max[df['timestamp'][index].hour]:
            usage_max[df['timestamp'][index].hour] = value
    
    for index, _ in enumerate(usage):
        if usage_counter[index] != 0:
            usage[index] = usage[index] / float(usage_counter[index])

    return usage, usage_max
            
def optimize(usage: list, usage_max: list) -> list:
    result = [0 for _ in range(len(usage))]
    for index, value in enumerate(usage):
        left_over_average = 100 - value
        left_over_max = 100 - usage_max[index]
        if left_over_average > 0 and left_over_max > 0:
            smaller_left_over = min(left_over_average, left_over_max)
            result[index] = int(smaller_left_over)
    return result

def find_start_finish_window_low_utilization(proposed_optimization: list) -> tuple:
    lowest_length = (proposed_optimization[0], 0, 0)
    lowest_length_temp = (proposed_optimization[0], 0, 0)
    for index, value in enumerate(proposed_optimization):
        if value != lowest_length_temp[0] and value != lowest_length_temp[0] + 1 and value != lowest_length_temp[0] - 1:
            if lowest_length_temp[1] > lowest_length[1]:
                lowest_length = (lowest_length_temp[0], lowest_length_temp[1], lowest_length_temp[2])
            else:
                lowest_length_temp = (proposed_optimization[index], 0, 0)    
        else:
            lowest_length_temp = (lowest_length_temp[0], lowest_length_temp[1]+1, lowest_length_temp[2])
    # Check backwards if index is 0
    if lowest_length[2] == 0:
        for index, value in enumerate(proposed_optimization):
            if index == 0:
                continue
            if proposed_optimization[-index] == lowest_length[0] or proposed_optimization[-index] == lowest_length[0] + 1 or proposed_optimization[-index] == lowest_length[0] - 1:
                lowest_length = (lowest_length[0], lowest_length[1] + 1, -index)
            else:
                return lowest_length
    return lowest_length

def main():
    table_name = dbutils.widgets.get('table_name')
    table = spark.table(table_name)
    for resource_id in table.select('ResourceId').distinct().toPandas()['ResourceId']:
        for metric_name in table.select('metricName').distinct().where(f"ResourceId == '{resource_id}'").toPandas()['metricName']:
            table_compute = table.where("ResourceId == '%s' AND metricName == '%s'" % (resource_id, metric_name))
            compute(table_compute.sort('timestamp').toPandas(), resource_id, metric_name)

if __name__=='__main__':
    main()
```

You should compile the two global variables "url" and "topic". The first one is the public domain url of your Kubernetes cluster, including the port for the FinOps HTTP REST Queue application, which by default will be 31723. The second one is the topic to publish the json of the optimization on. You can also schedule this notebook to run periodically and optimize your cluster every specified period. 

### Installing the FinOps HTTP REST Queue
To receive optimizations, you should install in your cluster the FinOps HTTP REST Queue. Since this component relies on a NATS server, install the NATS server first through HELM:
```
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm install -n finops nats nats/nats
```

Then, install the FinOps HTTP REST Queue, which can be done with the HELM chart:
```
helm install finops-http-rest-queue krateo/finops-http-rest-queue -n finops
```
This chart includes the NodePort on 31723.

### Installing the FinOps NATS Subscriber
To receive the optimizations, we use the FinOps NATS Subscriber. This component connects to the NATS server and subscribes on the specified topic, then creates a CR for an operator to apply the optimizations. To install it, firstly clone the chart repository:
```
git clone https://github.com/krateoplatformops/finops-nats-subscriber-chart.git
```

Then, you must edit the values.yaml file to configure four parameters:
 - subTopic: the topic that the subscriber will receive data on;
 - optNamespace: the namespace where the "finops-operator-vm-manager" is deployed;
 - optSecretName: the name of the secret containing the token for the Azure REST API;
 - optSecretNamespace: the namespace of the secret containing the token for the Azure REST API;

Finally:
```
helm install finops-nats-subscriber ./finops-nats-subscriber/chart -n finops
```

## Optimization for Azure Virtual Machines
To automatically apply the computed optimizations, you can use the FinOps Operator VM Manager:
```
helm install finops-operator-vm-manager krateo/finops-operator-vm-manager
```
