# Deploy tam-lab using Terragrunt

## 1. installation

> https://terragrunt.gruntwork.io/docs/getting-started/install/

## 2. setup environments

It is the same with Terraform

```bash
TENCENTCLOUD_SECRET_ID=xxxx
TENCENTCLOUD_SECRET_KEY=xxxx
```

## 3. Deploy the Infra

### 3.1 Overview

#### Layout 

```bash 

├── dev-ap-shanghai                         <-- environment
│   ├── README.md
│   ├── env.yaml                          <-- environtmen variables
│   ├── integration                       <-- terragrunt integration here
│   │   ├── as                          <-- product class
│   │   │   ├── app-app1              <-- deploy unit
│   │   │   │   └── terragrunt.hcl
│   │   │   └── app-frontend
│   │   │       └── terragrunt.hcl
│   │   ├── clbs
│   │   │   ├── app-app1
│   │   │   │   └── terragrunt.hcl
│   │   │   └── app-frontend
│   │   │       └── terragrunt.hcl
│   │   ├── databases
│   │   │   ├── cdb
│   │   │   │   └── terragrunt.hcl
│   │   │   └── redis
│   │   │       └── terragrunt.hcl
│   │   ├── domains
│   │   │   └── private_dns
│   │   │       └── terragrunt.hcl
│   │   ├── network
│   │   │   ├── app1_subnet
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── db_subnet
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── frontend_subnet
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── tke_node_subnet
│   │   │   │   └── terragrunt.hcl
│   │   │   ├── tke_pod_subnet
│   │   │   │   └── terragrunt.hcl
│   │   │   └── vpc
│   │   │       └── terragrunt.hcl
│   │   ├── security_groups
│   │       └── all
│   │           └── terragrunt.hcl
│   │   └── tke
│   │   │   ├── app2
│   │   │   │   └── terragrunt.hcl
│   │       └── cluster
│   │           └── terragrunt.hcl
│   ├── scripts
│   │   └── init.sh
│   ├── templates
│   │   ├── app1.sh.tftpl
│   │   └── frontend.sh.tftpl
│   └── terragrunt.hcl                <--- Global setting for the environment

```

### 3.2 Configure the workspace

Update this line in `deploy/tencentcloud/iac/workspaces/dev-ap-shanghai/terragrunt.hcl` to set a unique prefix

```terragrunt
  // Naming Convention
  prefix = "xxxxx"
```

### 3.3 run in one command

```bash  
$ cd dev-ap-shanghai/integration
$ terragrunt run-all apply
```

### 3.4 deploy app2 to kubernetes

```bash 
$ kubectl --kubeconfig dev-ap-shanghai/generated/kubeconfig apply -k dev-ap-shanghai/generated/app2

```

## 4. Teardown

```bash 
$ kubectl --kubeconfig dev-ap-shanghai/generated/kubeconfig delete -k dev-ap-shanghai/generated/app2
$ cd dev-ap-shanghai/integration
$ terragrunt run-all destroy
```

