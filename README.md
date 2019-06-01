# terraform-mds

*1er étape :*
Créer un compte AWS GRATUIT (UE Irlande)


*2ème étape :*
Services -> S3 -> Créer un compartiment 
  - Nom et région : nom du compartiment : « solenne-bucket » ; Région : UE Irlande
  - Configurer des options : ne rien cocher, aller directement sur Suivant
  - Définir des autorisations : cocher « Bloquer tout l'accès public »
  - Dernière étape : Vérification -> Cliquer « Créer un compartiment »


*3ème étape :*
Services -> IAM -> Utilisateurs -> Créer un utilisateur
  - Nom d’utilisateur : « solenne » ; cocher « Accès par programmation »
  - Aller dans la section « Attacher directement les stratégies existantes » puis cocher AdministratorAccess
  - Balise : pour l’instant rien
  - Dernière étape : Vérification -> Créer un utilisateur
  Télécharger le *.csv* et copier/coller dans le *packer.json* et *state.tf* et le *main.tf* les clefs *access_key* et *secret_key*


*4ème étape :*
Installer packer 
`brew install packer`
aller dans le dossier `cd live/eu-west-1/database`
et lancer `packer build packer.json`


*5ème étape :*
Services -> EC2 -> AMI (Images)
  - Sélectionner l’AMI, puis cliquer sur « Lancer », sélectionner « t2 micro » (Gratuit) et cliquer sur « vérifier et lancer »
  - Etape 7 : Examiner le lancement de l’instance -> cliquer directement sur « Lancer »
  - Dans la liste déroulante, choisir « créer une nouvelle paire de clés »  et la nommer « sosoKeyStp », télécharger les clés et enfin lancer les instances.
  -  copier / coller le fichier téléchargé (sosoKeyStp.pem) dans `~/.zsh`
  - Aller dans `cd ~/.ssh` puis donner les droits `chmod 6OO sosoKeyStp.pem`
  - Exécuter `ssh-add sosoKeyStp.pem`

*6ème étape :*
Copier / coller l'ID AMI dans EC2 -> AMI dans le *main.tf* ligne 117

Lancer les instances :
`terraform init` puis
`terraform apply`

*7ème étape :*
Se connecter au SSH
Récupérer le DNS public (IPv4) dans Services -> EC2 -> Instances
`ssh ubuntu@[DNS-PUBLIC]`
- une fois connecter à l'instance via le ssh executer :
  - `mkdir config`
  - `cd config`
  - `nano config.json`
  - copier / coller le fichier suivant dans config.json en modifiant l'host par le point de terminaison de la base de donnée (RDS -> base de données cliquer sur la base en cours postgreSLQL -> puis point de terminaison (ex: terraform-20190530130404255500000001.cfx0a0gbdqnw.eu-west-1.rds.amazonaws.com))

```
{
  "server": {
    "host": "0.0.0.0",
    "port": "8080"
  },
  "options": {
    "prefix": "http://localhost:8080/"
  },
  "postgres": {
    "host": "",
    "port": "5432",
    "user": "test",
    "password": "mangermanger",
    "db": "databasesoso"
  }
}
```
Executer  `ursho`

Enfin, ouvrir un nouveau terminal et se connecter en ssh 
`ssh ubuntu@[DNS-PUBLIC]`

Executer en remplacant LOCALHOST par IP Publique IPv4 qui se trouve dans EC2 -> Instances, cliquer sur l'Instance en cours et récuper l'IP Publique IPv4  :  
`curl -H "Content-Type: application/json" -X POST -d '{"url":"www.google.com"}' http://localhost:8080/encode/`


ATTENTION : ne pas oublier de `terraform destroy` afin de ne pas être facturé par AWS
