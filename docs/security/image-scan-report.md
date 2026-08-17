\# Container Image Security Scan Report



\## Alat



Za sigurnosno skeniranje container imageova korišten je \*\*Trivy\*\* unutar GitHub Actions CI pipelinea.



Skeniraju se tri aplikacijska imagea:



\- `ticketing-api`

\- `ticketing-frontend`

\- `ticketing-worker`



CI provjerava ranjivosti razina:



\- HIGH

\- CRITICAL



\## Početni rezultat



Prvo Trivy skeniranje pokazalo je ranjivosti povezane s Node.js/npm paketima koji su ostali u runtime imageu.



Rezultat je uključivao:



```text

HIGH: 7

CRITICAL: 1

```
## Zavr ni rezultat

Nakon sigurnosnog hardeninga produkcijski container imageovi ponovno su izgra eni i skenirani pomo u Trivy alata.

Zavr ni rezultat skeniranja:

| Image | HIGH | CRITICAL |
|---|---:|---:|
| ticketing-api | 0 | 0 |
| ticketing-frontend | 0 | 0 |
| ticketing-worker | 0 | 0 |

Nakon uklanjanja nepotrebnih npm i npx komponenti iz runtime imageova vi e nisu prona ene HIGH ni CRITICAL ranjivosti. GitHub Actions CI workflow nakon izmjena zavr ava uspje no.

Ovaj rezultat pokazuje da je sigurnosni problem prona en skeniranjem, analiziran i uklonjen prije zavr ne verzije produkcijskih imageova.
