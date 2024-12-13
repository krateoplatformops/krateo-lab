## Notebook for data analysis
For this following step, there is requirement of having an active Azure Virtual Machine to collect data from and optimize. Since this is not possible on Killercoda, the following steps will only be shown. You can follow them if you are using your own cluster.

Create a new notebook with the following code. This code computes unused resources on a Virtual Machine and forwards the optimization to the FinOps HTTP REST Queue:
```python
import pandas as pd
import numpy as np

# Global variables
json_template = {'resourceId': '', 'optimization': None}
json_template_optimization = {'resourceName':'', 'resourceDelta':0, 'typeChange':None}
json_template_type_change = {'cyclic':'', 'from':'', 'to':''}

TIME_GRANULARITY = 5  # in minutes

def compute(df: pd.DataFrame, resource_id: str, metric_name: str):
    time_durations = [int(60/TIME_GRANULARITY)]  # in minutes
    _, moving_average_values = moving_average(df, np.min(time_durations))
    usage, usage_max = utilization_per_unit(df, moving_average_values, 'd')
    proposed_optimization = optimize(usage, usage_max)
    window_low_utilization = find_start_finish_window_low_utilization(proposed_optimization)

    json_template_type_change['cyclic'] = 'day'
    json_template_type_change['from'] = str(24 + window_low_utilization[2] if window_low_utilization[2] < 0 else window_low_utilization[2]) + ':00'
    json_template_type_change['to'] = str(window_low_utilization[1] + window_low_utilization[2]) + ':00'
    json_template_optimization['resourceName'] = metric_name
    json_template_optimization['resourceDelta'] = -window_low_utilization[0]
    json_template_optimization['typeChange'] = json_template_type_change.copy()  # Added .copy()
    json_template['resourceId'] = resource_id
    json_template['optimization'] = json_template_optimization.copy()  # Added .copy()

    print(json_template)

def moving_average(df: pd.DataFrame, time_duration: int) -> tuple[list, list]:  # Fixed return type hint
    moving_average_values = [0.0 for _ in range(len(df['average']))]
    result = []
    contiguos = False
    for i in range(len(df['average'])):
        partial = 0.0
        cur_index = i
        for _ in range(cur_index, cur_index + time_duration):
            if cur_index < len(df['average']):
                partial += df['average'][cur_index]
                cur_index += 1
        partial = float(partial)/float(time_duration)
        moving_average_values[i] = partial
        if partial > np.average(df['average']) and contiguos:
            result[-1] = (result[-1][0], result[-1][1]+1)
        elif partial > np.average(df['average']):
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
        if value > np.average(df['average']):
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
            lowest_length_temp = (proposed_optimization[index], 0, index)  # Fixed: Added index
        else:
            lowest_length_temp = (lowest_length_temp[0], lowest_length_temp[1]+1, lowest_length_temp[2])
    
    # Check backwards if index is 0
    if lowest_length[2] == 0:
        for index in range(1, len(proposed_optimization)):
            if proposed_optimization[-index] == lowest_length[0] or proposed_optimization[-index] == lowest_length[0] + 1 or proposed_optimization[-index] == lowest_length[0] - 1:
                lowest_length = (lowest_length[0], lowest_length[1] + 1, -index)
            else:
                return lowest_length
    return lowest_length

def main():   
    table_name_arg = sys.argv[5]
    table_name_key_value = str.split(table_name_arg, '=')
    if len(table_name_key_value) == 2:
        if table_name_key_value[0] == 'table_name':
            table_name = table_name_key_value[1]
    try:
        resource_query = f"SELECT DISTINCT ResourceId FROM {table_name}"
        cursor.execute(resource_query)
        resource_ids = pd.DataFrame(cursor.fetchall(), columns=['ResourceId'])

        for resource_id in resource_ids['ResourceId']:
            metric_query = ("SELECT DISTINCT metricName\n"
                f"FROM {table_name}\n"
                "WHERE ResourceId = ?"
            )
            cursor.execute(metric_query, (resource_id,))
            metric_names = pd.DataFrame(cursor.fetchall(), columns=['metricName'])
            
            for metric_name in metric_names['metricName']:
                data_query = ("SELECT *\n"
                    f"FROM {table_name}\n"
                    "WHERE ResourceId = ?\n"
                    "AND metricName = ?\n"
                    "ORDER BY timestamp"
                )
                cursor.execute(data_query, (resource_id, metric_name))
                raw_data = cursor.fetchall()
                column_names = [desc[0] for desc in cursor.description]

                table_compute = pd.DataFrame(raw_data, columns=column_names)

                # Convert timestamp column to datetime
                if 'timestamp' in table_compute.columns:
                    table_compute['timestamp'] = pd.to_datetime(table_compute['timestamp'], unit='ms')
                    table_compute['timestamp'] = pd.to_datetime(table_compute['timestamp'], unit='ms').dt.tz_localize('UTC')

                if 'average' in table_compute.columns:
                    table_compute['average'] = pd.to_numeric(table_compute['average'], errors='coerce')
                
                compute(table_compute, resource_id, metric_name)
    
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    main()
```

