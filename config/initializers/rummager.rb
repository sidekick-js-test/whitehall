require 'gds_api/rummager'

Whitehall.government_search_client = GdsApi::Rummager.new(
    ENV.fetch("RUMMAGER_HOST") + Whitehall.government_search_index_path)
