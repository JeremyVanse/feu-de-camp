// Connexion à Supabase. Les deux valeurs se trouvent dans le tableau de bord
// Supabase : Project Settings → API (« Project URL » et clé « anon public »).
// La clé anon est faite pour être publique : ce sont les règles RLS de
// supabase/schema.sql qui protègent les données.
// Laissées vides, le site tourne en mode démo avec des personnages d'exemple.
window.FDC_CONFIG = {
  supabaseUrl: "https://henpzizxwwnbnrfdgehg.supabase.co",
  supabaseAnonKey: "sb_publishable_Q8aOaWnRaGLGTHdD9_Y5Cw_b6w0-0Kw",
};
