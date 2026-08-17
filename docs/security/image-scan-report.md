# Container Image Security Scan Report

## Alat

Za sigurnosno skeniranje container imageova korišten je Trivy unutar GitHub Actions CI pipelinea.

Skeniraju se tri aplikacijska imagea:

- ticketing-api
- ticketing-frontend
- ticketing-worker

CI provjerava ranjivosti razina:

- HIGH
- CRITICAL

## Početni rezultat

Prvo Trivy skeniranje pokazalo je ranjivosti povezane s Node.js/npm paketima koji su ostali u runtime imageu.

Rezultat je uključivao:

- HIGH: 7
- CRITICAL: 1

## Sigurnosni hardening

Nakon analize rezultata uklonjene su nepotrebne npm i npx komponente iz produkcijskih runtime imageova.

Aplikacije se u produkcijskim containerima pokreću izravno pomoću Node.js procesa i koriste non-root korisnika.

GitHub Actions konfiguriran je tako da HIGH ili CRITICAL ranjivost uzrokuje neuspjeh CI workflowa.

## Završni rezultat

Nakon sigurnosnog hardeninga produkcijski container imageovi ponovno su izgrađeni i skenirani pomoću Trivy alata.

Završni rezultat skeniranja:

| Image | HIGH | CRITICAL |
|---|---:|---:|
| ticketing-api | 0 | 0 |
| ticketing-frontend | 0 | 0 |
| ticketing-worker | 0 | 0 |

Nakon uklanjanja nepotrebnih npm i npx komponenti iz runtime imageova više nisu pronađene HIGH ni CRITICAL ranjivosti. GitHub Actions CI workflow nakon izmjena završava uspješno.

Ovaj rezultat pokazuje da je sigurnosni problem pronađen skeniranjem, analiziran i uklonjen prije završne verzije produkcijskih imageova.