Upload the notebook into the database:
```plain
echo "import pandas as pd
import numpy as np
# Global variables
json_template = {'resourceId': '', 'optimization': None}
json_template_optimization = {'resourceName':'', 'resourceDelta':0, 'typeChange':None}
json_template_type_change = {'cyclic':'', 'from':'', 'to':''}
TIME_GRANULARITY = 5  # in minutes
def compute(df: pd.DataFrame, resource_id: str, metric_name: str):
    time_durations = [int(60/TIME_GRANULARITY)]  # in minutes
    _, moving_average_values = moving_average(df, np.min(time_durations))
    usage, usage_max = utilization_per_unit(df, moving_average_values, 'd')
    proposed_optimization = optimize(usage, usage_max)
    window_low_utilization = find_start_finish_window_low_utilization(proposed_optimization)
    json_template_type_change['cyclic'] = 'day'
    json_template_type_change['from'] = str(24 + window_low_utilization[2] if window_low_utilization[2] < 0 else window_low_utilization[2]) + ':00'
    json_template_type_change['to'] = str(window_low_utilization[1] + window_low_utilization[2]) + ':00'
    json_template_optimization['resourceName'] = metric_name
    json_template_optimization['resourceDelta'] = -window_low_utilization[0]
    json_template_optimization['typeChange'] = json_template_type_change.copy()  # Added .copy()
    json_template['resourceId'] = resource_id
    json_template['optimization'] = json_template_optimization.copy()  # Added .copy()
    print(json_template)
def moving_average(df: pd.DataFrame, time_duration: int) -> tuple[list, list]:  # Fixed return type hint
    moving_average_values = [0.0 for _ in range(len(df['average']))]
    result = []
    contiguos = False
    for i in range(len(df['average'])):
        partial = 0.0
        cur_index = i
        for _ in range(cur_index, cur_index + time_duration):
            if cur_index < len(df['average']):
                partial += df['average'][cur_index]
                cur_index += 1
        partial = float(partial)/float(time_duration)
        moving_average_values[i] = partial
        if partial > np.average(df['average']) and contiguos:
            result[-1] = (result[-1][0], result[-1][1]+1)
        elif partial > np.average(df['average']):
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
        if value > np.average(df['average']):
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
            lowest_length_temp = (proposed_optimization[index], 0, index)  # Fixed: Added index
        else:
            lowest_length_temp = (lowest_length_temp[0], lowest_length_temp[1]+1, lowest_length_temp[2])
    # Check backwards if index is 0
    if lowest_length[2] == 0:
        for index in range(1, len(proposed_optimization)):
            if proposed_optimization[-index] == lowest_length[0] or proposed_optimization[-index] == lowest_length[0] + 1 or proposed_optimization[-index] == lowest_length[0] - 1:
                lowest_length = (lowest_length[0], lowest_length[1] + 1, -index)
            else:
                return lowest_length
    return lowest_length
def main():   
    table_name_arg = sys.argv[5]
    table_name_key_value = str.split(table_name_arg, '=')
    if len(table_name_key_value) == 2:
        if table_name_key_value[0] == 'table_name':
            table_name = table_name_key_value[1]
    try:
        resource_query = f\"SELECT DISTINCT ResourceId FROM {table_name}\"
        cursor.execute(resource_query)
        resource_ids = pd.DataFrame(cursor.fetchall(), columns=['ResourceId'])

        for resource_id in resource_ids['ResourceId']:
            metric_query = (\"SELECT DISTINCT metricName\n\"
                f\"FROM {table_name}\n\"
                \"WHERE ResourceId = ?\"
            )
            cursor.execute(metric_query, (resource_id,))
            metric_names = pd.DataFrame(cursor.fetchall(), columns=['metricName'])
            
            for metric_name in metric_names['metricName']:
                data_query = (\"SELECT *\n\"
                    f\"FROM {table_name}\n\"
                    \"WHERE ResourceId = ?\n\"
                    \"AND metricName = ?\n\"
                    \"ORDER BY timestamp\"
                )
                cursor.execute(data_query, (resource_id, metric_name))
                raw_data = cursor.fetchall()
                column_names = [desc[0] for desc in cursor.description]
                table_compute = pd.DataFrame(raw_data, columns=column_names)
                # Convert timestamp column to datetime
                if 'timestamp' in table_compute.columns:
                    table_compute['timestamp'] = pd.to_datetime(table_compute['timestamp'], unit='ms')
                    table_compute['timestamp'] = pd.to_datetime(table_compute['timestamp'], unit='ms').dt.tz_localize('UTC')
                if 'average' in table_compute.columns:
                    table_compute['average'] = pd.to_numeric(table_compute['average'], errors='coerce')
                compute(table_compute, resource_id, metric_name)
    finally:
        cursor.close()
        connection.close()
if __name__ == \"__main__\":
    main()" > cyclic.py
curl -X POST -u system:$(kubectl get secret user-system-cratedb-cluster -n finops -o json | jq -r '.data.password' | base64 --decode) http://localhost:$(kubectl get service -n finops finops-database-handler -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/compute/cyclic/upload --data-binary "@cyclic.py"
```{{exec}}

Query the new notebook for the optimizations:
```plain
curl -X POST -u system:$(kubectl get secret user-system-cratedb-cluster -n finops -o json | jq -r '.data.password' | base64 --decode) http://localhost:$(kubectl get service -n finops finops-database-handler -o custom-columns=ports:spec.ports[0].nodePort | tail -1)/compute/cyclic --header "Content-Type: application/json" --data '{"table_name":"krateo_finops_tutorial_res"}'
```{{exec}}

Note: this code may fail notifying the user that the table does not exist, however, this is due to Killercoda slow execution of the scrapers' upload. To avoid this, check the status of the resource scrapers and their uploads:
```plain
kubectl logs -n finops -f deployment/exporterscraperconfig-azure-res0-scraper-deployment
```{{exec}}
This step may take multiple minutes.

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
