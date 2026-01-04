# Reel Calendar

Reel Calendar est un **package Flutter de calendrier** (Day / Week / Month) conçu initialement pour un usage **interne**, mais avec une **API propre et maîtrisée**, afin de pouvoir évoluer vers une version publiable ultérieurement.

Ce package met l’accent sur :

- un **contrôle total du layout**
- une **architecture explicite**
- aucune logique métier interne
- aucune magie cachée

---

## ⚠️ Statut du package

> **Statut actuel : usage interne (semi-public)**

- ❌ Pas encore personnalisable (thèmes, builders, styles)
- ❌ Pas destiné à être publié sur pub.dev pour le moment
- ✅ API stable et volontairement minimaliste
- ✅ Pensé pour évoluer vers une V2 plus générique

---

## 🎯 Philosophie

Reel Calendar est :

- **piloté de l’extérieur**
- **opinionated**
- **prévisible**
- **sans dépendance applicative**

Ce package **n’a aucune connaissance** :

- de ton backend
- de ta base de données
- de ton state management
- de ta logique métier

👉 Il **affiche** ce qu’on lui donne, rien de plus.

---

## 🧱 Architecture globale

```
reel_calendar/
├── controllers/
│   ├── calendar_controller.dart
│   └── event_controller.dart
│
├── views/
│   ├── day_view.dart
│   ├── week_view.dart
│   └── month_view.dart
│
├── models/
│   └── reel_calendar_event.dart
│
└── reel_calendar.dart
```

---

## 🧠 Concepts clés

### CalendarController

Responsable de :

- la vue courante (day / week / month)
- la date focalisée
- la navigation temporelle

👉 **Un seul controller pour piloter le calendrier.**

---

### ReelCalendarEventController

Responsable de :

- stocker les événements
- fournir les occurrences aux vues
- notifier les mises à jour

👉 **Aucune récupération réseau ici.**

---

### Views

- `DayView` : vue journalière (grille horaire)
- `WeekView` : vue hebdomadaire (events positionnés par minute)
- `MonthView` : vue mensuelle (grille + empilement)

Chaque vue :

- est purement visuelle
- dépend uniquement des controllers

---

## 🔌 Installation (via Git)

### Dépendance Git (repo privé ou public)

```yaml
dependencies:
  reel_calendar:
    git:
      url: git@github.com:YOUR_ORG/reel_calendar.git
      ref: main
```

> ⚠️ Le repo peut être **privé** (recommandé).
> Assurez-vous que l’accès SSH ou le token Git est configuré.

---

## 🚀 Utilisation de base

### 1️⃣ Créer les controllers

```dart
final calendarController = CalendarController();
final eventController = ReelCalendarEventController();
```

---

### 2️⃣ Fournir les événements

```dart
eventController.setEvents([
  ReelCalendarEvent(
    id: '1',
    title: 'Meeting',
    start: DateTime(2026, 1, 4, 10),
    end: DateTime(2026, 1, 4, 11),
  ),
]);
```

---

### 3️⃣ Utiliser le widget principal

```dart
ReelCalendar(
  calendarController: calendarController,
  eventController: eventController,
)
```

---

## 🔄 Changer de vue

```dart
calendarController.setView(CalendarView.week);
calendarController.setView(CalendarView.month);
calendarController.setView(CalendarView.day);
```

---

## 📅 Navigation temporelle

```dart
calendarController.goToNext();
calendarController.goToPrevious();
calendarController.goTo(DateTime.now());
```

---

## ❌ Ce que le package ne fait PAS

- ❌ Pas de fetch réseau
- ❌ Pas de pagination
- ❌ Pas de cache
- ❌ Pas de thème dynamique
- ❌ Pas de logique métier

👉 Tout cela **doit rester dans l’application**.

---

## ✅ Bonnes pratiques

- Charger les événements **depuis l’app**
- Mettre à jour le `EventController` quand les données changent
- Ne PAS surcharger le package avec du métier
- Considérer le package comme une **lib UI spécialisée**

---

## 🔮 Évolution prévue (V2)

- Thématisation
- Custom builders
- Callbacks avancés
- API plus générique

⚠️ Ces fonctionnalités **ne font PAS partie de la V1**.

---

## 📄 Licence

À définir (usage interne pour le moment).

---

## 🧾 Conclusion

Reel Calendar est un **outil robuste, maîtrisé et volontairement minimal**, conçu pour des applications qui exigent :

- un contrôle précis du rendu
- une logique claire
- une séparation stricte UI / métier

Il est actuellement utilisé comme **package interne**, mais a été conçu pour pouvoir évoluer vers une solution publiable sans refonte majeure.
