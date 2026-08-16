@'

\# Troubleshooting Guide



Ovaj dokument opisuje probleme koji su se pojavili tijekom razvoja i deploymenta projekta te njihova rješenja.



\## OpenShift login istekao



\### Problem



oc naredbe vraćaju:



the server has asked for the client to provide credentials



\### Rješenje



oc login -u developer -p developer https://api.ocp4.example.com:6443



\---



\## Registry authentication required



\### Problem



podman push vraća:



authentication required



\### Rješenje



Ponovno se prijaviti u registry:



podman login registry.ocp4.example.com:8443



Nakon prijave ponoviti podman push.



\---



\## OpenShift Route nije dostupan iz Windows preglednika



\### Problem



Windows preglednik nije mogao razriješiti OpenShift adrese oblika:



\*.apps.ocp4.example.com



\### Rješenje



Aplikacija je otvorena i testirana u Firefoxu unutar Red Hat virtualne mašine.



\---



\## Redis permission denied



\### Problem



Redis je pokušavao zapisivati u /data i javljao:



Permission denied

Background saving error



\### Rješenje



Redis je konfiguriran da koristi /tmp:



args:

&#x20; - redis-server

&#x20; - --dir

&#x20; - /tmp



Nakon izmjene Redis se normalno pokrenuo bez permission grešaka.



\---



\## API readiness probe vraća 503



\### Problem



Novi API pod može privremeno biti 0/1 jer /readyz vraća HTTP 503.



\### Objašnjenje



API readiness provjera ovisi o dostupnosti Redis i PostgreSQL servisa.



OpenShift ne šalje promet novom podu dok readiness provjera ne prođe. Time se izbjegava slanje prometa podu koji još nije spreman.



\---



\## PostgreSQL persistent volume i rolling update



\### Problem



PostgreSQL koristi RWO persistent volume pa dva PostgreSQL poda ne bi trebala istodobno koristiti isti volume.



\### Rješenje



PostgreSQL Deployment koristi:



strategy:

&#x20; type: Recreate



Time se stari pod uklanja prije pokretanja novoga.



\---



\## Worker izgubi Redis vezu



\### Problem



Tijekom restarta Redisa worker može prijaviti:



Redis error: Socket closed unexpectedly

Worker loop error: Socket closed unexpectedly



\### Rješenje



Worker se ponovno povezuje na Redis i nastavlja rad.



Uspješna obrada potvrđena je porukom:



Order processed



\---



\## Hot reload nije radio s node --watch



\### Problem



Promjene datoteka s Windows bind mounta bile su vidljive u containeru, ali node --watch nije automatski ponovno pokretao aplikaciju.



\### Rješenje



Za development imageove koristi se nodemon s polling načinom:



nodemon -L



Nakon promjene koda log prikazuje:



\[nodemon] restarting due to changes...



Hot reload je potvrđen za API, frontend i worker.



\---



\## Pogrešna NetworkPolicy naredba



\### Problem



Pogrešno je uneseno:



oc get network policy



OpenShift je zato pokušao dohvatiti drugi resurs i vratio permission grešku.



\### Rješenje



Ispravna naredba je:



oc get networkpolicy



networkpolicy se piše kao jedna riječ.



\---



\## Trivy HIGH i CRITICAL nalazi



\### Problem



Početno Trivy skeniranje pronašlo je:



HIGH: 7

CRITICAL: 1



\### Rješenje



Production runtime imageovi su smanjeni i iz njih su uklonjeni nepotrebni npm alati.



Nakon izmjena API, frontend i worker prošli su Trivy security gate bez HIGH i CRITICAL nalaza.



\---



\## OpenShift provjera



Provjera podova:



oc get pods



API logovi:



oc logs deploy/ticketing-api



Frontend logovi:



oc logs deploy/ticketing-frontend



Worker logovi:



oc logs deploy/ticketing-worker



Detaljna analiza poda:



oc describe pod POD\_NAME



\---



\## Lokalna provjera



Provjera containera:



podman compose ps



API logovi:



podman logs ticketing-api



Frontend logovi:



podman logs ticketing-frontend



Worker logovi:



podman logs ticketing-worker



