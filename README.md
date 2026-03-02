# 🧯 Serious Game: Brandschutz-Simulator

Ein interaktives 3D-Lernspiel, entwickelt mit **Godot 4**. Dieses Projekt bringt dem Spieler die 7 wichtigsten Brandschutzregeln durch praktisches Gameplay und interaktive Rätsel bei. Anstatt trockene Theorie zu lesen, muss der Spieler hier in einer simulierten Umgebung Brände richtig einschätzen und bekämpfen.

 *(Tipp: Ersetze diesen Text später durch einen echten Screenshot deines Spiels!)*

## 🎮 Features & Die 7 Brandschutzregeln

Das Spiel ist in 7 Level unterteilt, die jeweils eine spezifische Regel behandeln:

1. **🌬️ Windrichtung beachten:** Sprühe niemals gegen den Wind, sonst wird dir die Sicht durch den zurückschlagenden Löschschaum ("Blowback") genommen.
2. **🔥 Flächenbrände von vorn nach hinten löschen:** Berühre nicht das Feuer! Du musst dich strategisch vorarbeiten, ohne in die heiße Zone zu treten.
3. **💧 Tropfbrände von oben nach unten löschen:** Ein Feuer an der Decke entzündet den Boden immer wieder neu. Die Quelle muss zuerst gelöscht werden.
4. **🧱 Wandbrände von unten nach oben löschen:** Das Feuer klettert physikalisch die Wand hinauf. Starte unten und arbeite dich nach oben.
5. **🤝 Ausreichend Feuerlöscher einsetzen:** Manche Brände sind zu groß für einen allein. Nutze Hilfsmittel wie automatische Sprinkleranlagen, um Boss-Feuer im Teamwork zu besiegen.
6. **⏳ Auf Rückzündung achten:** Ein gelöschtes Feuer ist noch extrem heiß. Wer nicht ausreichend nachkühlt, erlebt eine gefährliche Rückzündung aus der unsichtbaren Glut.
7. **🛠️ Leere Feuerlöscher zur Wartung bringen:** Ein leerer Löscher darf niemals zurück an den Wandhaken gehängt werden. Der Spieler muss am Ende die richtige Entscheidung zur Entsorgung treffen.

## 🛠️ Technologie & Assets

* **Engine:** [Godot Engine 4.x](https://godotengine.org/)
* **Sprache:** GDScript
* **3D-Assets:** [Kenney Space Kit](https://kenney.nl/) (für das Level-Design via GridMap)
* **Kamera:** First-Person-Controller mit Raycast-basiertem Partikel-Löschsystem.

## 🕹️ Steuerung

* **W, A, S, D:** Bewegen
* **Maus:** Umsehen
* **Leertaste:** Springen
* **Linke Maustaste (Halten):** Feuerlöscher benutzen

## 🚀 Installation & Starten des Projekts

Um dieses Projekt lokal auszuführen oder daran weiterzuarbeiten:

1. Lade dir **Godot 4** (Version 4.x) von der offiziellen Website herunter.
2. Klone dieses Repository:
   ```bash
   git clone [https://github.com/DEIN_USERNAME/brandschutz-simulator.git](https://github.com/DEIN_USERNAME/brandschutz-simulator.git)
