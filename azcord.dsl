workspace "AzCord" "Architecture de la stack self-hosted AzCord (Revolt/Stoat v0.11.1)" {

  !identifiers hierarchical

  model {

    utilisateur = person "Utilisateur" "Client web ou mobile de l'instance AzCord"

    azcord = softwareSystem "AzCord" "Plateforme de messagerie instantanée self-hosted basée sur Revolt/Stoat" {

      caddy = container "caddy" "Reverse proxy HTTPS avec TLS automatique (ACME). Route les requêtes entrantes par préfixe de chemin vers les services backend." "Caddy 2" {
        tags "Proxy"
      }

      cloudflared = container "cloudflared" "[Optionnel] Tunnel Cloudflare Zero Trust. Expose la stack sans ouvrir de port pare-feu. Config: cloudflared/config.yml." "cloudflare/cloudflared" {
        tags "Optional"
      }

      web = container "web" "Single Page Application React (for-web). Interface utilisateur AzCord. Port interne: 5000." "React / Nginx" {
        tags "Frontend"
      }

      api = container "api" "API REST principale Stoat v0.11.1. Gère les comptes, canaux, messages, permissions. Port interne: 14702. Route Caddy: /api/*" "Rust" {
        tags "Backend"
      }

      events = container "events" "Service WebSocket temps-réel. Diffuse les événements (messages, présence) aux clients connectés. Port interne: 14703. Route Caddy: /ws" "Rust" {
        tags "Backend"
      }

      autumn = container "autumn" "Serveur de fichiers et médias. Upload/download via MinIO. Port interne: 14704. Route Caddy: /autumn/*" "Rust" {
        tags "Backend"
      }

      january = container "january" "Proxy de métadonnées et prévisualisation de liens externes. Port interne: 14705. Route Caddy: /january/*" "Rust" {
        tags "Backend"
      }

      gifbox = container "gifbox" "Proxy API Tenor/GIFs. Port interne: 14706. Route Caddy: /gifbox/*" "Rust" {
        tags "Backend"
      }

      pushd = container "pushd" "Daemon de notifications push mobiles. Consomme RabbitMQ. Envoie aux plateformes push (APNs, FCM)." "Rust" {
        tags "Backend"
      }

      crond = container "crond" "Daemon de tâches planifiées. Nettoyage des fichiers orphelins et maintenance périodique." "Rust" {
        tags "Backend"
      }

      voiceIngress = container "voice-ingress" "Passerelle de signalement vocal. Pont entre l'API Stoat et le SFU LiveKit. Port interne: 8500. Route Caddy: /ingress/*" "Rust" {
        tags "Backend"
      }

      createbuckets = container "createbuckets" "Job d'initialisation one-shot (minio/mc). Crée le bucket revolt-uploads dans MinIO. Prérequis pour autumn." "minio/mc" {
        tags "Job"
      }

      mongodb = container "MongoDB" "Base de données documentaire principale. Stocke messages, utilisateurs, canaux, serveurs. Volume persisté: data/db. Port: 27017." "MongoDB 7" {
        tags "Database"
      }

      keydb = container "KeyDB / Redis" "KV store et pub/sub compatible Redis. Cache de sessions, rate-limiting, diffusion temps-réel. Port: 6379." "eqalpha/keydb" {
        tags "Cache"
      }

      rabbitmq = container "RabbitMQ" "Message broker AMQP 0-9-1. Découplage des notifications push. Volume persisté: data/rabbit. Port: 5672." "RabbitMQ 4" {
        tags "MessageBroker"
      }

      minio = container "MinIO" "Stockage objet S3-compatible. Héberge les médias et pièces jointes. Volume persisté: data/minio. Alias DNS: revolt-uploads.minio." "minio/minio" {
        tags "Storage"
      }

      livekit = container "LiveKit SFU" "Selective Forwarding Unit WebRTC pour les appels vocaux/vidéo. TCP 7881 (signal), UDP 50000-50100 (media RTP). Config: livekit.yml." "stoatchat/livekit-server" {
        tags "Voice"
      }

    }

  }

  views {

    systemContext azcord "SystemContext" "Vue d'ensemble : qui utilise AzCord et comment" {
      include *
      autoLayout tb 300 100
    }

    container azcord "Containers" "Tous les services Docker Compose de la stack AzCord" {
      include *
      autoLayout tb 200 100
    }

    styles {
      element "Person" { shape person background #1a73e8 color #ffffff fontSize 14 }
      element "Software System" { background #1a73e8 color #ffffff }
      element "Container" { background #2d6a9f color #ffffff }
      element "Proxy" { background #0d6e6e color #ffffff shape roundedbox }
      element "Frontend" { background #6750a4 color #ffffff shape webbrowser }
      element "Backend" { background #1e5799 color #ffffff shape roundedbox }
      element "Database" { background #2d6a9f color #ffffff shape cylinder }
      element "Cache" { background #c95b0c color #ffffff shape cylinder }
      element "MessageBroker" { background #7b2d8b color #ffffff shape pipe }
      element "Storage" { background #1a6b3a color #ffffff shape cylinder }
      element "Voice" { background #c62828 color #ffffff shape roundedbox }
      element "Job" { background #5d4037 color #ffffff shape component }
      element "Optional" { background #546e7a color #ffffff border dashed }
    }

  }

}
