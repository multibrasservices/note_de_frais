# Note de Frais Kilométriques

Ce projet est une application web simple (HTML/JS/CSS) permettant de générer et d'imprimer des notes de frais kilométriques.

## Fonctionnalités

- Sélection de la société (multi-sociétés configurables)
- Saisie des informations du bénéficiaire et du véhicule
- Tableau dynamique des trajets (ajout/suppression de lignes)
- Calcul automatique des totaux et du montant à rembourser
- Mise en page optimisée pour l'impression A4

## Installation et Utilisation

Il s'agit d'une application statique. Vous n'avez pas besoin de serveur backend.

1. Clonez ce dépôt ou téléchargez les fichiers.
2. Ouvrez le fichier `note_frais.html` dans votre navigateur web préféré.
3. Remplissez les informations.
4. Cliquez sur le bouton "Imprimer / PDF" pour générer le document final.

## Déploiement sur GitHub Pages

Pour rendre cette page accessible en ligne via GitHub :

1. Créez un nouveau dépôt sur GitHub.
2. Poussez les fichiers de ce projet (`note_frais.html`, dossier `images`, etc.) sur le dépôt.
3. Allez dans les **Settings** du dépôt.
4. Dans la section **Pages** (menu de gauche) :
   - Sous **Source**, sélectionnez `Deploy from a branch`.
   - Sous **Branch**, choisissez `main` (ou `master`) et le dossier `/root`.
   - Cliquez sur **Save**.
5. Votre site sera accessible à l'adresse : [https://multibrasservices.github.io/note_de_frais/](https://multibrasservices.github.io/note_de_frais/)

## Personnalisation

Vous pouvez modifier la liste des sociétés directement dans le code Javascript en bas du fichier `note_frais.html` :

```javascript
const societes = [
    {
        nom: "MA SOCIETE",
        adresse: "Mon Adresse...",
        siret: "MON SIRET"
    },
    // ...
];
```
