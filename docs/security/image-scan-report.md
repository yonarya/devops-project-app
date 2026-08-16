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

