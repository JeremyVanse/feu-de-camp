# Feu de Camp

Préparation de groupe pour la sortie de **World of Warcraft: Forever** (4 novembre 2026).

Chaque ami se connecte avec Discord et choisit sa race, sa classe, son rôle et ses métiers. Le site affiche ensuite :

- **qui joue quoi** et la répartition tanks, soigneurs et DPS ;
- **ce qu'il manque au groupe** : rôle absent, factions mélangées, pas de Cuisine (donc pas de feu de camp), buff qu'aucune classe ni aucun métier n'apporte, métier de fabrication sans le métier de récolte qui va avec ;
- **le feu de camp idéal** : les objets de camp à poser en priorité (3, 5 ou 10 places) ;
- **les buffs de chaque classe** et **les buffs de camping de chaque métier**, avec le buff de classe que chacun remplace.

Site : https://jeremyvanse.github.io/feu-de-camp/

## Stack

- Page statique unique (`index.html`), servie par GitHub Pages, sans étape de build.
- [Supabase](https://supabase.com) pour la connexion Discord, la base de données et le temps réel.
- Icônes officielles du jeu dans `icons/`.

Tant que `config.js` est vide, le site tourne en **mode démo** avec des personnages d'exemple.

## Mise en service (une seule fois)

### 1. Créer le projet Supabase

1. Crée un projet gratuit sur https://supabase.com/dashboard.
2. Dans **SQL Editor**, colle le contenu de [`supabase/schema.sql`](supabase/schema.sql) puis clique sur **Run**.

### 2. Brancher la connexion Discord

1. Sur https://discord.com/developers/applications, crée une application, puis ouvre **OAuth2**.
2. Dans **Redirects**, ajoute `https://<ton-projet>.supabase.co/auth/v1/callback`. L'adresse exacte est affichée dans Supabase, sous **Authentication → Sign In / Providers → Discord**.
3. Copie le **Client ID** et le **Client Secret** de Discord dans le fournisseur Discord de Supabase, puis active-le.
4. Dans Supabase, sous **Authentication → URL Configuration** :
   - **Site URL** : `https://jeremyvanse.github.io/feu-de-camp/`
   - **Redirect URLs** : ajoute la même adresse.

### 3. Relier le site à Supabase

Dans **Project Settings → API**, copie la **Project URL** et la clé **anon public** dans `config.js`, puis pousse le changement. La clé anon est faite pour être publique : ce sont les règles RLS du schéma qui protègent les données.

### 4. Te donner les droits d'admin

Connecte-toi sur le site avec Discord et enregistre ta fiche. Lance ensuite cette requête dans le SQL Editor, avec le pseudo affiché en haut à droite du site :

```sql
insert into public.admins (user_id)
select user_id from public.roster
where not manual and display_name ilike 'TON_PSEUDO'
on conflict do nothing
returning user_id;
```

Si le résultat est vide, personne n'a été trouvé. La liste des pseudos enregistrés s'obtient avec `select display_name, user_id from public.roster where not manual;`.

L'admin peut créer, dans l'onglet « Mon perso », la fiche d'un ami qui n'a pas Discord.

## Qui peut faire quoi

| Action | Visiteur | Connecté | Admin |
| --- | --- | --- | --- |
| Consulter les buffs de classe et de camp | ✓ | ✓ | ✓ |
| Voir le groupe | | ✓ | ✓ |
| Créer, modifier ou retirer **sa** fiche | | ✓ | ✓ |
| Gérer les fiches des amis sans compte | | | ✓ |

N'importe quel compte Discord peut se connecter et ajouter sa fiche. Si le lien circule trop, désactive les inscriptions dans **Authentication → Sign In / Providers** (option « Allow new users to sign up ») une fois tout le groupe inscrit.

## Sources

- Races et classes : [tableau officiel Blizzard](https://news.blizzard.com/en-us/article/24304075/create-the-hero-you-want-to-be-in-world-of-warcraft-forever)
- Camping : [guide Icy Veins](https://www.icy-veins.com/wow-forever/camping), [Warcraft Tavern](https://www.warcrafttavern.com/forever/news/camping-profession-buffs-in-world-of-warcraft-forever/)

Les données de camping viennent de la bêta (septembre 2026) et peuvent encore changer. Icônes et marques © Blizzard Entertainment ; projet de fans sans lien avec Blizzard.
