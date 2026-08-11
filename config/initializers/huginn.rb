Huginn.configure do |config|
  config.pagy_items = 100
  config.pagy_max_items = 500
  # Estratégias de busca (uma ou combinadas com OR):
  #   :pg_trgm   -> similaridade trigram (%) OU unaccent+ILIKE (tolerante a typos)
  #   :full_text -> full text search sobre lexemas (to_tsvector @@ plainto_tsquery)
  # Config ousada neste dataset: :full_text é a mais rápida; para unir as duas
  # fontes (typos + morfologia) use [ :pg_trgm, :full_text ].
  config.search_strategy = :full_text
  config.unaccent_function = "public.f_unaccent"
  config.fts_dictionary = "portuguese"
  config.fts_function = "public.f_tsvector"
  config.auto_include_datatable = true
  config.auto_include_searchable = true
end
