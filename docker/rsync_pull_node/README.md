# rsync_pull_node

Rassemble les données des Docker nodes dans un dossier central du NAS pour que [ZeroByte](https://zerobyte.app/) puisse effectuer son backup.

## Comment ça marche

1. **Le cron** dans le conteneur `eeacms/rsync` exécute `sync_nodes.sh` tous les jours à 3h du mat
2. **Pour chaque node**, le script :
   - Utilise `docker ps -a` avec les labels Docker Compose pour récupérer directement le chemin du projet de chaque conteneur
   - Déduplique les chemins (ex: `excalidash_backend`, `excalidash_postgres` → un seul `/home/norbert/docker/excalidash`)
3. **Rsync** synchronise chaque dossier unique du node vers le NAS (`--delete` assure un miroir exact)
4. **ZeroByte** backup le dossier `/volume2/Users/norbert/docker/` sur le NAS

## Architecture

```
Node1 (10.0.10.5)                    NAS (10.0.10.2)
/home/norbert/docker/forgejo/  ──→   /volume2/Users/norbert/docker_test/forgejo/
/home/norbert/docker/mailserver/ ──→  /volume2/Users/norbert/docker_test/mailserver/
              ...                                ...
                                              ↓
                                      ZeroByte backup
```

## Configuration requise sur chaque node

Avant d'ajouter un node, configurer **chaque serveur** :

### 1. SSH - Clé d'accès

```bash
# Sur le NAS, copier la clé vers le node
ssh-copy-id norbert@10.0.10.X

# Vérifier l'accès sans mot de passe
ssh norbert@10.0.10.X "echo OK"
```

### 2. Sudoers - Rsync en root

```bash
# Sur le node : éditer sudoers
sudo visudo

# Ajouter cette ligne (permet à norbert de lancer rsync en root sans mot de passe)
norbert ALL=(root) NOPASSWD: /usr/bin/rsync
```

**Pourquoi ?** Les fichiers Docker appartiennent à `root` ou `postgres`. Sans sudo, rsync ne peut pas les lire.

### 3. Docker - Accès sudo

```bash
# Sur le node : ajouter norbert au groupe docker
sudo usermod -aG docker norbert

# Ou utiliser sudo docker (déjà configuré dans le script)
```

### 4. Vérification

```bash
# Tester l'accès complet depuis le NAS
ssh norbert@10.0.10.X "sudo docker ps -a --format '{{.Names}}'"
ssh norbert@10.10.X "sudo rsync --version"
```

### 5. Ajouter le node

```bash
# Dans .env sur le NAS, ajouter l'IP
NODES="norbert@10.0.10.5 norbert@10.0.10.6 norbert@10.0.10.7"

# Redémarrer le conteneur
docker compose restart
```

## Variables d'environnement (`.env`)

| Variable | Description | Exemple |
|---|---|---|
| `NODES` | Liste des nodes à synchroniser (user@ip) | `"norbert@10.0.10.5 norbert@10.0.10.6"` |
| `DOCKER_DIR` | Chemin de mount dans le conteneur | `/source/docker` |
| `DOCKER_SOURCE` | Dossier sur le NAS à remplir | `/volume2/Users/norbert/docker` |
| `BLACKLIST` | Chemin vers le fichier de blacklisting | `${DOCKER_DIR}/.blacklist` |

## Blacklist

Un conteneur par ligne dans `.blacklist`. Les conteneurs listés sont ignorés par le script.

## Conteneurs non-gérés par Docker Compose

Si un conteneur a été lancé avec `docker run` (sans `docker compose`), il n'a pas le label `com.docker.compose.project.working_dir` et sera ignoré avec un message `WARN`. C'est le comportement attendu pour les conteneurs éphémères ou gérés automatiquement.

## Dépannage

```bash
# Vérifier les permissions SSH après un restart
docker exec rsync_pull_node chmod 600 /root/.ssh/id_rsa

# Exécuter manuellement le script
docker exec rsync_pull_node /scripts/sync_nodes.sh

# Voir les logs du conteneur
docker logs rsync_pull_node
```

## Évolutions prévues

### Notifications (ntfy)

Ajouter des notifications push via [ntfy](https://ntfy.sh/) pour alerter en cas de succès ou d'erreur :

```bash
# En cas d'erreur
curl -d "❌ Rsync échoué sur ${NODE_IP}" ntfy.sh/rsync-alerts

# En cas de succès
curl -d "✅ Rsync terminé - ${COUNT} projets sync" ntfy.sh/rsync-alerts
```

**Configuration requise :**
- Ajouter `NTFY_TOPIC` dans `.env`
- Ajouter le hook de notification à la fin du script `sync_nodes.sh`
- Le conteneur doit avoir accès à internet (ou URL ntfy self-hosted)
