## dYbench

### Introduction & Motivation

This project proposes a simple benchmarking framework for the DymensionHub blockchain. The framework is designed following a git-ops based approach, where all infrastructure, test coordination and execution is orchestrated by GH Actions workflows. Bench workloads are coordinated/distributed by GH runners and bench results are stored as GH artifacts.

Besides a small/cheap set of dedicated pre-existing cloud resources (VPCs, SGs, routing, Policies for short lived credentials etc), the framework is entirely ephemeral; becomes obsolete after every test round.

### Stack
 - Cloud Provider: AWS
 - Terraform & Terraform Cloud for Supporting cloud infrastructure (VPCs, IAM roles and policies, S3 storage etc)
 - DymensionHub nodes/validators and rollApp nodes are deployed on AWS ec2 nodes
 - A redis instance is used for test data storage

### Processes

Framework processes/stages are controlled via [deploy_bench](https://github.com/MariosAronis/dYbench/blob/main/.github/workflows/deploy_bench.yaml) workflow. The workflow provides user inputs to control the number of hub nodes/validators, rollApps, and the transaction mix to benchmark against (total number of transactions and percentage of each Tx type). 

GH runners interact with cloud provider/resources via AWS api. A minimum permissions' approach is satisfied with the use of short lived credentials (SLCs) allocated to the runner via an IAM identity provider combined with [roles/policies](https://github.com/MariosAronis/dYbench/blob/main/terraform/modules/iam/iam.tf). As a result the runner can only access specific resources (for example deploy computes on a limited set of VPCs). Additionaly, the SLCs may further narrow down the permission boundaries specifying the workflow source repo, the GH event actor and other action attributes. 

All testnet operations including setup steps, generation of transactions, collection of metrics and statistics are coordinated via AWS SSM service. With ssm, we allow our GH runner to perform secure remote operations on our computes (validators, rollapp nodes) via bash commands, local or remote scripts. SSM operations are also relying on the allocated SLCs.

#### 1. Hub Deployment
- We deploy a configurable number of computes and install dependencies with a cloud init script. A bootstrap/leader node is created with [bootstrap.json](https://github.com/MariosAronis/dYbench/blob/main/.github/scripts/bootstrap.json). The workflow sequence uploads the dymd binary to s3 storage.
- A configurable number of validators is also deployed. A new key is generated for each node/validator, and DYM allocation Tx are submitted on the leader node for each new account with [allocate_DYM.sh](https://github.com/MariosAronis/dYbench/blob/main/.github/scripts/allocate_DYM.sh) and a create validator Tx is generated on each node [create_validator.sh](https://github.com/MariosAronis/dYbench/blob/main/.github/scripts/create_validator.sh).

#### 2. RollApps Deployment
- The rollapp nodes' number is also configurable on the action trigger and deployment happens similarly to validators. We execute the [deploy_rollApps.sh](https://github.com/MariosAronis/dYbench/blob/main/.github/scripts/deploy_rollApps.sh) script to install roller, setup the roll app parameters, register the sequencer and launch the rollapp.

*The framework has been designed having a private dymensionHub in mind. Roller does not (??) offer an option argument to deploy against a network other than public testen, devnet or Local. The description that follows assumes we have the option to target roolapp deployment against our new private dymensioHub*

#### 3. Redis instantiation
- For storing benchmark metrics, we will use a lightweigth redis data store. Redis will be installed on a dedicated ec2 instance and will be accessible via a dns record on a private internal domain. 

#### 4. Benmarking
- Depending on the transaction mix defined in the workflow trigger, the gh runner
will start distributing the workloads (transactions) to rollapp nodes/clients. For now there is no consideration for a specific distribution algorithm, so we assume round robin execution. 

We further need to consider parallel execution mode for different workloads, to achieve realistic traffic model. Thid could be implemented with triggering of separate GH workflows per transaction type. Assume our Tx mix consists of tx types 1, 2 and 3, once all test infrastructure is ready, we trigger workflows dybench_workload1.yaml, dybench_workload2.yaml and dybench_workload3.yaml with the appropriate number/rate of generated Txs. The new runners will then distribute Tx generation commands to clients/rollapp nodes via SSM and the permissions model described above (SLCs). **The workflow-dispatch event syntax to start a wf from inside another workflow is not defined in the context of this exercise**

> Calculations:

> For each submitted transaction we add a redis record consisting of Tx hash, block height and tx timestamp. This record is written to redis by the client/rollapp node. For all non-empty finalized blocks, we also write a record to redis, consisting of the block hash/height and a list with the included Txs.

>Once the workloads are finalized, we release all compute resources besides the redis node. Calculations will be performed by the parent GH action runner:

>**Latency**: for each transaction, confirmation time will be measured as the duration between Tx timestamp and block timestamp. Network latency will be the average of these values.

>**TPS**: from the block data recorded, we can estimate the average block size and average block time. TPS will be the ratio of the two figures. 

>*For all measurements we assume finality=1*

#### 5. Usage

1. Clone the dYbench repository.
2. Build the test environment infrastructure via terraform. This repo assumes integration with terraform cloud. Follow the [instructions](https://github.com/MariosAronis/dYbench/blob/main/terraform/README.md) to setup the needed cloud resources.
3. On the repo actions dashboard, trigger a manual run of [Deploy DymensionHub](https://github.com/MariosAronis/dYbench/actions) providing the necessary parameters.
