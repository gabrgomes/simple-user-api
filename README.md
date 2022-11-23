# simple-user-api showcase
This is a project created to showcase a simple python api running on AWS using ECS. The app implement api calls to upsert and get users to a MongoDB database. This is by no means intended for production usage.

The project is publicly available on https://github.com/gabrgomes/simple-user-api

## TODO
- [x] App
- [x] Dockerfile
- [x] Docker compose
- [x] Deploy AWS
- [x] HA
- [ ] Monitoring

## Simplified architecture
```mermaid
flowchart TB;
lb{Applicaton LB}
subgraph cluster-app
App1 & App2 & App3
end
subgraph service-discovery
sd(mongo.app_zone)
end
subgraph cluster-db
db[(MongoDB)]
end
lb -.-> App1 & App2 & App3
App1 & App2 & App3 --> sd
sd -.- db
```
## Running locally
Requirements:
- docker >= 20.10.18
  
```shell
# run containers on background
docker compose up -d

# Api doc will be available on http://localhost:8000/docs

# stop the containers
docker compose down
```

## Running on AWS
Requirements:
- aws credentials configured [ref](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- terraform >= 1.3.2

```shell
# enter terraform directory
cd terraform

# see the modifications 
terraform plan

# provision application resources
terraform apply

# Api doc url will be shown on the output var app_url

# remove application resources
terraform destroy
```
### Variables
| var | default  | description |
|---|---|---|
| region_name  | us-east-1  | AWS region name  |
|  app_name |  simple-user-api |  Name of the application to be used to create resources. |
|  app_image | public.ecr.aws/f9q5q0t9/simple-user-api:latest  | Application image url |
|  db_container_port |  27017 | MongoDB port |

### Considerations
For simplicity this project has some questionable choices that should be mentioned:
- The terraform module provision all resources on the default VPC.
- The database is implemented as simple MongoDB instance without authentication and persistence.
- The containers in ECS are configured with public IP adresses to allow image pull from public repositories. Ideally you could use private repos on ECR with the necessary security group configurations or use NAT for outgoing connections to the internet.


## Monitoring 
![image](https://user-images.githubusercontent.com/8647236/203460099-c0187f4f-a0b8-4f28-975d-9f1b370aeb35.png)
