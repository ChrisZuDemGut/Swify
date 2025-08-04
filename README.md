# Swify

Eine iOS-App für die native Fotogalerie, mit der Nutzer*innen ihre Bilder durch Wischen („Swipe") sichten, sortieren und löschen können.

## Features

### 🖼️ Integration mit der iOS-Fotogalerie
- Vollständiger Zugriff auf die lokal gespeicherten Bilder der Fotos-App
- Änderungen (Löschen, Favorisieren) werden direkt und synchron in die Systemgalerie übernommen
- Unterstützung für alle Bildformate der iOS-Fotogalerie

### 👆 Swipe-basierte Foto-Navigation
- Fotos werden im Vollbild angezeigt mit flüssigen Animationen
- **Links-Swipe** = Löschen
- **Rechts-Swipe** = Behalten/Favorisieren
- Undo-Funktion für die letzten zwei Aktionen
- Visuelles Feedback während des Swipens

### ⭐ Favoritenfunktion
- Bilder können als Favorit markiert werden
- Synchronisation mit dem iOS-Foto-Favoritenstatus
- Separate Ansicht nur für Favoriten

### 📂 Sortieroptionen
- **Zufällige Reihenfolge**: Für überraschende Entdeckungen
- **Chronologisch**: Nach Aufnahmedatum (neueste zuerst)
- **Nur Favoriten**: Zeigt nur bereits favorisierte Fotos
- Tracking bereits gesichteter Bilder (keine Dopplungen)

### 🎨 Benutzeroberfläche
- Minimalistisches, modernes Design
- Apples „Liquid Glass"-Stil mit transparenten Layern
- Weiche Animationen und helle Farben
- Optimiert für iOS 16+

### 💾 Verlauf & Fortschritt
- Automatische Speicherung des Fortschritts
- iCloud-Sync für Synchronisation zwischen Geräten
- Statistische Auswertung (bewertete Fotos, Löschrate, etc.)
- Fortsetzung an der zuletzt angesehenen Position

## Technische Details

- **Sprache**: Swift 5.0
- **Framework**: SwiftUI
- **iOS Version**: 16.0+
- **Berechtigungen**: Foto-Bibliothek Lese-/Schreibzugriff
- **Architektur**: MVVM mit ObservableObject

## Projektstruktur

```
Swify/
├── SwifyApp.swift          # App-Einstiegspunkt
├── ContentView.swift       # Hauptansicht mit Navigation
├── PhotoDetailView.swift   # Vollbild-Foto-Ansicht mit Swipe-Funktionalität
├── PhotoCard.swift         # Einzelne Foto-Karte mit Metadaten
├── SortingOptionsView.swift # Sortierungsoptionen
├── PhotoManager.swift      # Foto-Verwaltung und PhotoKit-Integration
├── ProgressManager.swift   # Fortschritt und iCloud-Sync
└── Assets.xcassets/       # App-Icons und Ressourcen
```

## Installation

1. Öffnen Sie `Swify.xcodeproj` in Xcode 15 oder neuer
2. Wählen Sie Ihr Entwicklerteam in den Projekteinstellungen
3. Stellen Sie sicher, dass ein iOS-Gerät mit iOS 16+ angeschlossen ist
4. Bauen und starten Sie die App

## Verwendung

1. **Berechtigung gewähren**: Beim ersten Start Foto-Zugriff erlauben
2. **Sortierung wählen**: Über das Sortier-Icon die gewünschte Ansicht auswählen
3. **Swipen**: 
   - Nach rechts wischen = Foto behalten/favorisieren
   - Nach links wischen = Foto löschen
4. **Rückgängig machen**: Über den Undo-Button die letzten Aktionen widerrufen
5. **Fortschritt verfolgen**: Der Zähler zeigt den aktuellen Fortschritt

## Datenschutz

- Die App greift nur auf Ihre lokalen Fotos zu
- Keine Datenübertragung an externe Server
- iCloud-Sync nutzt Ihren privaten iCloud-Speicher
- Alle Änderungen erfolgen direkt in Ihrer Foto-Bibliothek

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert.