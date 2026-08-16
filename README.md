# Secure Event Ticketing Platform

Projekt za kolegij **Uvod u DevOps - DevSecOps**.

Aplikacija demonstrira lokalni razvoj pomoću Podmana i Composea, deployment na OpenShift te osnovne DevSecOps sigurnosne prakse i CI pipeline.

## Arhitektura

Aplikacija se sastoji od pet servisa:

- `frontend` - web sučelje za pregled događaja i kupnju karata
- `api` - REST API za događaje, narudžbe i health provjere
- `worker` - obrađuje narudžbe iz Redis reda
- `redis` - red poruka između API-ja i workera
- `postgres` - trajna pohrana narudžbi

Tok zahtjeva:

```text
Frontend -> API -> Redis -> Worker -> PostgreSQL
```

## Lokalno pokretanje

### 1. Konfiguracija

Napraviti lokalnu `.env` datoteku prema primjeru:

```text
.env.example
```

Datoteka `.env` nije spremljena u Git repozitorij.

### 2. PostgreSQL volume

Prije prvog pokretanja potrebno je napraviti persistent volume:

```bash
podman volume create ticketing-postgres-data
```

### 3. Development imageovi

Za lokalni razvoj koriste se posebni development Containerfileovi:

```bash
podman build -f api/Containerfile.dev -t ticketing-api:dev api
podman build -f frontend/Containerfile.dev -t ticketing-frontend:dev frontend
podman build -f worker/Containerfile.dev -t ticketing-worker:dev worker
```

### 4. Pokretanje aplikacije

```bash
podman compose up -d
```

Provjera containera:

```bash
podman compose ps
```

Frontend je dostupan na:

```text
http://localhost:3000
```

API je dostupan na:

```text
http://localhost:8080
```

Za zaustavljanje aplikacije:

```bash
podman compose down
```

## Hot reload

API, frontend i worker koriste `nodemon` u development imageovima.

Izvorni `src` direktoriji montirani su u containere kroz Compose, pa se nakon spremanja promjene u kodu servis automatski ponovno pokreće bez ponovnog buildanja imagea.

Primjer poruke u logu:

```text
[nodemon] restarting due to changes...
```

## Brza validacija funkcionalnosti

### Health API

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/readyz
```

### Dohvat događaja

```bash
curl http://localhost:8080/events
```

### Kupnja karte

```bash
curl -X POST http://localhost:8080/tickets/purchase \
  -H "Content-Type: application/json" \
  -d '{"eventId":"evt-1001","customerEmail":"student@example.com","quantity":2}'
```

### Provjera obrađenih narudžbi

```bash
curl http://localhost:8080/tickets/orders
```

## OpenShift deployment

Kubernetes/OpenShift manifesti nalaze se u direktoriju:

```text
k8s/
```

Projekt koristi:

- Deployment
- Service
- Route
- ConfigMap
- Secret
- PersistentVolumeClaim
- NetworkPolicy
- ServiceAccount
- Role
- RoleBinding

Primjena manifesta izvodi se naredbom:

```bash
oc apply -f k8s/
```

Provjera podova:

```bash
oc get pods
```

Očekivani servisi:

```text
ticketing-frontend
ticketing-api
ticketing-worker
redis
postgres
```

Aplikacijski imageovi koriste verzionirane tagove umjesto `latest` taga.

## Health i resource management

Frontend i API koriste HTTP health probeove.

Redis i PostgreSQL koriste izvršne health provjere.

Deployment manifesti također definiraju CPU i memory `requests` i `limits`.

API readiness provjera dodatno provjerava dostupnost Redis i PostgreSQL servisa.

## Persistent storage

PostgreSQL koristi PersistentVolumeClaim kako bi podaci ostali sačuvani nakon ponovnog kreiranja PostgreSQL poda.

Za PostgreSQL Deployment koristi se strategija:

```text
Recreate
```

jer baza koristi persistent storage.

## Network security

NetworkPolicy pravilima ograničen je pristup Redis i PostgreSQL servisima.

Redis i PostgreSQL nisu namijenjeni izravnom pristupu korisnika.

Aplikacijski promet slijedi arhitekturu:

```text
Frontend -> API -> Redis -> Worker -> PostgreSQL
```

## RBAC

Projekt koristi princip najmanjih privilegija.

Definirani su:

- ServiceAccount `ticketing-viewer`
- Role `ticketing-readonly`
- RoleBinding `ticketing-readonly-binding`

Role omogućuje samo read-only pristup potrebnim resursima.

## CI pipeline

GitHub Actions workflow nalazi se u:

```text
.github/workflows/ci.yml
```

Workflow se pokreće na:

- push na `main`
- pull request prema `main`

Pipeline:

```text
Checkout repository
        |
Build API image
        |
Build frontend image
        |
Build worker image
        |
Trivy scan API
        |
Trivy scan frontend
        |
Trivy scan worker
```

## Security scanning

Container imageovi skeniraju se pomoću Trivy alata.

CI provjerava:

```text
HIGH
CRITICAL
```

ranjivosti.

Ako se pronađe HIGH ili CRITICAL ranjivost, CI završava greškom.

Produkcijski imageovi koriste multi-stage build, non-root korisnika i ne sadrže nepotrebne development alate poput npm-a u runtime sloju.

Detalji skeniranja:

```text
docs/security/image-scan-report.md
```

## Rolling update i rollback

OpenShift Deployment omogućuje kontrolirano ažuriranje aplikacijskih imageova.

Primjer provjere rollouta:

```bash
oc rollout status deployment/ticketing-api
```

Rollback:

```bash
oc rollout undo deployment/ticketing-api
```

## Troubleshooting

Provjera lokalnih containera:

```bash
podman compose ps
```

Pregled logova containera:

```bash
podman logs ticketing-api
podman logs ticketing-frontend
podman logs ticketing-worker
```

Provjera OpenShift podova:

```bash
oc get pods
```

Pregled logova:

```bash
oc logs deploy/ticketing-api
oc logs deploy/ticketing-frontend
oc logs deploy/ticketing-worker
```

Detaljna provjera problema s podom:

```bash
oc describe pod POD_NAME
```

## DevSecOps elementi projekta

Projekt demonstrira:

- containerizaciju aplikacije
- multi-stage Containerfileove
- non-root runtime
- lokalni Compose deployment
- hot reload za lokalni razvoj
- odvojene mreže između servisa
- health checkove
- persistent storage
- Kubernetes/OpenShift Deployment, Service i Route resurse
- ConfigMap i Secret konfiguraciju
- readiness i liveness probeove
- CPU i memory requests/limits
- NetworkPolicy segmentaciju
- RBAC i least privilege
- verzioniranje container imageova
- rolling update i rollback
- GitHub Actions CI
- Trivy security scanning
- security gate za HIGH i CRITICAL ranjivosti