# Visualisation

#### Avoir des couleurs dans certaines cases d'un tableau
```xml
<panel>
      <title>Ticketing - Détails</title>
      <table>
        <search base="invisible_sistats_tickets_analysis">
          <query>| stats latest(ticket_time) as date_creation latest(ticket_libelle) as objet latest(nature_intervention) as nature latest(modif_time) as modif_time latest(cloture_time) as cloture_time max(temps_passe_total) as temps_passe latest(cloture_timestamp) as delai latest(incident_type) as incident_type latest(gravite) as gravite latest(gtr) as estGTR by  id_ticket 

| sort + id_ticket 
| fields id_ticket, date_creation, objet, modif_time, cloture_time, delai, estGTR, temps_passe incident_type gravite
| eval _time_ouverture=strptime(date_creation,"%Y-%m-%d %H:%M:%S.%3N"), delai=tostring(round(delai),"duration"),
    temps_passe=tostring(round(temps_passe),"duration")
| rename id_ticket as "N°Ticket"
          date_creation as "Saisie le"
          objet as Objet
          modif_time as "Modifié le" 
          cloture_time as "Clôturé le"
          delai as "Durée traitement"
          estGTR as GTR
          temps_passe as "Temps passé"</query>
        </search>
        <option name="count">25</option>
        <option name="drilldown">cell</option>
        <option name="refresh.display">progressbar</option>
        <option name="wrap">false</option>
        <format type="color" field="gravite">
          <colorPalette type="sharedList"></colorPalette>
          <scale type="sharedCategory"></scale>
        </format>
        <format type="color" field="incident_type">
          <colorPalette type="sharedList"></colorPalette>
          <scale type="sharedCategory"></scale>
        </format>
      </table>
    </panel>
```
