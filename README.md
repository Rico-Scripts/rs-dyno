# rs-dyno

Standalone dynotestbank die gekoppeld is aan het medewerkerssysteem van `rs-bikemechanic`.

## Installatie

1. Importeer `sql/install.sql`.
2. Start `rs-bikemechanic` vóór `rs-dyno`.
3. Pas locatie en meetwaarden aan in `config.lua`.

Alleen geregistreerde medewerkers die in dienst zijn kunnen een test uitvoeren. Start, duur, voertuig, locatie en kenteken worden server-side gevalideerd. Resultaten worden opgeslagen en naar de services-webhook gelogd.
